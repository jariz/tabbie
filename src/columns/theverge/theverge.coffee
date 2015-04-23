class Columns.TheVerge extends Columns.FeedColumn
  name: "TheVerge"
  thumb: "column-theverge.png"
  url: "https://www.theverge.com/rss/index.xml"
  element: "verge-item"
  link: "https://www.theverge.com"
  dataType: "rss"
  xmlTag: "entry"
  responseType: "xml"

  attemptAdd: (successCallback) ->
    chrome.permissions.request
      origins: ['https://www.theverge.com/']
    , (granted) =>
      if granted and typeof successCallback is 'function' then successCallback()

tabbie.register "TheVerge"
