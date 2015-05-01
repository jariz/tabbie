#CustomColumn is part of the tabbie core.
#blabla

class Columns.CustomColumn extends Columns.FeedColumn
  element: "custom-item"
  xmlTag: "item"
  responseType: "xml"

  # name, link, name, etc all get set by Tabbie core

  attemptAdd: (successCallback) =>
    uri = new URI @url
    uri.path("")
    console.log "[attemptAdd]", "full", @url, "formatted", uri.toString()

    chrome.permissions.request
      origins: [uri.toString()]
    , (granted) =>
      if granted and typeof successCallback is 'function' then successCallback()