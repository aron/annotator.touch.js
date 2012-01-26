describe "Annotator.Touch", ->
  plugin = null

  beforeEach ->
    plugin = new Annotator.Plugin.Touch(document.body)

  afterEach ->
    plugin.pluginDestroy()

  it "should be an instance of Annotator.Plugin", ->
    expect(plugin).to.be.an.instanceof(Annotator.Plugin)

  describe "@pluginInit()", ->
    it "should start watching for selections", ->
      target = sinon.stub(plugin, "_watchForSelection")
      plugin.pluginInit()
      expect(target).was.called()

    it "should append the @adder to the document.body", ->
      plugin.pluginInit()
      expect(plugin.adder.parent().get(0)).to.equal(document.body)

    it "should create a new instance of Highlighter", ->
      plugin.pluginInit()
      expect(plugin.highlighter).to.be.an.instanceof(Highlighter)

  describe "@pluginDestroy()", ->
    beforeEach ->
      plugin.pluginInit()

    it "should remove the adder from the DOM", ->
      plugin.pluginDestroy()
      expect(plugin.adder.parent().get(0)).to.equal(undefined)

    it "should disable the @highlighter object", ->
      target = sinon.stub(plugin.highlighter, "disable")
      plugin.pluginDestroy()
      expect(target).was.called()
