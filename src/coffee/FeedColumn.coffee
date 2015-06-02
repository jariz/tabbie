# FeedColumn makes it easy to make feed-based columns.
# Summed up: it makes a request from a API endpoint that returns json,
# It loops trough it's result, adds a element for each item in the loop, sets 'item' on the element, and its it to the holder.
# Also automatically takes care of caching.

class Columns.FeedColumn extends Columns.Column

  # The element name that will be inserted
  element: false

  # API endpoint
  url: false

  # Response type (json, xml)
  responseType: 'json'

  # Path inside returned JSON object that has the array we'll loop trough.
  # Example: data.children when returned obj from server is { data: { children: [] } }
  # Leave null for no path (i.e. when server directly returns array)
  dataPath: null

  # Same as dataPath, but for items in the array itself
  childPath: null

  baseUrl: false
  infiniteScroll: false
  page: 1

  draw: (data, holderElement) ->
    @loading = false

    if @flex then holderElement.classList.add "flex"
    else holderElement.classList.remove "flex"

    if not @element
      console.warn "Please define the 'element' property on your column class!"
      return

    if @dataPath then data = eval "data." + @dataPath

    if @responseType is 'xml'
      parser = new DOMParser
      xmlDoc = parser.parseFromString data, 'text/xml'
      items = xmlDoc.getElementsByTagName @xmlTag
      data = []

      for item in items
        converted = {}
        nodes = item.childNodes
        for el in nodes
          converted[el.nodeName] = el.textContent
        data.push converted

    for child in data
      card = document.createElement @element
      if @childPath then child = eval "child." + @childPath
      card.item = child
      holderElement.appendChild card

    #needed for proper flex
    for num in [0..10] when @flex
      hack = document.createElement @element
      hack.className = "hack"
      holderElement.appendChild hack

  refresh: (columnElement, holderElement, adding) ->
    @refreshing = true

    if @infiniteScroll
      @baseUrl = @url if not @baseUrl
      @url = @baseUrl.replace "{PAGENUM}", @page

    if not @url
      console.warn "Please define the 'url' property on your column class!"
      return

    fetch(@url)
    .then (response) =>
      if response.status is 200
        dataType = 'json'
        dataType = 'text' if @responseType is 'xml'
        Promise.resolve response[dataType]()
      else Promise.reject new Error response.statusText
    .then (data) =>
      @refreshing = false
      @cache = data
      tabbie.sync @
      holderElement.innerHTML = "" if not adding
      if @flex then hack.remove() for hack in holderElement.querySelectorAll ".hack"
      @draw @cache, holderElement
    .catch (error) =>
      console.error error
      @refreshing = false
      @loading = false

      #no cached data to display? show error
      if not @cache or @cache.length is 0 then @error holderElement

  render: (columnElement, holderElement) ->
    super columnElement, holderElement

    if @infiniteScroll then holderElement.addEventListener "scroll", =>
      if not @refreshing and holderElement.scrollTop + holderElement.clientHeight >= holderElement.scrollHeight - 100
        if typeof @page is 'number' then @page++
        @refresh columnElement, holderElement, true

    if Object.keys(@cache).length
      @draw @cache, holderElement
    @refresh columnElement, holderElement
