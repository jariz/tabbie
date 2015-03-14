class Columns.PushBullet extends Columns.Column
  name: "PushBullet"
  thumb: "column-pushbullet.png"
  socket: undefined,
  api: undefined,

  refresh: (columnElement, holderElement) =>
    @api.pushHistory (error, history) =>
      @cache = history
      tabbie.sync @
      @draw history, holderElement

  draw: (data, holderElement) =>
    for item in data
      document.createElement "pushbullet-item"

  render: (columnElement, holderElement) =>
    super columnElement, holderElement
    @api = window.PushBullet

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
        console.log "PB WS received", data
        switch(data.type)
          when "tickle" then if data.subtype is "push" then @refresh columnElement, holderElement

      @socket.onopen = =>
        console.info "PushBullet socket connected :D"
      @socket.onerror = (e) =>
        console.error "PushBullet socket fail " + e.data
      @socket.onclose = =>
        console.error "PushBullet socket closed :("

tabbie.register "PushBullet"