class Column
  constructor: ->
    @className = @constructor.name

    thmb = document.createElement "img"
    thmb.addEventListener "load", =>
      ct = new ColorThief thmb
      @color = ct.getColor(thmb)
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
        console.info @config
        cdialog.toggle()
        if typeof cb is 'function' then cb(cdialog)
    else if typeof cb is 'function' then cb(cdialog)

  refresh: (columnElement) ->

  render: (columnElement) ->
    spinner = columnElement.querySelector "html /deep/ paper-spinner"
    Object.defineProperty @, "loading",
      get: -> spinner.active
      set: (val) -> spinner.active = val

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
  config: {},

  #Cache is a helper property that you can use or not.
  cache: []

  loading: true

  toJSON: ->
    result = {}
    result[key] = @[key] for key of @ when typeof @[key] isnt 'function'
    result
