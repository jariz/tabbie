class Columns.PushBullet extends Columns.Column
  name: "PushBullet"
  thumb: "column-pushbullet.png"
  dialog: "pushbullet-dialog"
  socket: undefined
  api: undefined
  colEl: undefined
  holEl: undefined

  refresh: (columnElement, holderElement) =>
    @refreshing = true
    @api.user (error, user) =>
      @config.user = user
      tabbie.sync @
      @api.pushHistory (error, history) =>
        @refreshing = false
        user.myself = true
        item.from = user for item in history.pushes when item.direction is 'self'
        @cache = history
        tabbie.sync @
        @draw history, holderElement

  draw: (data, holderElement) =>
    @loading = false
    holderElement.innerHTML = ""
    for item in data.pushes
      if not item.active then continue
      el = document.createElement "pushbullet-item"
      el.item = item
      holderElement.appendChild el

  logOut: () =>
    delete @config.access_token
    delete @config.user
    tabbie.sync @
    @render @colEl, @holEl

  render: (columnElement, holderElement) =>
    super columnElement, holderElement
    @api = window.PushBullet
    @colEl = columnElement
    @holEl = holderElement

    if not @config.access_token
      @loading = false
      @refreshing = false
      auth = document.createElement "pushbullet-auth"
      auth.addEventListener "sign-in", (event) =>
        @config.access_token = event.detail
        tabbie.sync @
        @render columnElement, holderElement
      holderElement.innerHTML = ""
      holderElement.appendChild auth
    else
      @api.APIKey = @config.access_token

      if Object.keys(@cache).length
        @draw @cache, holderElement
      @refresh columnElement, holderElement

      @socket = new WebSocket 'wss://stream.pushbullet.com/websocket/' + @config.access_token
      @socket.onmessage = (e) =>
        data = JSON.parse e.data
        if data.type is "tickle" and data.subtype is "push" then @refresh columnElement, holderElement

tabbie.register "PushBullet"