class Columns.Behance extends Columns.FeedColumn
  name: "Behance"
  width: 2
  thumb: "column-behance.png"

  element: "behance-item"
  dataPath: "projects"

  url: "https://api.behance.net/v2/projects?page={PAGENUM}&api_key=IRZkzuavyQ8XBNihD290wtgt4AlwYo6X"
  flex: true
  infiniteScroll: true

tabbie.register "Behance"