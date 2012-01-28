class Annotator.Plugin.Touch.Viewer extends Annotator.Delegator
  jQuery = Annotator.$

  events:
    ".annotator-item tap":   "_onTap"
    ".annotator-edit tap":   "_onEdit"
    ".annotator-delete tap": "_onDelete"

  constructor: (@viewer, options) ->
    super @viewer.element[0], options

    @element.unbind("click")
    @element.addClass("annotator-touch-widget")

    @on("load", @_onLoad)

  _onLoad: =>
    controls = @element.find(".annotator-controls")
    controls.toggleClass("annotator-controls annotator-touch-controls")
    controls.find("button").addClass("annotator-button")

  _onTap: (event) ->
    jQuery(event.currentTarget).toggleClass(@viewer.classes.showControls)

  _onEdit: (event) ->
    event.preventDefault()
    @viewer.onEditClick(event)

  _onDelete: (event) ->
    event.preventDefault()
    @viewer.onDeleteClick(event)
