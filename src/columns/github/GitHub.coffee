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

    if typeof @config.language is "undefined" then @config.language = 0

    switch @config.language
      when 0 then language = ""
      when 1 then language = "+language:CSS"
      when 2 then language = "+language:HTML"
      when 3 then language = "+language:Java"
      when 4 then language = "+language:JavaScript"
      when 5 then language = "+language:PHP"
      when 6 then language = "+language:Python"
      when 7 then language = "+language:Ruby"


    date = new moment
    date.subtract(1, period)
    @url = "https://api.github.com/search/repositories?q=created:>="+date.format("YYYY-MM-DD")+language+"&sort=stars&order=desc"
    super columnElement, holderElement

tabbie.register "GitHub"