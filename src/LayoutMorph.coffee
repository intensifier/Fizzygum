# LayoutMorph

# this comment below is needed to figure our dependencies between classes
# REQUIRES Color
# REQUIRES Point
# REQUIRES Rectangle

# This is a port of the
# respective Cuis Smalltalk classes (version 4.2-1766)
# Cuis is by Juan Vuletich

# A row or column of widgets, does layout by placing
# them either horizontally or vertically.

# Submorphs might specify a LayoutSpec.
# If some don't, then, for a column, the column
# width is taken as the width, and any morph height
# is kept. Same for rows: submorph width would be
# maintained, and submorph height would be made
# equal to row height.

class LayoutMorph extends Morph

	instanceVariableNames: 'direction separation padding'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Layouts'

	direction: ""
	padding: 0
	separation: null # contains a Point
	layoutNeeded: false

	constructor: ->
		super()
		@separation = new Point 0,0
		@updateRendering()
	
	@newColumn: ->
		newLayoutMorph =  new LayoutMorph()
		newLayoutMorph.beColumn()
		return newLayoutMorph

	@newRow: ->
		debugger
		newLayoutMorph =  new LayoutMorph()
		newLayoutMorph.beRow()
		return newLayoutMorph

	beColumn: ->
		@direction = "#vertical"
		@setPadding "#center"

	beRow: ->
		@direction = "#horizontal"
		@setPadding= "#left"

	defaultColor: ->
		return Color.transparent()

	# This sets how extra space is used when doing layout.
	# For example, a column might have extra , unneded
	# vertical space. #top means widgets are set close
	# to the top, and extra space is at bottom. Conversely,
	# #bottom means widgets are set close to the bottom,
	# and extra space is at top. Valid values include
	# #left and #right (for rows) and #center. Alternatively,
	# any number between 0.0 and 1.0 might be used.
	#   self new padding: #center
	#   self new padding: 0.9
	setPadding: (howMuchPadding) ->
		switch howMuchPadding
			when "#top" then @padding = 0.0
			when "#left" then @padding = 0.0
			when "#center" then @padding = 0.5
			when "#right" then @padding = 1.0
			when "#bottom" then @padding = 1.0
			else @padding = howMuchPadding

	setSeparation: (howMuchSeparation) ->
		@separation = howMuchSeparation

	xSeparation: ->
		return @separation.x

	ySeparation: ->
		return @separation.y

	# Compute a new layout based on the given layout bounds
	layoutSubmorphs: ->
		console.log "layoutSubmorphs in LayoutMorph"
		debugger
		if @children.length == 0
			@layoutNeeded = false
			return @

		if @direction == "#horizontal"
			@layoutSubmorphsHorizontallyIn @bounds

		if @direction == "#vertical"
			@layoutSubmorphsVerticallyIn @bounds

		@layoutNeeded = false

	# Compute a new layout based on the given layout bounds.
	layoutSubmorphsHorizontallyIn: (boundsForLayout) ->
		#| xSep ySep usableWidth sumOfFixed normalizationFactor availableForPropWidth widths l usableHeight boundsTop boundsRight t |
		xSep = @xSeparation()
		ySep = @ySeparation()
		usableWidth = boundsForLayout.width() - ((@children.length + 1) * xSep)
		sumOfFixed = 0
		@children.forEach (child) =>
			if child.layoutSpec?
				if child.layoutSpec.fixedWidth?
					sumOfFixed += child.layoutSpec.getFixedWidth()
		availableForPropWidth = usableWidth - sumOfFixed
		normalizationFactor = @proportionalWidthNormalizationFactor()
		availableForPropWidth = availableForPropWidth * normalizationFactor
		widths = []
		sumOfWidths = 0
		@children.forEach (child) =>
			if child.layoutSpec?
				debugger
				theWidth = child.layoutSpec.widthFor availableForPropWidth
				sumOfWidths += theWidth
				widths.push theWidth
		l = ((usableWidth - sumOfWidths) * @padding + Math.max(xSep, 0)) +  boundsForLayout.left()
		usableHeight = boundsForLayout.height() - Math.max(2*ySep,0)
		boundsTop = boundsForLayout.top()
		boundsRight = boundsForLayout.right()
		for i in [@children.length-1 .. 0]
			m = @children[i]
			# major direction
			w = widths[i]
			# minor direction
			ls = m.layoutSpec
			h = Math.min(usableHeight, ls.heightFor(usableHeight))
			t = (usableHeight - h) * ls.minorDirectionPadding + ySep + boundsTop
			# Set bounds and adjust major direction for next step
			# self flag: #jmvVer2.
			# should extent be set in m's coordinate system? what if its scale is not 1?
			m.setPosition(new Point(l,t))
			debugger
			m.setExtent(new Point(Math.min(w,boundsForLayout.width()),h))
			if w>0
				l = Math.min(l + w + xSep, boundsRight)

	# this is the symetric of the previous method
	layoutSubmorphsVerticallyIn: (boundsForLayout) ->
		usableHeight boundsTop boundsRight t |
		xSep = @xSeparation()
		ySep = @ySeparation()
		usableWidth = boundsForLayout.height() - ((@children.length + 1) * ySep)
		sumOfFixed = 0
		@children.forEach (child) =>
			if child.layoutSpec?
				if child.layoutSpec.fixedWidth?
					sumOfFixed += child.layoutSpec.fixedHeight
		availableForPropHeight = usableHeight - sumOfFixed
		normalizationFactor = @proportionalHeightNormalizationFactor
		availableForPropHeight = availableForPropHeight * normalizationFactor
		heights = []
		sumOfHeights = 0
		@children.forEach (child) =>
			if child.layoutSpec?
				theHeight = child.layoutSpec.heightFor availableForPropHeight
				sumOfHeights += theHeight
				heights.push theHeight
		t = ((usableHeight - sumOfHeights) * @padding + Math.max(ySep, 0)) +  boundsForLayout.top()
		usableWidth = boundsForLayout.width() - Math.max(2*xSep,0)
		boundsBottom = boundsForLayout.bottom()
		boundsLeft = boundsForLayout.left()
		for i in [children.length-1 .. 0]
			m = @children[i]
			# major direction
			h = heights[i]
			# minor direction
			ls = m.layoutSpec
			w = Math.min(usableWidth, ls.widthFor(usableWidth))
			l = (usableWidth - w) * ls.minorDirectionPadding() + xSep + boundsLeft
			# Set bounds and adjust major direction for next step
			# self flag: #jmvVer2.
			# should extent be set in m's coordinate system? what if its scale is not 1?
			m.setPosition(new Point(l,t))
			m.setExtent(Math.min(w,boundsForLayout.height()),h)
			if h>0
				t = Math.min(t + h + ySep, boundsBottom)

	# So the user can adjust layout
	addAdjusterMorph: ->
		thickness = 4

		if @direction == "#horizontal"
			@addMorph( new LayoutAdjustingMorph() )
			@layoutSpec = LayoutSpec.fixedWidth(thickness)

		if @direction == "#vertical"
			@addMorph( new LayoutAdjustingMorph() )
			@layoutSpec = LayoutSpec.fixedHeight(thickness)

	#"Add a submorph, at the bottom or right, with aLayoutSpec"
	addMorphWithLayoutSpec: (aMorph, aLayoutSpec) ->
		aMorph.layoutSpec = aLayoutSpec
		@addMorph aMorph

	minPaneHeightForReframe: ->
		return 20

	minPaneWidthForReframe: ->
		return 40

	proportionalHeightNormalizationFactor: ->
		sumOfProportional = 0
		@children.forEach (child) =>
			if child.layoutSpec?
				sumOfProportional += child.layoutSpec.proportionalHeight()
		return 1.0/Math.max(sumOfProportional, 1.0)

	proportionalWidthNormalizationFactor: ->
		sumOfProportional = 0
		@children.forEach (child) =>
			if child.layoutSpec?
				sumOfProportional += child.layoutSpec.getProportionalWidth()
		return 1.0/Math.max(sumOfProportional, 1.0)

	adjustByAt: (aLayoutAdjustMorph, aPoint) ->
		if @direction == "#horizontal"
			@adjustHorizontallyByAt aLayoutAdjustMorph, aPoint

		if @direction == "#vertical"
			@adjustVerticallyByAt aLayoutAdjustMorph, aPoint

	adjustHorizontallyByAt: (aLayoutAdjustMorph, aPoint) ->
		# | delta l ls r rs lNewWidth rNewWidth i lCurrentWidth rCurrentWidth doNotResizeBelow |
		doNotResizeBelow =  @minPaneWidthForReframe
		i = @children[aLayoutAdjustMorph]
		l = @children[i+1]
		ls = l.layoutSpec
		lCurrentWidth = Math.max(l.morphWidth(),1) # avoid division by zero
		r = @children[i - 1]
		rs = r.layoutSpec
		rCurrentWidth = Math.max(r.morphWidth(),1) # avoid division by zero
		delta = aPoint.x - aLayoutAdjustMorph.position().x
		delta = Math.max(delta, doNotResizeBelow - lCurrentWidth)
		delta = Math.min(delta, rCurrentWidth - doNotResizeBelow)
		if delta == 0 then return @
		rNewWidth = rCurrentWidth - delta
		lNewWidth = lCurrentWidth + delta
		if ls.isProportionalWidth() and rs.isProportionalWidth()
			# If both proportional, update them
			ls.setProportionalWidth 1.0 * lNewWidth / lCurrentWidth * ls.proportionalWidth()
			rs.setProportionalWidth 1.0 * rNewWidth / rCurrentWidth * rs.proportionalWidth()
		else
			# If at least one is fixed, update only the fixed
			if !ls.isProportionalWidth()
					ls.fixedOrMorphWidth lNewWidth
			if !rs.isProportionalWidth()
					rs.fixedOrMorphWidth rNewWidth
		@layoutSubmorphs()

	adjustVerticallyByAt: (aLayoutAdjustMorph, aPoint) ->
		# | delta t ts b bs tNewHeight bNewHeight i tCurrentHeight bCurrentHeight doNotResizeBelow |
		doNotResizeBelow = @minPaneHeightForReframe()
		i = @children[aLayoutAdjustMorph]
		t = @children[i+1]
		ts = t.layoutSpec()
		tCurrentHeight = Math.max(t.morphHeight(),1) # avoid division by zero
		b = @children[i - 1]
		bs = b.layoutSpec
		bCurrentHeight = Math.max(b.morphHeight(),1) # avoid division by zero
		delta = aPoint.y - aLayoutAdjustMorph.position().y
		delta = Math.max(delta, doNotResizeBelow - tCurrentHeight)
		delta = Math.min(delta, bCurrentHeight - doNotResizeBelow)
		if delta == 0 then return @
		tNewHeight = tCurrentHeight + delta
		bNewHeight = bCurrentHeight - delta
		if ts.isProportionalHeight() and bs.isProportionalHeight()
			# If both proportional, update them
			ts.setProportionalHeight 1.0 * tNewHeight / tCurrentHeight * ts.proportionalHeight()
			bs.setProportionalHeight 1.0 * bNewHeight / bCurrentHeight * bs.proportionalHeight()
		else
			# If at least one is fixed, update only the fixed
			if !ts.isProportionalHeight()
					ts.fixedOrMorphHeight tNewHeight
			if !bs.isProportionalHeight()
					bs.fixedOrMorphHeight bNewHeight
		@layoutSubmorphs()

	#####################
	# convenience methods
	#####################

	addAdjusterAndMorphFixedHeight: (aMorph,aNumber) ->
		@addAdjusterAndMorphLayoutSpec(aMorph, LayoutSpec.fixedHeight aNumber)

	addAdjusterAndMorphLayoutSpec: (aMorph, aLayoutSpec) ->
		#Add a submorph, at the bottom or right, with aLayoutSpec"
		@addAdjusterMorph()
		@addMorphLayoutSpec(aMorph, aLayoutSpec)

	addAdjusterAndMorphProportionalHeight: (aMorph, aNumber) ->
		@addAdjusterAndMorphLayoutSpec(aMorph, LayoutSpec.proportionalHeight(aNumber))

	addAdjusterAndMorphProportionalWidth: (aMorph, aNumber) ->
		@addAdjusterAndMorphLayoutSpec(aMorph, LayoutSpec.proportionalWidth(aNumber))

	addMorphFixedHeight: (aMorph, aNumber) ->
		@addMorphLayoutSpec(aMorph, LayoutSpec.fixedHeight(aNumber))

	addMorphFixedWidth: (aMorph, aNumber) ->
		@addMorphLayoutSpec(aMorph, LayoutSpec.fixedWidth(aNumber))

	addMorphLayoutSpec: (aMorph, aLayoutSpec) ->
		# Add a submorph, at the bottom or right, with aLayoutSpec
		aMorph.layoutSpec = aLayoutSpec
		@add aMorph

	addMorphProportionalHeight: (aMorph, aNumber) ->
		@addMorphLayoutSpec(aMorph, LayoutSpec.newWithProportionalHeight(aNumber))

	addMorphProportionalWidth: (aMorph, aNumber) ->
		@addMorphLayoutSpec(aMorph, LayoutSpec.newWithProportionalWidth(aNumber))

	addMorphUseAll: (aMorph) ->
		@addMorphLayoutSpec(aMorph, LayoutSpec.useAll())

	addMorphs: (morphs) ->
		morphs.forEach (morph) =>
			@addMorphProportionalWidth(m,1)

	addMorphsWidthProportionalTo: (morphs, widths) ->
		morphs.forEach (morph) =>
			@addMorphProportionalWidth(m,w)

	# unclear how to translate this one for the time being
	is: (aSymbol) ->
	  return aSymbol == "#LayoutMorph" # or [ super is: aSymbol ]