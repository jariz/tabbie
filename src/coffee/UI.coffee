class UI
  constructor: ->
    window.addEventListener 'polymer-ready', this.render #when polymer is ready to go, ♫ bind the UI ♫

  render: =>
    #load columns
    for column in @columnNames
      @columns.push new window[column];

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
          cdialog.querySelector("paper-button[affirmative]").addEventListener "click", ->
            cdialog.toggle()
        else
          #add it


  columns: []
  columnNames: [
    "HackerNews",
    "Reddit",
    "Column",
    "Column"
  ]