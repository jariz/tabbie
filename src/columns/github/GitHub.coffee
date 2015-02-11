class Columns.GitHub extends Columns.FeedColumn
  name: "GitHub"
  width: 1
  thumb: "column-github.png"

  element: "github-item"
  dataPath: "items"

  refresh: (columnElement, holderElement) ->
    date = new moment
    date.subtract(1, "month")
    @url = "https://api.github.com/search/repositories?q=created:>="+date.format("YYYY-MM-DD")+"&sort=stars&order=desc"
    super columnElement, holderElement

tabbie.register "GitHub"