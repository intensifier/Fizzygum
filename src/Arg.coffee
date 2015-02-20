# an Arg wraps a Val that is an input to the
# calculation of the current Val.
# an Arg for example contains the signature that
# the input val had when the Val was calculated.
# The signature could be a custom signature that is
# only relevant to this Val. So it contains several
# pieces of information about each input val, that are
# specific to the context of this Val (hence, we
# can't put it in the input arg val, we need to
# put this Arg which lives in the context of this
# Val).

# REQUIRES ProfilerData

class Arg
  valWrappedByThisArg: null
  maybeChangedSinceLastCalculation: true
  
  # an argument can either be
  #  1. connected to a parent
  #  2. connected to a child
  #  3. connected to a local value
  # and this is determined when the
  # value that depends on this argument is created.
  # (the parent/child is dynamic, but the nature of
  # the argument is decided early)
  directlyCalculatedFromParent: false
  fromChild: false
  fromLocal: false

  # this flag tracks whether this argument
  # directly or indirectly depends on a parent
  # value. So if @directlyCalculatedFromParent is true
  # then this is true as well. But this could be true
  # even is @directlyCalculatedFromParent is false,
  # because you could have an argument which
  # is connected to a value in a child BUT
  # that value might directly or indirectly
  # depend on a parent value at some stage.
  directlyOrIndirectlyCalculatedFromParent: false
  
  morphContainingThisArg: null
  args: null
  markedForRemoval: false
  # we keep the vals of the args we
  # used to calculate the last val. This is so
  # we can keep an eye on how the args
  # change. If they change back to the original
  # vals we used then we can propagate this
  # "OK our last calculation actually holds"
  # information WITHOUT triggering a recalculation.
  @signatureAtLastCalculation: ""
  @id: ""

  constructor: (@valWrappedByThisArg, @valContainingThisArg) ->
    @morphContainingThisArg = @valContainingThisArg.ownerMorph
    @args = @valContainingThisArg.args
    @id = @valWrappedByThisArg.id
    @args.argById[@id] = @

  fetchVal: () ->
    @valWrappedByThisArg.fetchVal()

  ################################################
  #  signature checking / calculation
  ################################################

  # we give the opportunity to specify a custom signature
  # for args, in case we have a signature that
  # is more efficient considering the type of
  # calculation that we are going to do
  getSignatureOrCustomSignatureOfWrappedVal: () ->
    if @args.customSignatureMethod?
      theValSignature = @args.customSignatureMethod valWrappedByThisArg
    else
      theValSignature = @valWrappedByThisArg.lastCalculatedValContent.signature
      if WorldMorph.preferencesAndSettings.printoutsReactiveValuesCode
        console.log "fetching default signature of argument: " + @id + " : " + theValSignature
    theValSignature = theValSignature + @markedForRemoval

    if WorldMorph.preferencesAndSettings.printoutsReactiveValuesCode
      console.log "calculated signature of argument: " + @id + " : " + theValSignature

    return theValSignature

  semanticallyChangedSinceLastValCalculation: () ->
    if @getSignatureOrCustomSignatureOfWrappedVal() != @signatureAtLastCalculation
      return true
    else
      return false

  # an Argument of this value has notified its change
  # but we want to check, based on either its default
  # signature or a custom signature, wether its
  # value changed from when we calculated this value
  # the last time. Following this check, we might
  # "heal"/break the value and potentially
  # propagate the change
  checkBasedOnSignature: () ->

    if WorldMorph.preferencesAndSettings.printoutsReactiveValuesCode
      console.log "checking signature of argument: " + @id

    # the unique identifier of a val is given by
    # its name as a string and the id of the Morph it
    # belongs to. For localVals this is ever so slightly
    # inneficient as you could always index them through
    # an integer, which would be faster, but probably
    # the improvement would be "in the noise".
    signatureOfArgUsedInLastCalculation =
      @signatureAtLastCalculation
    # this is the case where a child has been added:
    # the arg wasn't there before
    if signatureOfArgUsedInLastCalculation == undefined
      if WorldMorph.preferencesAndSettings.printoutsReactiveValuesCode
        console.log "argument: " + @id + " is undefined, breaking and returning "
      @break()
      return undefined

    # if the arg which has maybe changed doesn't know
    # its val then we just mark the arg as broken
    # and we do nothing else
    if @valWrappedByThisArg.lastCalculatedValContentMaybeOutdated
      if WorldMorph.preferencesAndSettings.printoutsReactiveValuesCode
        console.log "argument: " + @id + " is broken on its own anyways, breaking this arg"
      @break()
    else
      # if the val that asserts change claims that its val
      # is actually correct then we proceed to check its
      # signature to check whether it changed since the
      # last time we calculated our val.
      # We let the user provide her own signature calculation
      # method for args: this is because for the purpose of
      # the calculation of this val, there might be a better
      # notion of equivalency of the args that lets us be
      # more tolerant of changes (which means less invalidation which
      # means less recalculations which means fewer invalidations further
      # on). An example of such "wider" equivalency is for the HSV color
      # values if we need to convert them to RGB. Every HSV value
      # with V set to zero is equivalent in this respect because it
      # always means black.
      if @semanticallyChangedSinceLastValCalculation()
        # argsMaybeChangedSinceLastCalculation is an object, we add
        # a property to it for each dirty arg, so we delete
        # such property when we verify it's actually healthy.
        if WorldMorph.preferencesAndSettings.printoutsReactiveValuesCode
          console.log "argument: " + @id + " has equal signature to one used for last calculation, healing"
        @heal()
      else
        if WorldMorph.preferencesAndSettings.printoutsReactiveValuesCode
          console.log "argument: " + @id + " has different signature to one used for last calculation, breaking"
        @break()


  updateSignature: () ->
    oldSig = @signatureAtLastCalculation
    newSig = @getSignatureOrCustomSignatureOfWrappedVal()
    signatureChanged = false
    if newSig != oldSig
        signatureChanged = true
    @signatureAtLastCalculation = newSig
    if WorldMorph.preferencesAndSettings.printoutsReactiveValuesCode
      if signatureChanged
      	console.log "checked signature of argument: " + @id + " and it changed was: " + oldSig + " now is: " + newSig
      else
      	console.log "checked signature of argument: " + @id + " and it didn't change was: " + oldSig + " now is: " + newSig
    return signatureChanged

  updateSignatureAndHeal: () ->
    signatureChanged = @updateSignature()
    @heal()
    return signatureChanged


  ################################################
  #  breaking / healing
  ################################################

  heal: () ->
    @maybeChangedSinceLastCalculation = false
    delete @args.argsMaybeChangedSinceLastCalculationById[@id]
    @args.countOfDamaged--
    # check implications of argument being healed: it
    # might be that this means that the value heals as
    # well and propagates healing
    if !@valContainingThisArg.directlyOrIndirectlyDependsOnAParentVal
      @valContainingThisArg.checkAndPropagateChangeBasedOnArgChange()

  break: () ->
    @maybeChangedSinceLastCalculation = true
    @args.argsMaybeChangedSinceLastCalculationById[@id] = true
    @args.countOfDamaged++
    # check implications of argument being broken: it
    # might be that this means that the value breaks as
    # well and propagates damage
    if !@valContainingThisArg.directlyOrIndirectlyDependsOnAParentVal
      @valContainingThisArg.checkAndPropagateChangeBasedOnArgChange()


  ################################################
  #  removal
  ################################################

  # we don't completely destroy the argument
  # (lieke removeFromArgs does)
  # for the simple reason that we do need to
  # remember its signature when the value
  # was last calculated.
  markForRemoval: () ->
    @markedForRemoval = true
    @turnIntoArgNotDirectlyNorIndirectlyDependingOnParent()
    @morphContainingThisArg.argMightHaveChanged(valWrappedByThisArg)

  unmarkForRemoval: () ->
    @markedForRemoval = false

  removeArgIfMarkedForRemoval: () ->
    if @markedForRemoval
      @removeFromArgs()
      return true
    else
      return false

  removeFromArgs: () ->
    #@turnIntoArgNotDirectlyNorIndirectlyDependingOnParent()
    delete @args.argById[@id]
    if @args.argsMaybeChangedSinceLastCalculationById[@id]?
      delete @args.argsMaybeChangedSinceLastCalculationById[@id]
      @args.countOfDamaged--



  ################################################
  #  disconnection
  ################################################

  disconnectChildArg: () ->
    @fromChild = false
    delete @args.childrenArgByName[@valContainingThisArg.valName]
    @args.childrenArgByNameCount[@valContainingThisArg.valName]--
    @markForRemoval()

  disconnectParentArg: () ->
    @directlyCalculatedFromParent = false
    @directlyOrIndirectlyCalculatedFromParent = true
    delete @args.parentArgByName[@valContainingThisArg.valName]
    @markForRemoval()

  ################################################
  #  (un)turning into argument
  #  directly or indirectly depending on parent
  ################################################

  turnIntoArgDirectlyOrIndirectlyDependingOnParent: () ->
    @args.calculatedDirectlyOfIndirectlyFromParentById[@valWrappedByThisArg.id] = true
    if !@args.calculatedDirectlyOfIndirectlyFromParentById[@valWrappedByThisArg.id]?
        @args.calculatedDirectlyOfIndirectlyFromParentByIdCount++
    @valContainingThisArg.directlyOrIndirectlyDependsOnAParentVal = true
    @directlyOrIndirectlyCalculatedFromParent = true

    for cv in @valContainingThisArg.localValsAffectedByChangeOfThisVal
      cv.stainValCalculatedFromParent @valContainingThisArg
    if @ownerMorph.parent?
      v = @morphContainingThisArg.parent.morphValsDependingOnChildrenVals[@valName]
      for k in v
        k.stainValCalculatedFromParent @valContainingThisArg



  turnIntoArgNotDirectlyNorIndirectlyDependingOnParent: () ->
    # note that we might turn also an Argument that we know
    # directly depends on a parent. The reason is that
    # we might be removing the parent, in which case
    # this morph might cease to depend on parent values.
    # we need to find out by doing the full works here.

    # this changes @directlyOrIndirectlyDependsOnAParentVal if there are no
    # more args depending on parent vals
    if @args.calculatedDirectlyOfIndirectlyFromParentById[@valWrappedByThisArg.id]?
        @args.calculatedDirectlyOfIndirectlyFromParentByIdCount--
    delete @args.calculatedDirectlyOfIndirectlyFromParentById[@valWrappedByThisArg.id]
    @directlyOrIndirectlyCalculatedFromParent = false

    if @args.calculatedDirectlyOfIndirectlyFromParentByIdCount > 0
      @valContainingThisArg.directlyOrIndirectlyDependsOnAParentVal = false

      # this means that the arg that has unstained itself
      # was the last and only reason why this val was stained
      # so we proceed to unstain ourselves
      for cv in @valContainingThisArg.localValsAffectedByChangeOfThisVal
        cv.unstainValCalculatedFromParent @valContainingThisArg
      if @valContainingThisArg.ownerMorph.parent?
        v = @morphContainingThisArg.parent.morphValsDependingOnChildrenVals[@valContainingThisArg.valName]
        for k in v
          k.unstainValCalculatedFromParent @valContainingThisArg