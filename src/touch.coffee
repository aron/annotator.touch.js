Annotator.Plugin.Touch = class Touch extends Annotator.Plugin

  @states: ON: "on", OFF: "off"

  template: """
  <div class="annotator-touch-widget annotator-touch-controls annotator-touch-hide">
    <div class="annotator-touch-widget-inner">
      <a class="annotator-button annotator-add annotator-focus">Annotate</a>
      <a class="annotator-button annotator-touch-toggle" data-state="off">Start Annotating</a>
    </div>
  </div>
  """

  classes:
    hide: "annotator-touch-hide"

  options:
    force: false
    useHighlighter: false

  constructor: (element, options) ->
    super

    @utils = Annotator.Plugin.Touch.utils
    @selection = null
    @document = jQuery(document)

  pluginInit: ->
    return unless @options.force or @isTouchDevice()

    @_setupControls()

    # Only need this for some Android browsers at the moment. The simulator
    # fails to select the highlights but the Galaxy Tab running 3.2 works
    # okay.
    if @options.useHighlighter
      @showControls()
      @highlighter = new Highlighter
        root:   @element[0]
        prefix: "annotator-selection"
        enable: false
        highlightStyles: true

    @editor = new Touch.Editor(@annotator.editor)

    # Unbind mouse events from the root element to prevent the iPad giving
    # it a grey selected outline when interacted with.
    @element.unbind("click mousedown mouseover mouseout")
    @element.delegate ".annotator-hl", "tap", (event) =>
      original = event.originalEvent
      if original and original.touches
        event.pageX = original.touches[0].pageX
        event.pageY = original.touches[0].pageY
      @annotator.onHighlightMouseover(event)

    @annotator.adder.remove()
    @annotator.editor.on "hide", @_watchForSelection

    @on "selection", @_onSelection
    @_watchForSelection()

  pluginDestroy: ->
    @adder.remove() if @adder
    @highlighter.disable() if @highlighter
    @annotator.editor.unsubscribe "hide", @_watchForSelection if @annotator

  startAnnotating: ->
    @highlighter.enable() if @highlighter
    @toggle.attr("data-state", Touch.states.ON)
    @toggle.html("Stop Annotating")

  stopAnnotating: ->
    @highlighter.disable() if @highlighter
    @toggle.attr("data-state", Touch.states.OFF)
    @toggle.html("Start Annotating")

  isAnnotating: ->
    usingHighlighter = @options.useHighlighter
    not usingHighlighter or @toggle.attr("data-state") is Touch.states.ON

  showControls: ->
    @controls.removeClass(@classes.hide)

  hideControls: ->
    @controls.addClass(@classes.hide) unless @options.useHighlighter

  _setupControls: ->
    @controls = jQuery(@template).appendTo("body")

    @adder = @controls.find(".annotator-add")
    @adder.bind(tap: @_onAdderTap)

    @toggle = @controls.find(".annotator-touch-toggle")
    @toggle.bind("tap": @_onToggleTap)
    @toggle.hide() unless @options.useHighlighter

  _watchForSelection: =>
    return if @timer

    start = new Date().getTime()
    step = =>
      progress = (new Date().getTime()) - start
      if progress > 1000 / 60
        start = new Date().getTime()
        @_checkSelection() 
      @timer = @utils.requestAnimationFrame.call(window, step)
    @timer = @utils.requestAnimationFrame.call(window, step)

  _clearWatchForSelection: ->
    @utils.cancelAnimationFrame.call(window, @timer)
    @timer = null

  _checkSelection: ->
    selection = window.getSelection()
    previous  = @selectionString
    string    = jQuery.trim(selection + "")

    if selection.rangeCount and string isnt @selectionString
      @range = selection.getRangeAt(0)
      @selectionString = string
    
    if selection.rangeCount is 0 or (@range and @range.collapsed)
      @range = null
      @selectionString = ""

    @publish("selection", [@range]) unless @selectionString is previous

  _onSelection: =>
    if @isAnnotating() and @range
      @adder.removeAttr("disabled")
      @showControls()
    else
      @adder.attr("disabled", "")
      @hideControls()

  _onToggleTap: (event) =>
    event.preventDefault()
    if @isAnnotating() then @stopAnnotating() else @startAnnotating()

  _onAdderTap: (event) =>
    event.preventDefault()
    if @range
      @_clearWatchForSelection()
      browserRange = new Annotator.Range.BrowserRange(@range)
      range = browserRange.normalize().limit(@element[0])

      if browserRange
        annotation = @annotator.createAnnotation()
        annotation.quote = @range.toString()

        @annotator.ignoreMouseup = true
        @annotator.selectedRanges = [range]
        @annotator.showEditor(annotation, top: 0, left: 0)
        @hideControls()

  isTouchDevice: ->
    ('ontouchstart' of window) or window.DocumentTouch and document instanceof DocumentTouch
