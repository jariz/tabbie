class Column
   constructor: ->
     return this

   name: "Empty column" #Dialog name
   width: 1 #Dialog grid width (width * 20%)
   dialog: null #Configuration dialog ID
   thumb: "column-unknown.png"
   config: {}

   render: (columnElement) ->
