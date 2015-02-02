class Column
   constructor: ->
     @className = @constructor.name
     this

   className: "" #Internally used for restoring/saving columns
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
