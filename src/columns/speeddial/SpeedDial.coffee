class Columns.SpeedDial extends Columns.Column
  name: "SpeedDial"
  dialog: "speed-dial-dialog"
  thumb: "img/column-speeddial.png"
  flex: true
  element: "speed-dial-item"
  link: ""

  refresh: (columnElement, holderElement) ->
    holderElement.innerHTML = ""

    # initialize config
    if not @config.websites
      @config =
        websites: []

    # create items
    for website in @config.websites
      app = document.createElement "speed-dial-item"
      try
        app.name = website.name
        app.icon = website.icon.url
        app.url = website.url
      catch e
        console.warn e

      holderElement.appendChild app

    #needed for proper flex
    for num in [0..10] when @flex
      hack = document.createElement "speed-dial-item"
      hack.className = "hack"
      holderElement.appendChild hack

  render: (columnElement, holderElement) ->
    super columnElement, holderElement
    @refreshing = false
    @loading = false

    @refresh columnElement, holderElement

tabbie.register "SpeedDial"
