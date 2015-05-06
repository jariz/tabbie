#CustomColumn is part of the tabbie core.
#blabla

class Columns.CustomColumn extends Columns.FeedColumn
  element: "feedly-item"
  responseType: "json"
  dataPath: "items"

  attemptAdd: (successCallback) =>
    chrome.permissions.request
      origins: ["https://feedly.com/"]
    , (granted) =>
      if granted
        if typeof successCallback is "function" then successCallback();