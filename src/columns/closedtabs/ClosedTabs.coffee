class Columns.ClosedTabs extends Columns.Column
  name: "Closed tabs"
  thumb: "img/column-closedtabs.png"
  link: "chrome://history"

  attemptAdd: (successCallback) =>
    chrome.permissions.request
      permissions: ["sessions", "tabs"],
      origins: ["chrome://favicon/*"]
    , (granted) =>
      if granted
        if typeof successCallback is 'function' then successCallback()

  refresh: (columnElement, holderElement) ->
    holderElement.innerHTML = ""
    chrome.sessions.getRecentlyClosed (sites) =>
      for site in sites
        paper = document.createElement "recently-item"
        if site.hasOwnProperty("tab")
          paper.window = 0
          paper.url = site.tab.url
          paper.title = site.tab.title
          paper.sessId = site.tab.sessionId
        else
          paper.window = 1
          paper.tab_count = site.window.tabs.length
          paper.sessId = site.window.sessionId

        paper.addEventListener "click", ->
          chrome.sessions.restore this.sessId

        holderElement.appendChild paper

  render: (columnElement, holderElement) ->
    super columnElement, holderElement
    @refreshing = false
    @loading = false
    @refresh columnElement, holderElement

tabbie.register "ClosedTabs"