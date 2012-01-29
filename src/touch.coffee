Annotator.Plugin.Touch = class Touch extends Annotator.Plugin
  _t = Annotator._t
  jQuery = Annotator.$

  @states: ON: "on", OFF: "off"

  template: """
  <div class="annotator-touch-widget annotator-touch-controls annotator-touch-hide">
    <div class="annotator-touch-widget-inner">
      <a class="annotator-button annotator-add annotator-focus">""" + _t("Annotate") + """</a>
      <a class="annotator-button annotator-touch-toggle" data-state="off">""" + _t("Start Annotating") + """</a>
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
    @viewer = new Touch.Viewer(@annotator.viewer)

    # Unbind mouse events from the root element to prevent the iPad giving
    # it a grey selected outline when interacted with.
    @element.unbind("click mousedown mouseover mouseout")

    # Bind tap event listeners to the highlight elements. We delegate to the
    # document rather than the container to prevent WebKit requiring a
    # double tap to bring up the text selection tool.
    jQuery(document).delegate ".annotator-hl", "tap", (event) =>
      if @element.has(event.currentTarget)
        original = event.originalEvent
        if original and original.touches
          event.pageX = original.touches[0].pageX
          event.pageY = original.touches[0].pageY

        @annotator.viewer.hide() if @annotator.viewer.isShown()
        @annotator.onHighlightMouseover(event)

        jQuery(document).unbind("tap", onDocTap)
        jQuery(document).bind("tap", preventDefault: false, onDocTap)

    onDocTap = (event) =>
      unless @annotator.isAnnotator(event.target)
        @annotator.viewer.hide()
        jQuery(document).unbind "tap", onDocTap

    @annotator.adder.remove()

    @annotator.editor.on "show", =>
      @highlighter.disable() if @highlighter

    @annotator.viewer.on "show", =>
      @highlighter.disable() if @highlighter
      window.getSelection().removeAllRanges()

    @annotator.editor.on "hide", =>
      @_watchForSelection()
      @highlighter.enable() if @highlighter
      window.getSelection().removeAllRanges()

    @annotator.viewer.on "hide", =>
      @highlighter.enable() if @highlighter and @editor.element.hasClass(@editor.classes.hide)

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

  createAnnotation: (range, quote) ->
    @annotator.selectedRanges = [range]
    annotation = @annotator.createAnnotation()
    annotation.quote = quote if quote
    annotation

  showEditor: (annotation) ->
    @annotator.showEditor(annotation, {})
    @hideControls()

  showControls: ->
    @controls.removeClass(@classes.hide)

  hideControls: ->
    @controls.addClass(@classes.hide) unless @options.useHighlighter

  _setupControls: ->
    @controls = jQuery(@template).appendTo("body")

    @adder = @controls.find(".annotator-add")
    @adder.bind("tap", (onTapDown: (event) -> event.stopPropagation()), @_onAdderTap)

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

      if browserRange and not @annotator.isAnnotator(range.commonAncestor)
        annotation = @createAnnotation(range, @range.toString())
        @showEditor(annotation)
        @annotator.onAdderMousedown()

  isTouchDevice: ->
    ('ontouchstart' of window) or window.DocumentTouch and document instanceof DocumentTouch
