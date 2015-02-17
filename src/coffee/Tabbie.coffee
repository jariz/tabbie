class Tabbie

  version: "0.1-alpha"
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
    columnEl.style.height = (document.documentElement.clientHeight / 2) - 10
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
        newcolumn = new Columns[column.className]
        newcolumn[key] = column[key] for key of column when typeof column[key] isnt 'function'
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
        newcol = new Columns[col.className]
        newcol[key] = col[key] for key of col when typeof col[key] isnt 'function'
        cols[i] = newcol
      @usedColumns = cols

    #get meta from dom
    @meta = document.getElementById "meta"

    #load column definitions
    for column in @columnNames
      continue if typeof Columns[column] is 'undefined'
      @columns.push new Columns[column]

    #load packery (layout manager)
    @packery = new Packery document.querySelector ".column-holder",
      columnWidth: document.clientWidth / 4
#      columnWidth: ".grid-sizer",
#      rowHeight: document.querySelector ".grid-sizer",
      isInitLayout: false,
      isHorizontal: true

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
    adddialog.addButton "add", =>
      adddialog.toggle()
      for column in columnchooser.selectedColumns
        column = new Columns[column.className]
        @addColumn(column)
        @packery.layout()

    fab.addEventListener "click", =>
      columnchooser.clear()
      fabanim = document.createElement "fab-anim"
      fabanim.classList.add "fab-anim-add"
      fabanim.addEventListener "webkitTransitionEnd", ->
        adddialog.toggle ->
          fabanim.remove()

      document.body.appendChild fabanim
      fabanim.play()

  register: (columnName, dir) =>
    @columnNames.push columnName

  packery: null
  columns: []
  columnNames: [],
  usedColumns: []

tabbie = new Tabbie