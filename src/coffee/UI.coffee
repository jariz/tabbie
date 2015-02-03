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

    holder.appendChild(columnEl)
    @packery.addItems [ columnEl ]

    columnEl.style.width = (25 * column.width)+"%"
    columnEl.style.height = document.documentElement.clientHeight / 2
    column.render columnEl

    draggie = new Draggabilly columnEl,
      handle: "html /deep/ core-toolbar",

    @packery.bindDraggabillyEvents(draggie)

    if column.config.position
      pItem = item for item in @packery.items when item.element is columnEl
      pItem.goTo(column.config.position.x, column.config.position.y)

    #bind column events
    columnEl.addEventListener "column-delete", =>
      @packery.remove(columnEl)
      @usedColumns = @usedColumns.filter (c) -> c.id isnt column.id
    columnEl.addEventListener "column-refresh", => column.refresh(columnEl)
    columnEl.addEventListener "column-settings", => column.settings()

    columnEl.animate [
      opacity: 0
    ,
      opacity: 1
    ]
    ,
      direction: 'alternate',
      duration: 500

  layoutChanged: () =>
    for columnEl in document.querySelectorAll("item-column")
      item = @packery.getItem(columnEl);
      position = item.position
      column = columnEl.querySelector("html /deep/ paper-shadow").templateInstance.model.column
      column.config.position = position;
      @usedColumns = @usedColumns.map (c) ->
        if c.id is column.id then c = column
        c

  render: =>
    #this turns usedColumn into a object that gets synced with localStorage.
    Object.defineProperty @, "usedColumns",
      get: ->
        if not cols = store.get "usedColumns" then [] else
          for col, i in cols
            newcol = new window[col.className]
            newcol[key] = col[key] for key of col when typeof col[key] isnt 'function'
            cols[i] = newcol
          cols
      set: (val) -> store.set "usedColumns", val

    #load column definitions
    for column in @columnNames
      @columns.push new window[column];

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
    @renderColumns();

    #bind fab
    fab = document.getElementById "addcolumn"
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