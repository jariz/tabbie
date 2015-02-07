class Column
  constructor: ->
    @className = @constructor.name

    thmb = document.createElement "img"
    thmb.addEventListener "load", =>
      ct = new ColorThief thmb
      @color = ct.getColor thmb
    thmb.src = "../src/img/" + @thumb

    this

  @cb: false
  @okBound: false
  settings: (cb) ->
    if @dialog
      dialog = document.createElement @dialog
      dialog.config = @config
      document.body.appendChild dialog
      if typeof @cb is 'function' then @cb(@_dialog)
    else if typeof cb is 'function' then cb(@_dialog)
#      wrap = document.getElementById @dialog
#      if not ui.dialogs[@dialog]
#        ui.dialogs[@dialog] = wrap.nextElementSibling
#
#      wrap.config = @config
#      @_dialog.toggle()
#      ok = @_dialog.querySelector("paper-button[affirmative]")
#      @cb = cb
#      if not @okBound
#        @okBound = true
#        ok.addEventListener "click", =>
#          @config = wrap.config
#          ui.sync @
#          console.info @config
#          @_dialog.toggle()

  refresh: (columnElement, holderElement) ->

  editMode: (enable) ->
    toolbar = @columnElement.querySelector "html /deep/ core-toolbar"
    trans = ui.meta.byId "core-transition-center"

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
    if @flex then holderElement.className = "flex holder"

    @columnElement = columnElement

    trans = ui.meta.byId "core-transition-center"
    for editable in @columnElement.querySelectorAll "html /deep/ .editable"
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
        get: -> progress.indeterminate
        set: (val) ->
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
    "id"
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

  #If set to true, this will cause the holder to be a flexbox
  flex: false

  toJSON: ->
    result = {}
    result[key] = @[key] for key of @ when @syncedProperties.indexOf(key) isnt -1
    result
