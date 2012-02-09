describe "Touch", ->
  Touch = Annotator.Plugin.Touch
  plugin = null
  annotator = null

  createPlugin = (opts) ->
    opts = jQuery.extend(force: true, opts)
    root = document.createElement('div')
    plug = new Annotator.Plugin.Touch(root, opts)
    anno = new Annotator(root)
    anno.plugins.Touch = plug
    plug.annotator = anno
    plug

  beforeEach ->
    plugin = createPlugin()
    annotator = plugin.annotator
    plugin.pluginInit()

  afterEach ->
    plugin.pluginDestroy()

  it "should be an instance of Annotator.Plugin", ->
    expect(plugin).to.be.an.instanceof(Annotator.Plugin)

  describe "@pluginInit()", ->
    beforeEach ->
      plugin.pluginDestroy()
      plugin = createPlugin()
      annotator = plugin.annotator

    it "should start watching for selections", ->
      target = sinon.stub(plugin, "_watchForSelection")
      plugin.pluginInit()
      expect(target).was.called()

    it "should append the @controls to the document.body", ->
      plugin.pluginInit()
      expect(plugin.controls.parent().get(0)).to.equal(document.body)

    it "should create a new instance of Highlighter if @options.useHighlighter is true", ->
      plugin.pluginDestroy()
      plugin = createPlugin(useHighlighter: true)
      annotator = plugin.annotator
      plugin.pluginInit()
      expect(plugin.highlighter).to.be.an.instanceof(Highlighter)

  describe "@pluginDestroy()", ->
    beforeEach ->
      plugin.pluginDestroy()
      plugin = createPlugin(useHighlighter: true)
      annotator = plugin.annotator
      plugin.pluginInit()

    it "should remove the controls from the DOM", ->
      plugin.pluginDestroy()
      expect(plugin.controls.parent().get(0)).to.equal(undefined)

    it "should disable the @highlighter object", ->
      target = sinon.stub(plugin.highlighter, "disable")
      plugin.pluginDestroy()
      expect(target).was.called()

  describe "#startAnnotating()", ->
    it "should toggle the data-state to 'on'", ->
      plugin.startAnnotating()
      expect(plugin.toggle.data("state")).to.equal(Touch.states.ON)

    it "should change the text to 'Stop Annotating'", ->
      plugin.startAnnotating()
      expect(plugin.toggle.text()).to.equal("Stop Annotating")

    it "should enable the highlighter if enabled", ->
      target = sinon.stub()
      plugin.highlighter = enable: target
      plugin.startAnnotating()
      expect(target).was.called()
      delete plugin.highlighter

  describe "#stopAnnotating()", ->
    it "should toggle the data-state to 'off'", ->
      plugin.stopAnnotating()
      expect(plugin.toggle.data("state")).to.equal(Touch.states.OFF)

    it "should change the text to 'Start Annotating'", ->
      plugin.stopAnnotating()
      expect(plugin.toggle.text()).to.equal("Start Annotating")

    it "should disable the highlighter if enabled", ->
      target = sinon.stub()
      plugin.highlighter = disable: target
      plugin.stopAnnotating()
      expect(target).was.called()
      delete plugin.highlighter

  describe "#isAnnotating()", ->
    it "should return true if the annotator state is 'on'", ->
      plugin.options.useHighlighter = true
      plugin.startAnnotating()
      target = plugin.isAnnotating()
      expect(target).to.equal(true)

    it "should return false if the annotator state is 'false'", ->
      plugin.options.useHighlighter = true
      plugin.stopAnnotating()
      target = plugin.isAnnotating()
      expect(target).to.equal(false)

    it "should always return true if not using the highlighter", ->
      plugin.stopAnnotating()
      target = plugin.isAnnotating()
      expect(target).to.equal(true)

  describe "#createAnnotation()", ->
    range = null

    beforeEach ->
      nativeRange = document.createRange()
      nativeRange.selectNodeContents(jQuery("#fixture p")[0])

      browserRange = new Annotator.Range.BrowserRange(nativeRange)
      range = browserRange.normalize()

    it "should return a newly created annotation", ->
      target = plugin.createAnnotation(range)
      expect(target).to.have.property('quote').to.equal("This is a test sentence.")

    it "should use the provided quote", ->
      target = plugin.createAnnotation(range, "passed quotation")
      expect(target).to.have.property('quote').to.equal("passed quotation")

  describe "#showEditor()", ->
    it "should show the editor", ->
      ann = {id: "this-is-an-id"}
      target = sinon.stub(plugin.annotator, "showEditor")
      plugin.showEditor(ann)
      expect(target).was.called()
      expect(target).was.calledWith(ann, {})

    it "should hide the touch controls", ->
      target = sinon.stub(plugin, "hideControls")
      plugin.showEditor({})
      expect(target).was.called()

  describe "#showControls()", ->
    it "should show the controls", ->
      plugin.showControls()
      expect(plugin.controls[0].className).not.to.include(plugin.classes.hide)
  
  describe "#hideControls()", ->
    it "should hide the controls", ->
      plugin.hideControls()
      expect(plugin.controls[0].className).to.include(plugin.classes.hide)
