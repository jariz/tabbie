#CustomColumn is part of the tabbie core.
#blabla

class Columns.CustomColumn extends Columns.FeedColumn
  element: "feedly-item"
  responseType: "json"
  page: "",
  infiniteScroll: true,

  draw: (data, holderElement) =>
    if typeof data.length isnt 'number'
      @page = data.continuation
      data = data.items
      @cache = data
    super data, holderElement

  attemptAdd: (successCallback) =>
    chrome.permissions.request
      origins: ["https://feedly.com/"]
    , (granted) =>
      if granted
        if typeof successCallback is "function" then successCallback();