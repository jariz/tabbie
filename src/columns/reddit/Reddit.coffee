class Columns.Reddit extends Columns.FeedColumn
  name: "Reddit"
  width: 1
  dialog: "reddit-dialog"
  thumb: "column-reddit.png"

  element: "reddit-item"
  dataPath: "data.children"
  childPath: "data"

  refresh: (columnElement, holderElement) ->
    if not @config.subreddit
      @config =
        listing: 0
        subreddit: "funny"

    switch @config.listing
      when 0 then listing = "hot"
      when 1 then listing = "new"
      when 2 then listing = "top"

    @url = "https://www.reddit.com/r/"+@config.subreddit+"/"+listing+".json"

    super columnElement, holderElement

tabbie.register "Reddit"