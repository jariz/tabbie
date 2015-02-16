class Columns.Lobsters extends Columns.FeedColumn
  name: "Lobste.rs"
  width: 1
  thumb: "column-lobsters.png"

  url: "https://lobste.rs/hottest.json"
  element: "lobsters-item"
  dialog: "lobsters-dialog"

  refresh: (holderEl, columnEl) =>
    if not @config.listing then @config.listing = 0

    switch @config.listing
      when 0 then listing = "hottest"
      when 1 then listing = "newest"

    @url = "https://lobste.rs/"+listing+".json"
    super holderEl, columnEl

tabbie.register "Lobsters"