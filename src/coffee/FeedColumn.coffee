# FeedColumn makes it easy to make feed-based columns.
# Summed up: it makes a request from a API endpoint that returns json,
# It loops trough it's result, adds a element for each item in the loop, sets 'item' on the element, and its it to the holder.
# Also automatically takes care of caching.

class Columns.FeedColumn extends Columns.Column

  # The element name that will be inserted
  element: false

  # API endpoint
  url: false

  # Path inside returned JSON object that has the array we'll loop trough.
  # Example: data.children when returned obj from server is { data: { children: [] } }
  # Leave null for no path (i.e. when server directly returns array)
  dataPath: null

  # Same as dataPath, but for items in the array itself
  childPath: null

  draw: (data, holderElement) ->
    @loading = false

    if not @element
      console.warn "Please define the 'element' property on your column class!"
      return

    if @dataPath then data = eval "data." + @dataPath

    for child in data
      card = document.createElement @element
      if @childPath then child = eval "child." + @childPath
      card.item = child
      holderElement.appendChild card

  refresh: (columnElement, holderElement) ->
    @refreshing = true

    if not @url
      console.warn "Please define the 'url' property on your column class!"
      return

    fetch(@url)
    .then (response) =>
      if response.status is 200
        Promise.resolve response.json()
      else Promise.reject new Error response.statusText
    .then (json) =>
      @refreshing = false
      @cache = json
      tabbie.sync @
      holderElement.innerHTML = ""
      @draw @cache, holderElement
    .catch (error) =>
      console.error error
      @refreshing = false

  render: (columnElement, holderElement) ->
    super columnElement, holderElement

    if Object.keys(@cache).length
      @draw @cache, holderElement
      @refresh columnElement, holderElement
    else @refresh columnElement, holderElement