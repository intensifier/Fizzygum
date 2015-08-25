# LayoutAdjustingMorph

# this Morph must be attached to a LayoutMorph
# because it relies on LayoutMorph's adjustHorizontallyByAt
# and adjustVerticallyByAt to adjust the layout

# This is a port of the
# respective Cuis Smalltalk classes (version 4.2-1766)
# Cuis is by Juan Vuletich


class LayoutAdjustingMorph extends RectangleMorph
  # this is so we can create objects from the object class name 
  # (for the deserialization process)
  namedClasses[@name] = @prototype

  hand: null
  indicator: null

  constructor: ->
    super()
    @isfloatDraggable = false
    @noticesTransparentClick = true

  # HandleMorph floatDragging and dropping:
  rootForGrab: ->
    @

  @includeInNewMorphMenu: ->
    # Return true for all classes that can be instantiated from the menu
    return false

  nonFloatDragging: (nonFloatDragPositionWithinMorphAtStart, pos, delta) ->
    console.log "layout adjuster being moved!"
    newPos = pos.subtract nonFloatDragPositionWithinMorphAtStart
    @parent.adjustByAt @, newPos

  #SliderButtonMorph events:
  mouseEnter: ->
    if @parent.direction == "#horizontal"
      document.getElementById("world").style.cursor = "col-resize"
    else if @parent.direction == "#vertical"
      document.getElementById("world").style.cursor = "row-resize"
  
  mouseLeave: ->
    document.getElementById("world").style.cursor = "auto"

  ###
  adoptWidgetsColor: (paneColor) ->
    super adoptWidgetsColor paneColor
    @color = paneColord

  cursor: ->
    if @owner.direction == "#horizontal"
      Cursor.resizeLeft()
    else
      Cursor.resizeTop()
  ###
