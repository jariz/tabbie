class Tabbie

  version: "0.2.2-alpha"
  editMode: false

  constructor: ->
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
      handle: "html /deep/ core-toolbar",
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

  layoutChanged: () =>
      @noColumnsCheck()
      for columnEl in document.querySelectorAll("item-column")
        item = @packery.getItem(columnEl);
        position = item.position
        column = columnEl.querySelector("html /deep/ paper-shadow").templateInstance.model.column
        column.config.position = position;
        @sync column

  sync: (column) =>
    @usedColumns = @usedColumns.map (c) ->
      if c.id is column.id then c = column
      c
    @syncAll()

  syncAll: () =>
    used = []
    for column in @usedColumns
      used.push column.toJSON()
    store.set "usedColumns", used

    store.set "lastRes", [
      document.body.clientHeight,
      document.body.clientWidth
    ]

  render: =>
    #load all columns
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

    #load column definitions
    for column in @columnNames
      continue if typeof Columns[column] is 'undefined'
      @columns.push new Columns[column]

    #load packery (layout manager)
    @packery = new Packery document.querySelector(".column-holder"),
      columnWidth: ".grid-sizer"
      rowHeight: ".grid-sizer"
      itemSelector: "item-column",
#      gutter: 10

    #packery bindings
    @packery.on "dragItemPositioned", @layoutChanged
    @packery.on "layoutComplete", @layoutChanged
    @packery.on "removeComplete", =>
      @packery.layout()

    #render loaded columns
    @renderColumns()
    @noColumnsCheck();

    # check if resolution has changed since last save,
    # else we're gonna have to force a relayout because the positions may not be correct anymore
    # (each column has a percentage width relative to the body's width...)
    res = store.get "lastRes", false
    if res and (res[0] isnt document.body.clientHeight or res[1] isnt document.body.clientWidth)
      @packery.layout()

    #about shiz
    #nasty, but i have no way to check if the autobinding template has loaded, and it's not yet loaded at run time...
    setTimeout ->
      for item in document.querySelectorAll("#about paper-item")
        item.addEventListener "click", -> if @getAttribute("href") then window.open @getAttribute("href")
    , 100

    #fab stuff
    fabs = document.querySelector ".fabs"
    fab = document.querySelector ".fab-add"
    fab2 = document.querySelector ".fab-edit"
    fab3 = document.querySelector ".fab-about"
    trans = @meta.byId "core-transition-center"
    trans.setup fab2
    trans.setup fab3

    fabs.addEventListener "mouseenter", ->
      trans.go fab2,
        opened: true
      trans.go fab3,
        opened: true

    fabs.addEventListener "mouseleave", ->
      trans.go fab2,
        opened: false
      trans.go fab3,
        opened: false

    fab2.addEventListener "click", =>
      if active = fab2.classList.contains "active" then fab2.classList.remove "active"
      else fab2.classList.add "active"

      @editMode = not active
      column.editMode not active for column in @usedColumns

    fab3.addEventListener "click", =>
      aboutdialog = document.querySelector "#about"
      aboutdialog.querySelector("html /deep/ template").version = @version
      fabanim = document.createElement "fab-anim"
      fabanim.classList.add "fab-anim-about"
      fabanim.addEventListener "webkitTransitionEnd", ->
        aboutdialog.toggle ->
          fabanim.remove()

      document.body.appendChild fabanim
      fabanim.play()

    columnchooser = document.querySelector "html /deep/ column-chooser"
    columnchooser.columns = @columns

    adddialog = document.querySelector "#addcolumn"

    #once again, there's no way to check if templates have loaded, so settimeout it is
    setTimeout =>
      columns = adddialog.querySelectorAll "html /deep/ .column:not(.hack)"
      for columnEl in columns
        column = columnEl.templateInstance.model.column
        columnEl.addEventListener "click", (e) =>
          column = e.target.templateInstance.model.column
          column.attemptAdd =>
            adddialog.toggle()
            @addColumn column
            @packery.layout()
    , 100

    fab.addEventListener "click", =>
      fabanim = document.createElement "fab-anim"
      fabanim.classList.add "fab-anim-add"
      fabanim.addEventListener "webkitTransitionEnd", ->
        adddialog.toggle ->
          fabanim.remove()

      document.body.appendChild fabanim
      fabanim.play()
#    if not store.has "update-" + @version
#      setTimeout ->
#        toast = document.querySelector "#update_toast"
#        toast.toggle()
#      , 1000

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


          renderBookmarkTree = (holder, tree, level) =>
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
                renderBookmarkTree holder, item.children, level+1

          chrome.bookmarks.getRecent 20, (tree) =>
            console.log tree
            recent = drawer.querySelector(".recent")
            recent.innerHTML = ""
            renderBookmarkTree recent, tree, 0

          chrome.bookmarks.getTree (tree) =>
            tree = tree[0].children
            console.log "tree", tree
            all = drawer.querySelector(".all")
            all.innerHTML = ""

            renderBookmarkTree all, tree, 0

    document.querySelector(".top-drawer-button").addEventListener "click", ->
      settings = document.querySelector(".settings")
      chrome.permissions.request
        permissions: ["topSites"]
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
        permissions: ["management"]
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

  register: (columnName) =>
    @columnNames.push columnName

  packery: null
  columns: []
  columnNames: [],
  usedColumns: []

tabbie = new Tabbie