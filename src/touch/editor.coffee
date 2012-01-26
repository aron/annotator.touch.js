class Annotator.Plugin.Touch.Editor extends Annotator.Delegator
  jQuery = Annotator.$
  _t = Annotator._t

  events:
    ".annotator-save touchstart":   "_onSubmit"
    ".annotator-cancel touchstart": "_onCancel"

  classes:
    expand: "annotator-touch-expand"

  templates:
    quote: """
    <button>#{_t("expand")}</button>
    <span class="quote"></span>
    """

  constructor: (@editor, options) ->
    super @editor.element[0], options
    @element.addClass("annotator-touch-editor")

    @element.wrapInner('<div class="annotator-touch-widget" />')
    @element.find("form").addClass("annotator-touch-widget-inner")
    @element.find(".annotator-controls a").addClass("annotator-button")

    # Remove the "return to submit" listener.
    @element.undelegate("textarea", "keydown")

    @on "hide", => @element.find(":focus").blur()

    @quote = jQuery @editor.addField
      id: 'quote'
      load: (field, annotation) =>
        @hideQuote()
        @quote.find('span').escape(annotation.quote || '')
        @quote.find("button").toggle(@_isTruncated())

    @quote.empty().addClass("annotator-item-quote")
    @quote.append(@templates.quote)
    @quote.find("button").click(@_onExpandClick)

  showQuote: ->
    @quote.addClass(@classes.expand)
    @quote.find("button").text _t("Collapse")
    this

  hideQuote: ->
    @quote.removeClass(@classes.expand)
    @quote.find("button").text _t("Expand")
    this

  isQuoteHidden: ->
    not @quote.hasClass(@classes.expand)

  _isTruncated: ->
    isHidden = @isQuoteHidden()

    @hideQuote() unless isHidden
    truncatedHeight = @quote.height()
    @showQuote()
    expandedHeight = @quote.height()

    # Restore previous state.
    if isHidden then @hideQuote() else @showQuote()

    return expandedHeight > truncatedHeight

  _onExpandClick: (event) =>
    event.preventDefault()
    event.stopPropagation()
    if @isQuoteHidden() then @showQuote() else @hideQuote()

  _onSubmit: (event) =>
    event.preventDefault()
    @editor.submit()

  _onCancel: (event) =>
    event.preventDefault()
    @editor.hide()

  _onClick: (event) ->
    @editor.hide() if event.target is @element[0]

  _onTapStart: (event) =>
    @_tapdown = null
    @_tapdown = event if event.target and event.target is @element[0]

  _onTapEnd: (event) =>
    tap = @_tapdown
    @editor.hide() if tap and event.target is tap.target and tap.pageY is event.pageY and tap.pageX is event.pageX
