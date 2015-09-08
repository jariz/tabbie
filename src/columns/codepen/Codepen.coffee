class Columns.Codepen extends Columns.FeedColumn
  name: "Codepen"
  width: 2
  thumb: "img/column-codepen.png"
  link: "https://codepen.io"

  element: "codepen-item"
  url: "http://codepen.io/popular/feed/"
  responseType: "xml"
  xmlTag: "item"
  flex: true

  attemptAdd: (successCallback) ->
    chrome.permissions.request
      origins: ['http://codepen.io/']
    , (granted) =>
      if granted and typeof successCallback is 'function' then successCallback()

tabbie.register "Codepen"
