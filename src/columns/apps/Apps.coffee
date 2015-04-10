class Columns.Apps extends Columns.Column
  name: "Apps"
  thumb: "column-apps.png"
  flex: true
  link: "chrome://apps"

  attemptAdd: (successCallback) =>
    chrome.permissions.request
      permissions: ["management"],
      origins: ["chrome://favicon/*"]
    , (granted) =>
      if granted
        if typeof successCallback is 'function' then successCallback()

  refresh: (columnElement, holderElement) ->
    holderElement.innerHTML = ""
    chrome.management.getAll (extensions) =>
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
        holderElement.appendChild app

      #needed for proper flex
      for num in [0..10] when @flex
        hack = document.createElement "app-item"
        hack.className = "hack"
        holderElement.appendChild hack

  render: (columnElement, holderElement) ->
    super columnElement, holderElement
    @refreshing = false
    @loading = false

    @refresh columnElement, holderElement

tabbie.register "Apps"