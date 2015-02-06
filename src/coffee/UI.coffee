class UI
  constructor: ->
    window.addEventListener 'polymer-ready', this.render #when polymer is ready to go, ♫ bind the UI ♫

  renderColumns: ->
    @addColumn column, true for column in @usedColumns

  addColumn: (column, dontsave) ->
    if not column.id then column.id = Math.round Math.random() * 1000000

    if not dontsave
      buffer = @usedColumns
      buffer.push column.toJSON()
      @usedColumns = buffer

    columnEl = document.createElement "item-column"
    columnEl.column = column
    holder = document.querySelector ".column-holder"

    holder.appendChild columnEl
    @packery.addItems [ columnEl ]

    columnEl.style.width = (25 * column.width)+"%"
    columnEl.style.height = document.documentElement.clientHeight / 2
    holderEl = columnEl.querySelector("html /deep/ paper-shadow .holder")
    column.render columnEl, holderEl

    draggie = new Draggabilly columnEl,
      handle: "html /deep/ core-toolbar",

    @packery.bindDraggabillyEvents draggie

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
    columnEl.addEventListener "column-refresh", => column.refresh columnEl, holderEl
    columnEl.addEventListener "column-settings", => column.settings()

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
    console.log op

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

  render: =>
    #this turns usedColumn into a object that gets synced with localStorage.
    Object.defineProperty @, "usedColumns",
      get: ->
        if not cols = store.get "usedColumns" then [] else
          for col, i in cols
            newcol = new window[col.className](@)
            newcol[key] = col[key] for key of col when typeof col[key] isnt 'function'
            cols[i] = newcol
          cols
      set: (val) ->
        store.set "usedColumns", val
        store.set "lastRes", [
          document.body.clientHeight,
          document.body.clientWidth
        ]

    #get meta from dom
    @meta = document.getElementById "meta"

    #load column definitions
    for column in @columnNames
      @columns.push new window[column](UI)

    #load packery (layout manager)
    @packery = new Packery document.querySelector ".column-holder",
      columnWidth: document.querySelector ".grid-sizer",
      rowHeight: document.querySelector ".grid-sizer",
      isInitLayout: false,
      isHorizontal: true

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

    mouseHasEntered = false
    fabs.addEventListener "mouseenter", ->
      mouseHasEntered = true
      trans.go fab2,
        opened: true

    timeout = -1
    fabs.addEventListener "mouseleave", ->
      if mouseHasEntered
        mouseHasEntered = false
        return
      if timeout then clearTimeout timeout
      timeout = setTimeout ->
        trans.go fab2,
          opened: false
      , 1000

    fab.addEventListener "click", =>
      dialog = document.getElementById "column_chooser"
      columnchooser = dialog.querySelector "column-chooser"
      columnchooser.columns = @columns
      dialog.toggle()

      dialog.addEventListener "column-chosen", (e) =>
        column = e.detail
        dialog.toggle()
        column.settings =>
          @addColumn(column)
          @packery.layout()

  packery: null
  columns: []
  columnNames: [
    "HackerNews",
    "Reddit",
    "Dribbble"
  ],
  usedColumns: []

ui = new UI