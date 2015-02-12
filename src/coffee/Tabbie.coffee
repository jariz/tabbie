class Tabbie
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
        @addColumn column
        @packery.layout()
      document.getElementById("removed_toast").show()
      @packery.remove columnEl
      @usedColumns = @usedColumns.filter (c) -> c.id isnt column.id
      @syncAll()
    columnEl.addEventListener "column-refresh", => column.refresh columnEl, holderEl
    columnEl.addEventListener "column-settings", =>
      column.settings -> column.refresh columnEl holderEl

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
        newcol = new Columns[col.className](@)
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
      columnWidth: document.querySelector ".grid-sizer",
      rowHeight: document.querySelector ".grid-sizer",
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
    res = store.get("lastRes", false)
    if res and (res[0] isnt document.body.clientHeight or res[1] isnt document.body.clientWidth)
      @packery.layout()

    #fab stuff
    fabs = document.querySelector ".fabs"
    fab = document.querySelector ".fab-add"
    fab2 = document.querySelector ".fab-edit"
    trans = @meta.byId "core-transition-center"
    trans.setup fab2

    fabs.addEventListener "mouseenter", ->
      if fab2.hasAttribute "hidden" then fab2.removeAttribute "hidden"
      trans.go fab2,
        opened: true

    fabs.addEventListener "mouseleave", ->
      trans.go fab2,
        opened: false

    fab2.addEventListener "click", =>
      if active = fab2.classList.contains "active"
        fab2.classList.remove "active"
      else
        fab2.classList.add "active"

      column.editMode not active for column in @usedColumns

    fab.addEventListener "click", =>
      dialog = document.getElementById "column_chooser"
      columnchooser = dialog.querySelector "column-chooser"
      columnchooser.columns = @columns
      dialog.toggle()

      if(!@columnChosenBound)
        @columnChosenBound = true
        dialog.addEventListener "column-chosen", (e) =>
          column = new Columns[e.detail.className]
          dialog.toggle()
          column.settings =>
            @addColumn(column)
            @packery.layout()

  register: (columnName, dir) =>
    @columnNames.push columnName

  packery: null
  columns: []
  columnNames: [],
  usedColumns: []

tabbie = new Tabbie