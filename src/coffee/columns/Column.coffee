class Column
  constructor: ->
    @className = @constructor.name

    thmb = document.createElement "img"
    thmb.addEventListener "load", =>
      ct = new ColorThief thmb
      @color = ct.getColor thmb
    thmb.src = "../src/img/" + @thumb

    this

  settings: (cb) ->
    if @dialog
      cdialog = document.getElementById @dialog
      wrap = document.getElementById @dialog + "_wrapper"
      wrap.config = @config
      cdialog.toggle()
      cdialog.querySelector("paper-button[affirmative]").addEventListener "click", =>
        @config = wrap.config
        ui.sync @
        console.info @config
        cdialog.toggle()
        if typeof cb is 'function' then cb(cdialog)
    else if typeof cb is 'function' then cb(cdialog)

  refresh: (columnElement, holderElement) ->


  render: (columnElement, holderElement) ->
    if @flex then holderElement.className = "flex holder"

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
            , 700
#  autoSync = (propName) =>
#    try
#      Object.defineProperty @, propName,
#        get: =>
#          ui.sync @
#          @["_" + propName]
#        set: (val) =>
#          console.log "sync", propName, @
#          ui.sync @
#          @["_" + propName] = val
    catch e
      console.warn(e)
#
#  autoSync "config"
#  autoSync "cache"


  #Internally used for restoring/saving columns (don't touch)
  className: ""

  #Automatically generated based on thumb image (don't touch)
  color: ""

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
#  _config: {}

  #Cache
  cache: []
#  _cache:[]

  loading: true

  #If set to true, this will cause the holder to be a flexbox
  flex: false

  toJSON: ->
    result = {}
    result[key] = @[key] for key of @ when typeof @[key] isnt 'function'
    result
