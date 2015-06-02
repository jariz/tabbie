class Columns.ProductHunt extends Columns.FeedColumn
  name: "ProductHunt"
  thumb: "img/column-producthunt.png"
  element: "ph-item"
  dataPath: "posts"
  link: "https://www.producthunt.com"
  dialog: "ph-dialog"
  width: 1

  attemptAdd: (successCallback) ->
    chrome.permissions.request
      origins: ['https://api.producthunt.com/']
    , (granted) =>
        if granted and typeof successCallback is 'function' then successCallback()

  draw: (data, holderElement) ->
    if not @config.type then @config.type = "list"
    @element = if @config.type == "list" then "ph-item" else "ph-thumb"
    @flex = @element == "ph-thumb"

    data.posts = data.posts.map (item, index) -> item.index = index + 1; item

    super data, holderElement

  refresh: (columnElement, holderElement) =>
    #producthunt api requires a request for a access token
    #when we've got access token, we can go on as usual

    fetch "https://api.producthunt.com/v1/oauth/token",
      method: "post",
      headers:
        "Accept": "application/json"
        "Content-Type": "application/json"
      body: JSON.stringify
        client_id: "6c7ae468245e828676be999f5a42e6e50e0101ca99480c4eefbeb981d56f310d",
        client_secret: "00825be2da634a7d80bc4dc8d3cbdd54bcaa46d4273101227c27dbd68accdb77",
        grant_type: "client_credentials"
    .then (response) ->
      if response.status is 200 then Promise.resolve response
      else Promise.reject new Error response.statusText
    .then (response) ->
      return response.json()
    .then (json) =>
      @url = "https://api.producthunt.com/v1/posts?access_token="+json.access_token
      super columnElement, holderElement
    .catch (error) =>
      console.error error
      @refreshing = false
      @loading = false

      if not @cache or @cache.length is 0 then @error holderElement


tabbie.register "ProductHunt"