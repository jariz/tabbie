class Tabbie

  version: "0.5"
  editMode: false

  constructor: ->
    console.time("polymer-ready");
    window.addEventListener 'polymer-ready', @render

  renderColumns: ->
    @addColumn column, true for column in @usedColumns when typeof column isnt 'undefined'

  addColumn: (column, dontsave) ->
    if not column.id then column.id = Math.round Math.random() * 1000000

    if not dontsave
      @usedColumns.push column
      @syncAll()

    columnEl = document.createElement "item-column"
    columnEl.column = column
    holder = document.querySelector ".column-holder"

    holder.appendChild columnEl
    @packery.addItems [ columnEl ]

    columnEl.style.width = (25 * column.width)+"%"
    columnEl.style.height = (50 * column.height)+"%"
    holderEl = columnEl.querySelector("html /deep/ paper-shadow .holder")
    column.render columnEl, holderEl

    column.draggie = new Draggabilly columnEl,
      handle: "html /deep/ core-toolbar /deep/ paper-icon-button.drag",
    column.draggie.disable()

    @packery.bindDraggabillyEvents column.draggie

    if column.config.position
      pItem = item for item in @packery.items when item.element is columnEl
      pItem.goTo column.config.position.x, column.config.position.y

    #bind column events
    columnEl.addEventListener "column-delete", =>
      toast = document.getElementById "removed_toast_wrapper"
      toast.column = column
      toast.restore = =>
        newcolumn = new Columns[column.className](column)
        @addColumn newcolumn
        @packery.layout()
      document.getElementById("removed_toast").show()
      @packery.remove columnEl
      @usedColumns = @usedColumns.filter (c) -> c.id isnt column.id
      @syncAll()
    columnEl.addEventListener "column-refresh", => column.refresh columnEl, holderEl
    columnEl.addEventListener "column-settings", =>
      column.settings -> column.refresh columnEl, holderEl

    if @editMode then column.editMode true

    columnEl.animate [
      opacity: 0
    ,
      opacity: 1
    ]
    ,
      direction: 'alternate',
      duration: 500

  noColumnsCheck: =>
    if @packery.items.length > 0 then op = 0 else op = 1
    document.querySelector(".no-columns-container").style.opacity = op

  autoRefresh: =>
    setInterval ->
      #nasty stuff, but tabbie has been nasty prototype stuff since the beginning
      column.shadowRoot.querySelector("[icon='refresh']").dispatchEvent(new MouseEvent("click")) for column in document.querySelectorAll("item-column")
    , 1000 * 60 * 5

  layoutChanged: () =>
      @noColumnsCheck()
      for columnEl in document.querySelectorAll("item-column")
        item = @packery.getItem(columnEl)
        position = item.position
        columnId = columnEl.querySelector("html /deep/ paper-shadow").templateInstance.model.column.id
        column = c for c in @usedColumns when c.id is columnId

        #what will now follow, is a fix for one of the strangest things i've seen in a while in my 7+ year programming career.
        #ok not really. but still.
        #we need to clear the column's config, or else changes get carried on across other columns
        #do not ask me why or how.
        newconfig = {}
        newconfig[k] = v for k, v of column.config when column.config.hasOwnProperty k
        newconfig.position = position
        column.config = newconfig
      @syncAll()

  sync: (column, dontSyncAll) =>
    @usedColumns = @usedColumns.map (c) ->
      if c.id is column.id then c = column
      c
    if not dontSyncAll then @syncAll()

  syncAll: () =>
    used = []
    used.push column.toJSON() for column in @usedColumns
    store.set "usedColumns", @resortUsedColumns used

    store.set "customColumns", @customColumns.map (column) -> column.toJSON()

    store.set "lastRes", [
      document.body.clientHeight,
      document.body.clientWidth
    ]

  renderBookmarkTree: (holder, tree, level) =>
    console.log "renderBookmarkTree level: ", level, " tree: ", tree
    for item in tree
      paper = document.createElement "bookmark-item"
      paper.item = item
      paper.level = level
      paper.showdate = level is 0
      paper.folder = !!item.children
      paper.title = item.title
      if level isnt 0 then paper.setAttribute "hidden", "" #only root items are visible on initial render
      paper.id = item.id

      if paper.folder then paper.addEventListener "click", ->
        loopie = (items) =>
          for item in items
            console.info "loopie id", item.id, "parent", item.parentId
            el = holder.querySelector "[id='"+item.id+"']"
            el.opened = @opened
            if @opened then el.setAttribute("hidden", "")
            else el.removeAttribute("hidden")

            if item.children and @opened then loopie item.children

        loopie @item.children, true

        @opened = !@opened

      if not paper.folder
        paper.url = item.url
        paper.date = item.dateAdded

      holder.appendChild paper

      if paper.folder
        @renderBookmarkTree holder, item.children, level+1

  tour: =>
    setTimeout ->
      steps = document.querySelectorAll("tour-step")
      steps[0].async =>
        currStep = 0
        tourEnded = false
        tours = document.querySelector "#tours"
        tours.endTour = endTour = ->
          store.set "notour", true
          tourEnded = true
        tours.openFabs = (e) ->
          if e.detail
            document.querySelector(".fabs").dispatchEvent new MouseEvent 'mouseenter'
          else document.querySelector(".fabs").dispatchEvent new MouseEvent 'mouseleave'
        for step in steps
          step.addEventListener "core-overlay-open", (e) ->
            if e.detail or tourEnded then return
            currStep++
            step = steps[currStep]
            if typeof step == 'undefined' then endTour()
            else step.toggle()

        steps[0].toggle()
    , 1000

  render: =>
    console.timeEnd('polymer-ready')
    console.time('tabbie render')

    if not store.has "notour" then @tour()

    #load all default columns
    if not cols = store.get "usedColumns" then @usedColumns = [] else
      for col, i in cols
        if typeof Columns[col.className] is 'undefined'
          delete cols[i]
          continue
        newcol = new Columns[col.className](col)
        cols[i] = newcol
      @usedColumns = cols

    #get meta from dom
    @meta = document.getElementById "meta"

    #load default column definitions
    @columns.push new Columns[column] {}, true for column in @columnNames when typeof Columns[column] isnt 'undefined'

    #load custom user made column definitions
    customColumns = store.get "customColumns", []
    @customColumns.push new Columns[column.className](column) for column in customColumns
    @columns.push column for column in @customColumns

    #resort columns by alphabet
    @resortColumns()

    #load packery (layout manager)
    @packery = new Packery document.querySelector(".column-holder"),
      columnWidth: ".grid-sizer"
      rowHeight: ".grid-sizer"
      itemSelector: "item-column",

    #packery bindings
    @packery.on "dragItemPositioned", @layoutChanged
    @packery.on "layoutComplete", @layoutChanged
    @packery.on "removeComplete", =>
      @packery.layout()

    #render loaded columns
    @renderColumns()

    @noColumnsCheck()
    @autoRefresh()

    res = store.get "lastRes", false
    if res and (res[0] isnt document.body.clientHeight or res[1] isnt document.body.clientWidth) then @packery.layout()

    document.querySelector("#about").async =>
      for item in document.querySelectorAll("#about paper-item")
        item.addEventListener "click", -> if @getAttribute("href") then window.open @getAttribute("href")

    fabs = document.querySelector ".fabs"
    allFabs = [".fab-edit", ".fab-about", ".fab-update"]
    allFabs = allFabs.map -> document.querySelector arguments[0]
    trans = @meta.byId "core-transition-center"

    for fab in allFabs
      trans.setup fab
      fab.removeAttribute "hidden"

    fabs.addEventListener "mouseenter", -> trans.go fab, { opened: true } for fab in allFabs
    fabs.addEventListener "mouseleave", -> trans.go fab, { opened: false } for fab in allFabs

    document.querySelector(".fab-edit").addEventListener "click", (e) =>
      if active = e.target.classList.contains "active" then e.target.classList.remove "active"
      else e.target.classList.add "active"

      @editMode = not active
      column.editMode not active for column in @usedColumns

    document.querySelector(".fab-about").addEventListener "click", =>
      aboutdialog = document.querySelector "#about"
      templ = aboutdialog.querySelector("html /deep/ template")
      templ.version = @version
      templ.polymerVersion = Polymer.version
      fabanim = document.createElement "fab-anim"
      fabanim.classList.add "fab-anim-about"
      fabanim.addEventListener "webkitTransitionEnd", ->
        aboutdialog.toggle ->
          fabanim.remove()

      document.body.appendChild fabanim
      fabanim.play()

    updateFab = document.querySelector(".fab-update")
    if store.has "hideUpdateButton"+@version then updateFab.parentNode.style.display = "none"
    updatediag = document.querySelector "#update"
    updatediag.querySelector(".hide-button").addEventListener "click", =>
      store.set "hideUpdateButton"+@version, "1"
      document.querySelector(".fab-update-wrapper")
      updatediag.toggle()
      updateFab.parentNode.style.display = "none"

    updateFab.addEventListener "click", =>
      fabanim = document.createElement "fab-anim"
      fabanim.classList.add "fab-anim-update"
      fabanim.addEventListener "webkitTransitionEnd", ->
        updatediag.toggle ->
          fabanim.remove()

      document.body.appendChild fabanim
      fabanim.play()

    columnchooser = document.querySelector "html /deep/ column-chooser"
    columnchooser.columns = @columns

    adddialog = document.querySelector "#addcolumn"
    search = document.querySelector "#searchdialog"

    searchBar = search.querySelector ".search-bar"
    searchProgress = search.querySelector ".search-progress"
    searchSuggestions = search.querySelector "auto-suggestions"

    search.replaceHeader [searchBar, searchProgress]

    closeSearch = ->
      search.toggle ->
        searchBar.value = ""
        searchSuggestions.suggestions = []

    searchSuggestions.addEventListener "suggestion-chosen", (e) =>
      @createColumnFromFeedly e.detail
      closeSearch()

    query = ""
    timeout = undefined

    searchBar.addEventListener "keydown", (e) =>
      prevent = true
      switch e.keyCode
        when 40 then searchSuggestions.highlightDown()
        when 38 then searchSuggestions.highlightUp()
        when 13 then searchSuggestions.highlightChosen()
        when 27 then closeSearch()
        else prevent = false

      if prevent then e.preventDefault()

    searchBar.addEventListener "keyup", (e) =>
      if query != searchBar.value
        query = searchBar.value

        if not query
          searchSuggestions.suggestions = []
          searchSuggestions.error = false
          return

        if timeout then clearTimeout timeout

        timeout = setTimeout =>
          searchProgress.setAttribute("active", "");
          fetch "https://feedly.com/v3/search/auto-complete?query="+query+"&sites=10&topics=0&libraries=0&locale=en-US"
          .then (response) ->
            if response.status is 200 then Promise.resolve response
            else Promise.reject new Error response.statusText
          .then (response) ->
            return response.json()
          .then (json) =>
            searchSuggestions.suggestions = json.sites
            searchSuggestions.error = false
            searchProgress.removeAttribute("active");
          .catch (error) =>
            searchProgress.removeAttribute("active");
            console.error error
            searchSuggestions.suggestions = []
            searchSuggestions.error = true
        , 300

    adddialog.addButton 'add', ->
      chrome.permissions.request
        origins: ["https://feedly.com/", "http://storage.googleapis.com/"]
      , (granted) =>
        if granted
          search.toggle()
          searchBar.focus()

    columnchooser.async =>
      columnchooser.shadowRoot.addEventListener "click", (e) =>
        if not e.target.matches ".grid .column paper-ripple" then return
        column = e.target.templateInstance.model.column
        column.attemptAdd =>
          adddialog.toggle()
          newcolumn = new Columns[column.className](column)
          @addColumn newcolumn
          @packery.layout()

    columnchooser.addEventListener "delete-column", (e) =>
      columnchooser.packery.remove colEl for colEl in columnchooser.shadowRoot.querySelectorAll(".column") when colEl.templateInstance.model.column is e.detail
