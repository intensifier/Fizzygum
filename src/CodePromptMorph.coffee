# CodePromptMorph ///////////////////////////////////////////////////

class CodePromptMorph extends Widget

  tempPromptEntryField: nil
  defaultContents: ""
  textMorph: nil

  cancelButton: nil
  saveButton: nil
  okButton: nil
  saveTextWdgt: nil

  # the external padding is the space between the edges
  # of the container and all of its internals. The reason
  # you often set this to zero is because windows already put
  # contents inside themselves with a little padding, so this
  # external padding is not needed. Useful to keep it
  # separate and know that it's working though.
  externalPadding: 0
  # the internal padding is the space between the internal
  # components. It doesn't necessarily need to be equal to the
  # external padding
  internalPadding: 5

  constructor: (@msg, @target, @callback, @defaultContents) ->
    super new Point 200,400
    @buildAndConnectChildren()

  colloquialName: ->
    "Edit tool code"

  buildAndConnectChildren: ->
    debugger
    if AutomatorRecorderAndPlayer? and AutomatorRecorderAndPlayer.state != AutomatorRecorderAndPlayer.IDLE and AutomatorRecorderAndPlayer.alignmentOfMorphIDsMechanism
      world.alignIDsOfNextMorphsInSystemTests()

    @tempPromptEntryField = new SimplePlainTextScrollPanelWdgt @defaultContents, false, 5
    @tempPromptEntryField.disableDrops()
    @tempPromptEntryField.contents.disableDrops()
    @tempPromptEntryField.color = new Color 255, 255, 255
    @tempPromptEntryField.addModifiedContentIndicator()

    # register this wdgt as one to be notified when the text
    # changes/unchanges from "reference" content
    # so we can enable/disable the "save" button
    @tempPromptEntryField.widgetToBeNotifiedOfTextModificationChange = @

    @textMorph = @tempPromptEntryField.textWdgt
    @textMorph.backgroundColor = new Color 0,0,0,0
    @textMorph.setFontName nil, nil, @textMorph.monoFontStack
    @textMorph.isEditable = true
    @textMorph.enableSelecting()

    @add @tempPromptEntryField

    # buttons -------------------------------
    @cancelButton = new SimpleButtonMorph true, @, "close", (new StringMorph2 "cancel").alignCenter()
    @add @cancelButton

    
    @saveTextWdgt = new StringMorph2 "save"
    @saveTextWdgt.alignCenter()
    @saveButton = new SimpleButtonMorph true, @, "informTarget", @saveTextWdgt
    @add @saveButton

    @okButton = new SimpleButtonMorph true, @, "notifyTargetAndClose", (new StringMorph2 "ok").alignCenter()
    @add @okButton
    # ---------------------------------------

    # now that we added the buttons there is a "save" button
    # to disable (because the reference text has not been
    # changed yet), so trigger the content check now
    @tempPromptEntryField.checkIfTextContentWasModifiedFromTextAtStart()

    @invalidateLayout()

  textContentModified: ->
    debugger
    @saveTextWdgt.setColor new Color 0,0,0

  textContentUnmodified: ->
    debugger
    @saveTextWdgt.setColor new Color 200, 200, 200


  informTarget: ->
    @target[@callback].call @target, nil, @textMorph
    @textMorph.considerCurrentTextAsReferenceText()
    @tempPromptEntryField.checkIfTextContentWasModifiedFromTextAtStart()

  notifyTargetAndClose: ->
    @informTarget()
    @close()

  doLayout: (newBoundsForThisLayout) ->
    if !window.recalculatingLayouts
      debugger

    if @isCollapsed()
      @layoutIsValid = true
      @notifyChildrenThatParentHasReLayouted()
      return

    super
    debugger

    # here we are disabling all the broken
    # rectangles. The reason is that all the
    # submorphs of the inspector are within the
    # bounds of the parent Widget. This means that
    # if only the parent morph breaks its rectangle
    # then everything is OK.
    # Also note that if you attach something else to its
    # boundary in a way that sticks out, that's still
    # going to be painted and moved OK.
    trackChanges.push false

    textHeight = @height() - 2 * @externalPadding - @internalPadding - 15
    textBottom = @top() + @externalPadding + textHeight

    if @tempPromptEntryField.parent == @
      @tempPromptEntryField.fullRawMoveTo new Point @left() + @externalPadding, @top() + @externalPadding
      @tempPromptEntryField.rawSetExtent new Point @width() - 2 * @externalPadding, textHeight


    # buttons -------------------------------
    

    eachButtonWidth = (@width() - 2 * @externalPadding - 3 * @internalPadding - WorldMorph.preferencesAndSettings.handleSize) / 3

    if @cancelButton.parent == @
      buttonBounds = new Rectangle new Point @left() + @externalPadding + 0*(eachButtonWidth + @internalPadding), textBottom + @internalPadding
      buttonBounds = buttonBounds.setBoundsWidthAndHeight eachButtonWidth, 15
      @cancelButton.doLayout buttonBounds 

    if @saveButton.parent == @
      buttonBounds = new Rectangle new Point @left() + @externalPadding + 1*(eachButtonWidth + @internalPadding), textBottom + @internalPadding
      buttonBounds = buttonBounds.setBoundsWidthAndHeight eachButtonWidth, 15
      @saveButton.doLayout buttonBounds 

    if @okButton.parent == @
      buttonBounds = new Rectangle new Point @left() + @externalPadding + 2*(eachButtonWidth + @internalPadding), textBottom + @internalPadding
      buttonBounds = buttonBounds.setBoundsWidthAndHeight eachButtonWidth, 15
      @okButton.doLayout buttonBounds 

    # ----------------------------------------------


    trackChanges.pop()
    @fullChanged()
    if AutomatorRecorderAndPlayer? and AutomatorRecorderAndPlayer.state != AutomatorRecorderAndPlayer.IDLE and AutomatorRecorderAndPlayer.alignmentOfMorphIDsMechanism
      world.alignIDsOfNextMorphsInSystemTests()

    @layoutIsValid = true
    @notifyChildrenThatParentHasReLayouted()
