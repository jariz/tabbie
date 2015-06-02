window.Columns = window.Columns || {}
window.Columns.Column = class Column
  constructor: (properties, dontCalculateColor) ->
    @className = @constructor.name

    if properties then @[key] = properties[key] for key of properties when typeof properties[key] isnt 'function'

    if not dontCalculateColor and not @color
      thmb = document.createElement "img"
      thmb.addEventListener "load", =>
        ct = new ColorThief thmb
        @color = ct.getColor thmb
      thmb.src = @thumb

    if not @config then @config = {}
    if not @cache then @cache = []
    @refreshing = false
    @reloading = true
    @_refreshing = false

  error: (holderElement) ->
    holderElement.setAttribute("hidden", "")
    colEl = holderElement.parentElement;
    error = colEl.querySelector(".error")
    error.removeAttribute("hidden")
    error.offsetTop #re-render hack
    error.style.opacity = 1

  settings: (cb) ->
    if @dialog
      dialog = document.createElement @dialog
      dialog.config = @config
      dialog.column = @
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

  handleHandler = undefined
  editMode: (enable) =>
    trans = tabbie.meta.byId "core-transition-center"
    handle = @columnElement.querySelector "html /deep/ .handle"

    if enable
      getPercentage = (target, width) =>
        if width
          base = document.querySelector(".grid-sizer").clientWidth
          absolute = Math.round((target.style.width.substring(0, target.style.width.length - 2) ) / base)
          final = absolute * 25
          if final is 0 then final = 25
        else
          base = document.querySelector(".grid-sizer").clientHeight
          absolute = Math.round((target.style.height.substring(0, target.style.height.length - 2) ) / base)
          final = absolute * 50
          if final is 0 then final = 50

        if final > 100 then final = 100
        console.info "[getPercentage] width?", width, "base", base, "absolute", absolute, "final", final, "%"
        return final

      preview = document.createElement "div"
      preview.classList.add "resize-preview"
      preview.style.visibility = "hidden"
      document.querySelector(".column-holder").appendChild preview

      #resize logic
      target = @columnElement
      handle.addEventListener "mousedown", @handleHandler = (event) =>
        event.preventDefault()
        target.style.transition = "none"
        startX = event.clientX - target.clientWidth
        startY = event.clientY - target.clientHeight
        mouseUpBound = false
        console.log "startY", startY, "startX", startX
        document.addEventListener "mousemove", msmv = (event) =>
          event.preventDefault()
          newX = event.clientX - startX
          newY = event.clientY - startY

          if preview.style.visibility isnt "visible"
            preview.style.visibility = "visible"
            preview.style.top = target.style.top
            preview.style.left = target.style.left

          preview.style.width = getPercentage(target, true)+"%"
          preview.style.height = getPercentage(target, false)+"%"

          target.style.zIndex = 107
          target.style.width  = newX + 'px'
          target.style.height = newY + 'px'

          if not mouseUpBound
            mouseUpBound = true
            document.addEventListener "mouseup", msp = (event) =>
              event.preventDefault()
              #clean up events
              document.removeEventListener "mousemove", msmv
              document.removeEventListener "mouseup", msp

              target.style.transition = "width 250ms, height 250ms"
              widthPerc = getPercentage target, true
              heightPerc = getPercentage target, false
              target.style.width = widthPerc + "%"
              target.style.height = heightPerc + "%"
              @width = widthPerc / 25
              @height = heightPerc / 50
              preview.style.visibility = "hidden"
              tabbie.sync @
              target.addEventListener "webkitTransitionEnd", trnstn = ->
                target.removeEventListener "webkitTransitionEnd", trnstn
                target.style.zIndex = 1
                tabbie.packery.layout()

      handle.style.visibility = "visible"
      @draggie.enable()
      @columnElement.classList.add "draggable"
      for editable in @editables
        editable.removeAttribute "hidden"
        editable.offsetTop #hack that forces re-render

        trans.go editable,
          opened: true
    else
      if @handleHandler then handle.removeEventListener "mousedown", @handleHandler
      handle.style.visibility = "hidden"
      @draggie.disable()
      @columnElement.classList.remove "draggable"
      for editable in @editables
        trans.go editable,
          opened: false

        trans.listenOnce editable, trans.completeEventName, (e) ->
          e.setAttribute "hidden", ""
        , [editable]

  render: (columnElement, holderElement) ->
    if @flex then holderElement.classList.add "flex"
    else holderElement.classList.remove "flex"

    @columnElement = columnElement

    trans = tabbie.meta.byId "core-transition-center"
    for editable in @columnElement.querySelectorAll "html /deep/ .editable"
      if not @dialog and editable.classList.contains "settings" then continue
      trans.setup editable
      @editables.push editable

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
    "color",
    "width",
    "height",
    "name",
    "url",
    "baseUrl",
    "link",
    "thumb",
    "custom"
  ]

  #Column name
  name: "Empty column"

  #Column grid width (width * 25%)
  width: 1

  #Column grid height (height * 50%)
  height: 1

  #Configuration dialog ID
  dialog: null

  #Thumbnail image path
  thumb: "img/column-unknown.png"

  #Configurations trough dialogs etc get saved in here
  config: {}

  #Cache
  cache: []

  loading: true
  refreshing: false

  #If set to true, this will cause the holder to be a flexbox
  flex: false

  #whether to hande column as a custom column or not
  custom: false

  toJSON: ->
    result = {}
    result[key] = @[key] for key of @ when @syncedProperties.indexOf(key) isnt -1
    result
