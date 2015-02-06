class Dribbble extends Column
  name: "Dribbble"
  width: 2
  dialog: null
  thumb: "column-dribble.png"

  access_token: "74f8fb9f92c1f79c4bc3662f708dfdce7cd05c3fc67ac84ae68ff47568b71a1f"
  flex: true

  draw: (data, holderElement) ->
    @loading = false

    for child in data
      card = document.createElement "dribbble-item"
      card.item = child
      holderElement.appendChild card

    #this is needed for flex positioning....
    for num in [0..10]
      hack = document.createElement "dribbble-item"
      hack.className = "hack"
      holderElement.appendChild hack

  refresh: (columnElement, holderElement) ->
    @refreshing = true

    fetch("https://api.dribbble.com/v1/shots?access_token=" + @access_token)
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

    holderElement.addEventListener "scroll", =>

    if Object.keys(@cache).length
      @draw @cache, holderElement
      @refresh columnElement, holderElement
    else @refresh columnElement, holderElement
