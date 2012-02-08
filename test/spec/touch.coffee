describe "Annotator.Touch", ->
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
