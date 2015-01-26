class Main
  constructor: () ->
    fb = new Firebase "https://hacker-news.firebaseio.com/";
    fb.child("v0/topstories").on "value", (snapshot) ->

      cards = document.querySelector(".cards");
      cards.innerHTML = ""; #clear card list
      i = -1
      row = null;
      loaderHidden = false;

      createRow = ->
        row = document.createElement("div")
        row.setAttribute("layout", "")
        row.setAttribute("horizontal", "")
        cards.appendChild row

      createRow();

      for id in snapshot.val()
        fb.child("v0/item/#{id}").on "value", (snapshot) ->
          i++
          if i >= 4
            i = 0;
            createRow()

          card = document.createElement "item-card"
          row.appendChild card

          item = snapshot.val()
          card.title = item.title
          card.description = "by #{item.by}, #{item.score} points"

          if(card.style.display != "block") #not visible? do animation
            card.animate([{ opacity: 0 }, { opacity: 1 }], {
              duration: 500,
              direction: "alternate"
            });

          card.style.display = "block"

          if !loaderHidden
            loaderHidden = true
            loader = document.querySelector ".loader"
            loader.animate([{ opacity: 1 }, { opacity: 0 }], {
              duration: 1000,
              direction: "alternate"
            }).onfinish = ->
              loader.style.display = "none"

main = new Main()