class HackerNews extends Column
  name: "HackerNews"
  width: 1
  thumb: "column-hackernews.png"

  draw: (data, holderElement) ->
    @loading = false

    for child in data
      card = document.createElement "hn-item"
      card.item = child
      holderElement.appendChild card

  refresh: (columnElement, holderElement) ->
    @refreshing = true

    #suck it, panda
    fetch "https://api.pnd.gs/v1/sources/hackerNews/popular"
    .then (response) =>
      if response.status is 200
        Promise.resolve response.json()
      else Promise.reject new Error response.statusText
    .then (json) =>
      @refreshing = false
      @cache = json
      ui.sync @
      holderElement.innerHTML = ""
      @draw @cache, holderElement
    .catch (error) =>
      @refreshing = false

  render: (columnElement, holderElement) ->
    super columnElement, holderElement

    if Object.keys(@cache).length
      @draw @cache, holderElement
      @refresh columnElement, holderElement
    else @refresh columnElement, holderElement
