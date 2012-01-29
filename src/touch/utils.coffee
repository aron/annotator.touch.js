jQuery.event.special.tap =
  add: (eventHandler) ->
    data = eventHandler.data = eventHandler.data or {}
    context = this

    onTapStart = (event) ->
      event.preventDefault() unless data.preventDefault is false
      data.onTapDown.apply(this, arguments) if data.onTapDown

      data.event = event
      data.touched = setTimeout ->
        data.touched = null
      , 300

      jQuery(document).bind touchend: onTapEnd, mouseup: onTapEnd

    onTapEnd = (event) ->
      if data.touched
        clearTimeout(data.touched)
        if event.target is context or jQuery.contains(context, event.target)
          eventHandler.handler.call(this, data.event)
        data.touched = null

      data.onTapUp.apply(this, arguments) if data.onTapUp

      jQuery(document).unbind touchstart: onTapEnd, mousedown: onTapEnd

    data.tapHandlers = touchstart: onTapStart, mousedown: onTapStart
    if eventHandler.selector
      jQuery(context).delegate eventHandler.selector, data.tapHandlers
    else
      jQuery(context).bind data.tapHandlers

  remove: (eventHandler) ->
    jQuery(this).unbind eventHandler.data.tapHandlers

# Add support for "touch" events.
Annotator.Delegator.natives.push("touchstart", "touchmove", "touchend", "tap")

Annotator.Plugin.Touch.utils = do ->
  vendors = ['ms', 'moz', 'webkit', 'o']

  requestAnimationFrame = window.requestAnimationFrame
  cancelAnimationFrame  = window.cancelAnimationFrame

  for prefix in vendors when !requestAnimationFrame
    requestAnimationFrame = window["#{prefix}RequestAnimationFrame"]
    cancelAnimationFrame  = window["#{prefix}CancelAnimationFrame"] or window["#{prefix}CancelRequestAnimationFrame"]

  unless requestAnimationFrame
    lastTime = 0
    requestAnimationFrame = (callback, element) ->
      currTime   = new Date().getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      lastTime   = currTime + timeToCall
      window.setTimeout((-> callback(currTime + timeToCall)), timeToCall)

  unless cancelAnimationFrame
    cancelAnimationFrame = (id) -> clearTimeout(id)

  {
    requestAnimationFrame: requestAnimationFrame
    cancelAnimationFrame:  cancelAnimationFrame
  }
