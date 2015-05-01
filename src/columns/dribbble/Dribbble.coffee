class Columns.Dribbble extends Columns.FeedColumn
  name: "Dribbble"
  width: 2
  thumb: "img/column-dribble.png"
  link: "https://dribbble.com"

  element: "dribbble-item"
  url: "https://api.dribbble.com/v1/shots?page={PAGENUM}&access_token=74f8fb9f92c1f79c4bc3662f708dfdce7cd05c3fc67ac84ae68ff47568b71a1f"

  infiniteScroll: true
  flex: true

tabbie.register "Dribbble"