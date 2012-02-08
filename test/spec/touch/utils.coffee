describe "Touch.utils", ->
  utils  = Annotator.Plugin.Touch.utils
  jQuery = Annotator.$

  describe ".nextTick()", ->
    it "should defer the callback until the next tick", (done) ->
      target = 1
      utils.nextTick -> target = 2; done()
      expect(target).to.equal(1)

describe "jQuery.fn.bind(\"tap\")", ->
  element = null
  clock = null

  beforeEach ->
    clock = sinon.useFakeTimers()
    element = jQuery("<div />").appendTo("body")

  afterEach ->
    clock.restore()
    element.remove()

  it "should fake a click event", ->
    target = sinon.stub()
    element.bind("tap", target)
    element.trigger("touchstart")
    element.trigger("touchend")
    expect(target).was.called()

  it "should not fire the call back if 300ms expires", (done) ->
    target = sinon.stub()
    element.bind("tap", target)
    element.trigger("touchstart")
    setTimeout ->
      element.trigger("touchend")
      expect(target).was.notCalled()
      done()
    , 500
    clock.tick(500)

  it "should not fire the call back if the touchend event is outside of the element", ->
    target = sinon.stub()
    element.bind("tap", target)
    element.trigger("touchstart")
    jQuery("body").trigger("touchend")
    expect(target).was.notCalled()

  it "should allow the timeout to be specified", (done) ->
    target = sinon.stub()
    element.bind("tap", timeout: 3000, target)
    element.trigger("touchstart")
    setTimeout ->
      element.trigger("touchend")
      expect(target).was.called()
      done()
    , 1000
    clock.tick(1000)

  it "should allow start and end callbacks to be provided", ->
    endTarget = sinon.stub()
    startTarget = sinon.stub()
    element.bind("tap", onTapUp: endTarget, onTapDown: startTarget, ->)
    element.trigger("touchstart")
    element.trigger("touchend")
    expect(endTarget).was.called()
    expect(startTarget).was.called()
