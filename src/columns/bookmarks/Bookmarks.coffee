class Columns.Bookmarks extends Columns.Column
  name: "Bookmarks"
  thumb: "img/column-bookmarks.png"
  link: "chrome://bookmarks"

  attemptAdd: (successCallback) =>
    chrome.permissions.request
      permissions: ["bookmarks"],
      origins: ["chrome://favicon/*"]
    , (granted) =>
      if granted
        if typeof successCallback is 'function' then successCallback()

  refresh: (columnElement, holderElement) ->
    @tabs.innerHTML = ""
    recent = document.createElement "div"
    recent.classList.add "recent"
    @tabs.appendChild recent
    all = document.createElement "div"
    all.classList.add "all"
    @tabs.appendChild all

    chrome.bookmarks.getRecent 20, (tree) =>
      tabbie.renderBookmarkTree recent, tree, 0

    chrome.bookmarks.getTree (tree) =>
      tree = tree[0].children
      tabbie.renderBookmarkTree all, tree, 0

  render: (columnElement, holderElement) ->
    super columnElement, holderElement
    @refreshing = false
    @loading = false

    holderElement.innerHTML = ""
    @tabs = document.createElement "bookmark-tabs"
    holderElement.appendChild @tabs

    @refresh columnElement, holderElement

tabbie.register "Bookmarks"