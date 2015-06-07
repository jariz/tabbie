class Columns.WebsitesPanel extends Columns.Column
  name: "WebsitesPanel"
  dialog: "websites-panel-dialog"
  thumb: "img/column-apps.png"
  flex: true
  link: ""
  element: "websites-panel-item"

  refresh: (columnElement, holderElement) ->
    holderElement.innerHTML = ""

    # initialize config
    if not @config.websites
      @config =
        websites: []

    # create items
    for website in @config.websites
      app = document.createElement "websites-panel-item"
      try
        app.name = website.name
        app.icon = website.icon.url
        app.url = website.url
      catch e
        console.warn e

      holderElement.appendChild app

    #needed for proper flex
    for num in [0..10] when @flex
      hack = document.createElement "websites-panel-item"
      hack.className = "hack"
      holderElement.appendChild hack

  render: (columnElement, holderElement) ->
    super columnElement, holderElement
    @refreshing = false
    @loading = false

    @refresh columnElement, holderElement

tabbie.register "WebsitesPanel"
