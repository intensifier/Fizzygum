# FridgeMagnetsMorph //////////////////////////////////////////////////////

class FridgeMagnetsMorph extends WindowMorph
  # this is so we can create objects from the object class name 
  # (for the deserialization process)
  namedClasses[@name] = @prototype

  # panes:
  fridge: null
  codeOutput: null
  magnetsBox: null
  visualOutput: null

  dragTheTilesHereHeader: null
  tilesBinHeader: null
  liveCodeLangOutputHeader: null
  outputAnimationHeader: null


  constructor: ->
    super "Fizzytiles"
  
  buildAndConnectChildren: ->
    if AutomatorRecorderAndPlayer.state != AutomatorRecorderAndPlayer.IDLE and AutomatorRecorderAndPlayer.alignmentOfMorphIDsMechanism
      world.alignIDsOfNextMorphsInSystemTests()

    super
    
    # source code output pane
    @codeOutput = new ScrollFrameMorph()
    @codeOutput.disableDrops()
    @codeOutput.contents.disableDrops()
    @codeOutput.isTextLineWrapping = true
    @codeOutput.color = new Color 255, 255, 255
    sourceCode = new TextMorph ""
    sourceCode.isEditable = true
    sourceCode.enableSelecting()
    sourceCode.setReceiver @target
    @codeOutput.setContents sourceCode, 2
    @add @codeOutput

    # fridge
    @fridge = new FridgeMorph()
    @fridge.sourceCodeHolder = @codeOutput
    @add @fridge

    # magnets box
    @magnetsBox = new FrameMorph()
    @add @magnetsBox

    # visual output
    @visualOutput = new FridgeMagnetsCanvasMorph()
    @visualOutput.disableDrops()
    @add @visualOutput


    # sample magnets -------------------------------
    @scale = new MagnetMorph true, @
    @scale.setLabel "scale"
    @scale.alignCenter()
    @magnetsBox.add @scale

    @rotate = new MagnetMorph true, @
    @rotate.setLabel "rotate"
    @rotate.alignCenter()
    @magnetsBox.add @rotate

    @box = new MagnetMorph true, @
    @box.setLabel "box"
    @box.alignCenter()
    @magnetsBox.add @box

    @move = new MagnetMorph true, @
    @move.setLabel "move"
    @move.alignCenter()
    @magnetsBox.add @move

    # ----------------------------------------------

    # headers --------------------------------------
    @dragTheTilesHereHeader = new StringMorph2 "drag tiles here"
    @dragTheTilesHereHeader.toggleHeaderLine()
    @dragTheTilesHereHeader.alignCenter()
    @add @dragTheTilesHereHeader

    @tilesBinHeader = new StringMorph2 "tiles bin"
    @tilesBinHeader.toggleHeaderLine()
    @tilesBinHeader.alignCenter()
    @add @tilesBinHeader

    @liveCodeLangOutputHeader = new StringMorph2 "LiveCodeLang output"
    @liveCodeLangOutputHeader.toggleHeaderLine()
    @liveCodeLangOutputHeader.alignCenter()
    @add @liveCodeLangOutputHeader

    @outputAnimationHeader = new StringMorph2 "output animation"
    @outputAnimationHeader.toggleHeaderLine()
    @outputAnimationHeader.alignCenter()
    @add @outputAnimationHeader
    # -----------------------------------------------


    # update layout
    @layoutSubmorphs()

  
  layoutSubmorphs: (morphStartingTheChange = null) ->
    super morphStartingTheChange
    console.log "fixing the layout of the inspector"

    # here we are disabling all the broken
    # rectangles. The reason is that all the
    # submorphs of the inspector are within the
    # bounds of the parent Morph. This means that
    # if only the parent morph breaks its rectangle
    # then everything is OK.
    # Also note that if you attach something else to its
    # boundary in a way that sticks out, that's still
    # going to be painted and moved OK.
    trackChanges.push false

    # label
    labelLeft = @left() + @padding
    labelTop = @top() + @padding
    labelRight = @right() - @padding
    labelWidth = labelRight - labelLeft
    labelBottom = labelTop + @label.height() + 2

    classDiagrHeight = Math.floor(@height() / 2)
    eachPaneWidth = Math.floor( (@width() - 4*@padding) / 3) 


    # fridge
    fridgeWidth = eachPaneWidth
    b = @bottom() - (2 * @padding) - WorldMorph.preferencesAndSettings.handleSize
    fridgeHeight = b - labelBottom - classDiagrHeight
    fridgeBottom = labelBottom + fridgeHeight + classDiagrHeight
    fridgeLeft = @fridge.left()

    magnetsBoxLeft = labelLeft + eachPaneWidth + @padding
    magnetsBoxWidth = eachPaneWidth
    magnetsBoxHeight = b - labelBottom - (15 + 2*@padding)

    if @fridge.parent == @
      @fridge.fullRawMoveTo new Point magnetsBoxLeft, labelBottom + 15 + 2*@padding
      @fridge.rawSetExtent new Point eachPaneWidth, fridgeHeight

    if @liveCodeLangOutputHeader.parent == @
      @liveCodeLangOutputHeader.fullRawMoveTo new Point magnetsBoxLeft, @fridge.bottom() + @padding
      @liveCodeLangOutputHeader.rawSetExtent new Point eachPaneWidth, 15

    # codeOutput
    if @codeOutput.parent == @
      @codeOutput.fullRawMoveTo new Point magnetsBoxLeft, labelBottom + classDiagrHeight
      @codeOutput.rawSetExtent new Point fridgeWidth, fridgeHeight

    if @dragTheTilesHereHeader.parent == @
      @dragTheTilesHereHeader.fullRawMoveTo new Point magnetsBoxLeft, @label.bottom() + @padding
      @dragTheTilesHereHeader.rawSetExtent new Point eachPaneWidth, 15

    if @tilesBinHeader.parent == @
      @tilesBinHeader.fullRawMoveTo new Point @left() + @padding, @label.bottom() + @padding
      @tilesBinHeader.rawSetExtent new Point eachPaneWidth, 15

    # magnets box
    detailRight = fridgeLeft + eachPaneWidth
    if @magnetsBox.parent == @
      @magnetsBox.fullRawMoveTo new Point labelLeft, labelBottom + 15 + 2*@padding
      @magnetsBox.rawSetExtent new Point(eachPaneWidth, magnetsBoxHeight).round()

    # visual output
    visualOutputLeft = labelLeft + eachPaneWidth + @padding + eachPaneWidth + @padding
    visualOutputWidth = eachPaneWidth
    visualOutputRight = visualOutputLeft + visualOutputWidth
    if @visualOutput.parent == @
      @visualOutput.fullRawMoveTo new Point visualOutputLeft, labelBottom + 15 + 2*@padding
      @visualOutput.rawSetExtent new Point(eachPaneWidth, magnetsBoxHeight).round()

    if @outputAnimationHeader.parent == @
      @outputAnimationHeader.fullRawMoveTo new Point visualOutputLeft, @label.bottom() + @padding
      @outputAnimationHeader.rawSetExtent new Point eachPaneWidth, 15


    # sample magnets -------------------------------
    if @scale.parent == @magnetsBox
      @scale.fullRawMoveTo new Point @magnetsBox.left() + @padding, @magnetsBox.top() + @padding

    if @rotate.parent == @magnetsBox
      @rotate.fullRawMoveTo new Point @magnetsBox.left() + @padding, @scale.bottom() + @padding

    if @box.parent == @magnetsBox
      @box.fullRawMoveTo new Point @magnetsBox.left() + @padding, @rotate.bottom() + @padding

    if @move.parent == @magnetsBox
      @move.fullRawMoveTo new Point @magnetsBox.left() + @padding, @box.bottom() + @padding

    # ----------------------------------------------


    trackChanges.pop()
    @changed()
    if AutomatorRecorderAndPlayer.state != AutomatorRecorderAndPlayer.IDLE and AutomatorRecorderAndPlayer.alignmentOfMorphIDsMechanism
      world.alignIDsOfNextMorphsInSystemTests()
