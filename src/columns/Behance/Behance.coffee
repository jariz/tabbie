class Columns.Behance extends Columns.FeedColumn
  name: "Behance"
  width: 2
  dialog: null
  thumb: "column-behance.png"

  element: "behance-item"
  dataPath: "projects"
  url: "https://api.behance.net/v2/projects?api_key=IRZkzuavyQ8XBNihD290wtgt4AlwYo6X"
  flex: true

  draw: (data, holderElement) ->
    super data, holderElement

    #this is needed for flex positioning....
    for num in [0..10]
      hack = document.createElement @element
      hack.className = "hack"
      holderElement.appendChild hack

tabbie.register "Behance"