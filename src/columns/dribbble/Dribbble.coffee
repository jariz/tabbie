class Columns.Dribbble extends Columns.FeedColumn
  name: "Dribbble"
  width: 2
  dialog: null
  thumb: "column-dribble.png"

  element: "dribbble-item"
  url: "https://api.dribbble.com/v1/shots?access_token=74f8fb9f92c1f79c4bc3662f708dfdce7cd05c3fc67ac84ae68ff47568b71a1f"
  flex: true

  draw: (data, holderElement) ->
    super data, holderElement

    #this is needed for flex positioning....
    for num in [0..10]
      hack = document.createElement @element
      hack.className = "hack"
      holderElement.appendChild hack

tabbie.register "Dribbble"