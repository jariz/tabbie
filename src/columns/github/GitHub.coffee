class Columns.GitHub extends Columns.Column
  name: "GitHub"
  width: 1
  thumb: "column-github.png"

  draw: (data, holderElement) ->
    @loading = false

    for child in data.items
      card = document.createElement "github-item"
      card.item = child
      holderElement.appendChild card

  refresh: (columnElement, holderElement) ->
    @refreshing = true

    date = new moment()
    date.subtract(1, "month")
    fetch "https://api.github.com/search/repositories?q=created:>="+date.format("YYYY-MM-DD")+"&sort=stars&order=desc"
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
      @refreshing = false

  render: (columnElement, holderElement) ->
    super columnElement, holderElement

    if Object.keys(@cache).length
      @draw @cache, holderElement
      @refresh columnElement, holderElement
    else @refresh columnElement, holderElement

tabbie.register "GitHub"