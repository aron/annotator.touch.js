Annotator.Plugin.Touch.utils = do ->
  vendors = ['ms', 'moz', 'webkit', 'o']

  requestAnimationFrame = window.requestAnimationFrame
  cancelAnimationFrame  = window.cancelAnimationFrame

  for prefix in vendors when !requestAnimationFrame
    requestAnimationFrame = window["#{prefix}RequestAnimationFrame"]
    cancelAnimationFrame  = window["#{prefix}CancelAnimationFrame"] or window["#{prefix}RequestCancelAnimationFrame"]

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
