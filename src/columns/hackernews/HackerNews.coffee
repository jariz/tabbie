class Columns.HackerNews extends Columns.FeedColumn
  name: "HackerNews"
  width: 1
  thumb: "column-hackernews.png"

  url: "https://api.pnd.gs/v1/sources/hackerNews/popular"
  element: "hn-item"

tabbie.register "HackerNews"