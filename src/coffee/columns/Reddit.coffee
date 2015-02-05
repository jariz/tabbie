class Reddit extends Column
  name: "Reddit"
  width: 1
  dialog: "reddit_dialog"
  thumb: "column-reddit.png"

  draw: (data, holderElement) ->
    @loading = false

    for child in data.data.children
      card = document.createElement "reddit-item"
      card.item = child.data
      holderElement.appendChild card

  refresh: (columnElement, holderElement) ->
    switch @config.listing
      when 0 then listing = "hot"
      when 1 then listing = "new"
      when 2 then listing = "top"

    @refreshing = true

    fetch("https://www.reddit.com/r/"+@config.subreddit+"/"+listing+".json")
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
      .catch (error) ->
        @refreshing = false
        #todo something on error

  render: (columnElement, holderElement) ->
    super columnElement

#    Polymer.import ['reddit-item.html'], =>
    if Object.keys(@cache).length
      @draw @cache, holderElement
      @refresh columnElement, holderElement
    else @refresh columnElement, holderElement
