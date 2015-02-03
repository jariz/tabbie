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


  className: "" #Internally used for restoring/saving columns
  color: "" #automatically generated based on thumb image

  name: "Empty column" #Dialog name
  width: 1 #Dialog grid width (width * 20%)
  dialog: null #Configuration dialog ID
  thumb: "column-unknown.png"
  config: {},

  toJSON: ->
    result = {}
    result[key] = @[key] for key of @ when typeof @[key] isnt 'function'
    result

  render: (columnElement) ->
