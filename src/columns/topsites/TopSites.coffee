class Columns.TopSites extends Columns.Column
  name: "Top sites"
  thumb: "img/column-topsites.png"

  attemptAdd: (successCallback) =>
    chrome.permissions.request
      permissions: ["topSites"],
      origins: ["chrome://favicon/*"]
    , (granted) =>
      if granted
        if typeof successCallback is 'function' then successCallback()

  refresh: (columnElement, holderElement) ->
    chrome.topSites.get (sites) =>
      console.log sites
      holderElement.innerHTML = ""
      for site in sites
        paper = document.createElement "bookmark-item"
        paper.showdate = false
        paper.title = site.title
        paper.url = site.url
        holderElement.appendChild paper

  render: (columnElement, holderElement) ->
    super columnElement, holderElement
    @refreshing = false
    @loading = false
    @refresh columnElement, holderElement

tabbie.register "TopSites"