#      @columns.splice @columns.indexOf(e.detail), 1
      @customColumns.splice @customColumns.indexOf(e.detail), 1

      @syncAll()

    document.querySelector(".fab-add").addEventListener "click", =>
      fabanim = document.createElement "fab-anim"
      fabanim.classList.add "fab-anim-add"
      fabanim.addEventListener "webkitTransitionEnd", ->

      adddialog.toggle ->
        fabanim.remove()
      , -> columnchooser.shown()

      document.body.appendChild fabanim
      fabanim.play()

    document.querySelector(".bookmarks-drawer-button").addEventListener "click", ->
      settings = document.querySelector(".settings")
      chrome.permissions.request
        permissions: ["bookmarks"],
        origins: ["chrome://favicon/*"]
      , (granted) =>
        if granted
          drawer = document.querySelector "app-drawer.bookmarks"
          drawer.show()
          drawer.addEventListener "opened-changed", ->
            if @opened then settings.classList.add("force") else settings.classList.remove("force")

          chrome.bookmarks.getRecent 20, (tree) =>
            console.log tree
            recent = drawer.querySelector(".recent")
            recent.innerHTML = ""
            tabbie.renderBookmarkTree recent, tree, 0

          chrome.bookmarks.getTree (tree) =>
            tree = tree[0].children
            console.log "tree", tree
            all = drawer.querySelector(".all")
            all.innerHTML = ""

            tabbie.renderBookmarkTree all, tree, 0

    document.querySelector(".top-drawer-button").addEventListener "click", ->
      settings = document.querySelector(".settings")
      chrome.permissions.request
        permissions: ["topSites"],
        origins: ["chrome://favicon/*"]
      , (granted) =>
        if granted
          chrome.topSites.get (sites) =>
            console.log sites
            drawer = document.querySelector("app-drawer.top")
            drawer.innerHTML = ""
            drawer.show()
            drawer.addEventListener "opened-changed", ->
              if @opened then settings.classList.add("force") else settings.classList.remove("force")
            for site in sites
              paper = document.createElement "bookmark-item"
              paper.showdate = false
              paper.title = site.title
              paper.url = site.url
              drawer.appendChild paper

    document.querySelector(".app-drawer-button").addEventListener "click", ->
      settings = document.querySelector(".settings")
      chrome.permissions.request
        permissions: ["management"],
        origins: ["chrome://favicon/*"]
      , (granted) =>
          if granted
            chrome.management.getAll (extensions) =>
              drawer = document.querySelector("app-drawer.apps")
              drawer.innerHTML = ""
              drawer.show()
              drawer.addEventListener "opened-changed", ->
                if @opened then settings.classList.add("force") else settings.classList.remove("force")

              for extension in extensions when extension.type.indexOf("app") isnt -1 and not extension.disabled
                console.log extension
                app = document.createElement "app-item"
                try
                  app.name = extension.name
                  app.icon = extension.icons[extension.icons.length-1].url
                  app.id = extension.id
                catch e
                  console.warn e

                app.addEventListener "click", -> chrome.management.launchApp this.id
                drawer.appendChild app


    console.timeEnd('tabbie render')

    document.querySelector(".recently-drawer-button").addEventListener "click", ->
      settings = document.querySelector(".settings")
      chrome.permissions.request
        permissions: ["sessions", "tabs"],
        origins: ["chrome://favicon/*"]
      , (granted) =>
        if granted
          chrome.sessions.getRecentlyClosed (sites) =>
            console.log sites
            drawer = document.querySelector("app-drawer.recently")
            drawer.innerHTML = ""
            drawer.show()
            drawer.addEventListener "opened-changed", ->
              if @opened then settings.classList.add("force") else settings.classList.remove("force")
            for site in sites
              paper = document.createElement "recently-item"
              if site.hasOwnProperty("tab")
                paper.window = 0
                paper.url = site.tab.url
                paper.title = site.tab.title
                paper.sessId = site.tab.sessionId
              else
                paper.window = 1
                paper.tab_count = site.window.tabs.length
                paper.sessId = site.window.sessionId

              paper.addEventListener "click", ->
                chrome.sessions.restore this.sessId
                drawer.hide()

              drawer.appendChild paper

  register: (columnName) =>
    @columnNames.push columnName

  createColumnFromFeedly: (feedly) =>

    #todo download and convert thumb to data url
    if feedly.visualUrl then thumb = feedly.visualUrl
    else thumb = "img/column-unknown.png";

    column = new Columns.CustomColumn
      name: feedly.title
      link: feedly.website
      baseUrl: "https://feedly.com/v3/streams/contents?count=20&streamId=" + encodeURIComponent(feedly.feedId) + "&continuation={PAGENUM}"
      thumb: thumb,
      custom: true

    @customColumns.push column
    @columns.push column
    @resortColumns()
    @syncAll()

  resortColumns: =>
    @columns.sort (a, b) -> if a.name < b.name then -1 else if a.name > b.name then 1 else 0

  resortUsedColumns: (used) =>
    used = used.map (clmn) ->
      if not clmn.config.position then clmn.config.position = {x: 0, y: 0}
      return clmn

    used.sort (a, b) -> a.config.position.y - b.config.position.y or a.config.position.x - b.config.position.x;

  customColumns: []
  packery: null
  columns: []
  columnNames: [],
  usedColumns: []

tabbie = new Tabbie