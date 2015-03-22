class Columns.Reddit extends Columns.FeedColumn
  name: "Reddit"
  width: 1
  dialog: "reddit-dialog"
  thumb: "column-reddit.png"

  element: "reddit-item"
  dataPath: "data.children"
  childPath: "data"

  refresh: (columnElement, holderElement) =>
    @refreshing = true

    if not @config.subreddit
      @config =
        listing: 0
        subreddit: "funny"
        option: "subreddit",
        multireddit: "empw/m/electronicmusic"

    console.info "config.option", @config.option
    switch @config.option
      when "subreddit"
        switch @config.listing
          when 0 then listing = "hot"
          when 1 then listing = "new"
          when 2 then listing = "top"

        @url = "https://www.reddit.com/r/"+@config.subreddit+"/"+listing+".json"
        super columnElement, holderElement
      when "multireddit"
        @url = "https://www.reddit.com/user/"+@config.multireddit+".json"
        super columnElement, holderElement
      when "frontpage"
        fetch "https://oauth.reddit.com/.json",
          headers:
            "Authorization": "bearer "+@config.access_token
            "Accept": "application/json"
        .then (response) =>
          if response.status is 200
            Promise.resolve response.json()
          else Promise.reject new Error response.statusText
        .then (data) =>
          @refreshing = false
          @cache = data
          tabbie.sync @
          holderElement.innerHTML = ""
          @draw data, holderElement
        .catch (error) =>
          console.error error
          @refreshing = false
          @loading = false
      else console.error "Reddit column: Invalid config.option ???"


  login: =>
    chrome.permissions.request
      origins: ['https://oauth.reddit.com/']
    , (granted) =>
      if granted
        chrome.identity.launchWebAuthFlow
          url: "https://www.reddit.com/api/v1/authorize?client_id=qr6drw45JFCXfw&response_type=code&state=hellothisisaeasteregg&redirect_uri=https%3A%2F%2Fkckhddfnffeofnfjcpdffpeiljicclbd.chromiumapp.org%2Freddit&duration=permanent&scope=read"
          interactive: true,
        , (redirect_url) =>
            if redirect_url
              code = /code=([a-zA-Z0-9_\-]*)/.exec(redirect_url)[1]
              fetch "https://www.reddit.com/api/v1/access_token",
                method: "post"
                headers:
                  "Content-Type": "application/x-www-form-urlencoded",
                  "Authorization": "Basic "+btoa("qr6drw45JFCXfw:")
                body: "grant_type=authorization_code&code="+code+"&redirect_uri=https%3A%2F%2Fkckhddfnffeofnfjcpdffpeiljicclbd.chromiumapp.org%2Freddit"
              .then (response) =>
                if response.status is 200 then Promise.resolve response.json()
                else Promise.reject new Error response.statusText
              .then (data) =>
                @config.access_token = data.access_token
                tabbie.sync @
              .catch (e) =>
                console.error(e)

  logout: =>
    delete @config.access_token
    tabbie.sync @

tabbie.register "Reddit"