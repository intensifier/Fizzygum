# this comment below is needed to figure out dependencies between classes
# REQUIRES globalFunctions

class SimpleVerticalStackScrollPanelWdgt extends ScrollPanelWdgt

  constructor: (@isTextLineWrapping = true) ->
    VS = new SimpleVerticalStackPanelWdgt()

    if !@isTextLineWrapping
      VS.constrainContentWidth = false

    VS.tight = false
    VS.isLockingToPanels = true
    super VS
    @disableDrops()

    ostmA = new SimplePlainTextWdgt(
      "A small string\n\n\nhere another.",nil,nil,nil,nil,nil,(new Color 240, 240, 240), 1)
    ostmA.isEditable = true
    ostmA.enableSelecting()
    @setContents ostmA, 5
    @setColor new Color 249, 249, 249

  colloquialName: ->
    "stack"

  addMorphSpecificMenuEntries: (morphOpeningThePopUp, menu) ->
    super
    menu.removeMenuItem "move all inside"

    childrenNotHandlesNorCarets = @contents?.children.filter (m) ->
      !((m instanceof HandleMorph) or (m instanceof CaretMorph))

    if childrenNotHandlesNorCarets? and childrenNotHandlesNorCarets.length > 0
      menu.addLine()
      if @allSubMorphsAreLocked()
        menu.addMenuItem "unlock content", true, @, "unlockAllChildren", "lets you drag content in and out"
      else
        menu.addMenuItem "lock content", true, @, "lockAllChildren", "prevents dragging content in and out"

    menu.removeConsecutiveLines()
