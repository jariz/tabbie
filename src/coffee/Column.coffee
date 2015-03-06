window.Columns = window.Columns || {}
window.Columns.Column = class Column
  constructor: (properties) ->
    @className = @constructor.name

    if properties then @[key] = properties[key] for key of properties when typeof properties[key] isnt 'function'

    if not @color
      thmb = document.createElement "img"
      thmb.addEventListener "load", =>
        ct = new ColorThief thmb
        @color = ct.getColor thmb
      thmb.src = "img/" + @thumb

    if not @config then @config = {}
    if not @cache then @cache = []
    @refreshing = false
    @reloading = true
    @_refreshing = false

  settings: (cb) ->
    if @dialog
      dialog = document.createElement @dialog
      dialog.config = @config
      document.body.appendChild dialog
      #warning, nasty code ahead
      _d = null
      dialog.toggle = ->
        if not _d then _d = this.shadowRoot.querySelector "tabbie-dialog"
        _d.toggle()
      dialog.toggle()
      dialog.shadowRoot.querySelector("tabbie-dialog").shadowRoot.querySelector("paper-button.ok").addEventListener "click", ->
        @config = dialog.config
        tabbie.sync @
        dialog.toggle()
        if typeof cb is 'function' then cb dialog
    else if typeof cb is 'function' then cb dialog

  refresh: (columnElement, holderElement) ->

  attemptAdd: (successCallback) ->
    if typeof successCallback is 'function' then successCallback()

  editMode: (enable) ->
    toolbar = @columnElement.querySelector "html /deep/ core-toolbar"
    trans = tabbie.meta.byId "core-transition-center"

    if enable
      @draggie.enable()
      toolbar.classList.add "draggable"
      for editable in @editables
        trans.go editable,
          opened: true
    else
      @draggie.disable()
      toolbar.classList.remove "draggable"
      for editable in @editables
        trans.go editable,
          opened: false


  render: (columnElement, holderElement) ->
    if @flex then holderElement.classList.add "flex"

    @columnElement = columnElement

    trans = tabbie.meta.byId "core-transition-center"
    for editable in @columnElement.querySelectorAll "html /deep/ .editable"
      if not @dialog and editable.classList.contains "settings" then continue
      trans.setup editable
      @editables.push editable
      editable.removeAttribute "hidden"

    spinner = columnElement.querySelector "html /deep/ paper-spinner"
    progress = columnElement.querySelector "html /deep/ paper-progress"

    try
      Object.defineProperty @, "loading",
        get: -> spinner.active
        set: (val) -> spinner.active = val

      timeout = false
      Object.defineProperty @, "refreshing",
        get: -> @_refreshing
        set: (val) ->
          @_refreshing = false
          if val
            progress.style.opacity = 1
          else
            if timeout then clearTimeout timeout
            timeout = setTimeout ->
              progress.style.opacity = 0
            , 400
    catch e
      console.warn(e)

  #Internally used for restoring/saving columns (don't touch)
  className: ""

  #Automatically generated based on thumb image (don't touch)
  color: ""

  #more internal shiz
  columnElement: null
  editables: []
  draggie: null

  #Internally used to determine which properties to keep when saving
  syncedProperties:[
    "cache",
    "config",
    "className",
    "id",
    "color"
  ]

  #Dialog name
  name: "Empty column"

  #Dialog grid width (width * 25%)
  width: 1

  #Configuration dialog ID
  dialog: null

  #Thumbnail image path
  thumb: "column-unknown.png"

  #Configurations trough dialogs etc get saved in here
  config: {}

  #Cache
  cache: []

  loading: true
  refreshing: false

  #If set to true, this will cause the holder to be a flexbox
  flex: false

  toJSON: ->
    result = {}
    result[key] = @[key] for key of @ when @syncedProperties.indexOf(key) isnt -1
    result
