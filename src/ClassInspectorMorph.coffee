# ClassInspectorMorph //////////////////////////////////////////////////////

class ClassInspectorMorph extends InspectorMorph2
  # this is so we can create objects from the object class name 
  # (for the deserialization process)
  namedClasses[@name] = @prototype

  notifyInstancesOfSourceChange: (propertiesArray)->
    @target.constructor.class.notifyInstancesOfSourceChange propertiesArray

  buildAndConnectChildren: ->
    super
    @lastLabelInHierarchy.setText "this class"
    @label.setText "class " + @target.constructor.name   

  layoutOwnPropsOnlyToggle: (height) ->

    @showMethodsToggle.fullRawMoveTo new Point @left()+@padding , height
    @showMethodsToggle.rawSetExtent new Point (@width() - 4*@padding)/4,15

    @showFieldsToggle.fullRawMoveTo new Point @showMethodsToggle.right() + @padding, height
    @showFieldsToggle.rawSetExtent new Point (@width() - 4*@padding)/4,15

    @showInheritedToggle.fullRawMoveTo new Point @showFieldsToggle.right() + @padding, height
    @showInheritedToggle.rawSetExtent new Point 2*(@width() - 4*@padding)/4,15



  buildAndConnectObjOwnPropsButton: ->

  # TODO: when inspecting objects, we added the functionality to
  # inject code in the objects themselves.
  # We'd have to do the same here, add a way to inject code in
  # object classes.
  save: ->
    txt = @detail.contents.children[0].text.toString()
    propertyName = @list.selected.labelString

    try
      # this.target[propertyName] = evaluate txt
      @target.evaluateString "@" + propertyName + " = " + txt
      # if we are saving a function, we'd like to
      # keep the source code so we can edit Coffeescript
      # again.
      if isFunction @target[propertyName]
        @target[propertyName + "_source"] = txt
      @notifyInstancesOfSourceChange([propertyName])
    catch err
      @inform err
