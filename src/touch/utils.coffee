jQuery.event.special.tap =
  add: (data) ->
    context = this

    onTapStart = (event) ->
      event.preventDefault() if event.target is context
      data.event = event
      data.touched = setTimeout ->
        data.touched = null
      , 300
      jQuery(document).bind touchend: onTapEnd, mouseup: onTapEnd

    onTapEnd = (event) ->
      if data.touched
        clearTimeout(data.touched)
        jQuery(document).unbind touchstart: onTapEnd, mousedown: onTapEnd
        if event.target is context or jQuery.contains(context, event.target)
          data.handler.call(this, data.event)
        data.touched = null

    data.tapHandlers = touchstart: onTapStart, mousedown: onTapStart
    if data.selector
      jQuery(context).delegate data.selector, data.tapHandlers
    else
      jQuery(context).bind data.tapHandlers

  remove: (data) ->
    jQuery(this).unbind data.tapHandlers

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
