class Columns.GitHub extends Columns.FeedColumn
  name: "GitHub"
  width: 1
  thumb: "img/column-github.png"
  link: "https://github.com"

  element: "github-item"
  dataPath: "items"
  dialog: "github-dialog"

  refresh: (columnElement, holderElement) ->
    if typeof @config.period is "undefined" then @config.period = 1

    switch @config.period
      when 0 then period = "month"
      when 1 then period = "week"
      when 2 then period = "day"

    date = new moment
    date.subtract(1, period)
    @url = "https://api.github.com/search/repositories?q=created:>="+date.format("YYYY-MM-DD")+"&sort=stars&order=desc"
    super columnElement, holderElement

tabbie.register "GitHub"