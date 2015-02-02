class UI
  constructor: ->
    window.addEventListener 'polymer-ready', this.render #when polymer is ready to go, ♫ bind the UI ♫

  renderColumns: ->
    @addColumn column, true for column in @usedColumns

  addColumn: (column, dontsave) ->
    if not dontsave
      buffer = @usedColumns
      buffer.push column.toJSON()
      @usedColumns = buffer

    columnEl = document.createElement "item-column"
    columnEl.column = column
    holder = document.querySelector ".column-holder"
    holder.appendChild columnEl

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
        if column.dialog
          cdialog = document.getElementById column.dialog
          cdialog.toggle()
          cdialog.querySelector("paper-button[affirmative]").addEventListener "click", =>
            cdialog.toggle()
            @addColumn column
        else
          @addColumn column


  columns: []
  columnNames: [
    "HackerNews",
    "Reddit",
    "Column",
    "Column"
  ],
  usedColumns: []