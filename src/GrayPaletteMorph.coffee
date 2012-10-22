# GrayPaletteMorph ///////////////////////////////////////////////////

class GrayPaletteMorph extends ColorPaletteMorph
  constructor: (@target = null, @sizePoint = new Point(80, 10)) ->
    super @target, @sizePoint
  
  drawNew: ->
    ext = @extent()
    @image = newCanvas(@extent())
    context = @image.getContext("2d")
    @choice = new Color()
    gradient = context.createLinearGradient(0, 0, ext.x, ext.y)
    gradient.addColorStop 0, "black"
    gradient.addColorStop 1, "white"
    context.fillStyle = gradient
    context.fillRect 0, 0, ext.x, ext.y
