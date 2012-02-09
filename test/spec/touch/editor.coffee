describe "Touch.Editor", ->
  Editor = Annotator.Plugin.Touch.Editor
  editor = null

  beforeEach ->
    annotatorEditor = new Annotator.Editor()
    editor = new Editor(annotatorEditor)

  it "should add additonal class names to the editor", ->
    expect(editor.element[0].className).to.include("annotator-touch-editor")
    expect(editor.element.find(".annotator-touch-widget").length).to.equal(1)
    expect(editor.element.find("form")[0].className).to.include("annotator-touch-widget-inner")
    expect(editor.element.find(".annotator-controls a")[0].className).to.include("annotator-button")

  it "should add an @quote field", ->
    expect(editor.quote).to.be.defined

  describe "#showQuote()", ->
    it "should show the quoted text", ->
      editor.showQuote()
      expect(editor.quote[0].className).to.include(editor.classes.expand)

    it "should change the button text to 'Collapse'", ->
      editor.showQuote()
      expect(editor.quote.find("button").text()).to.equal("Collapse")

  describe "#hideQuote()", ->
    it "should hide the quoted text", ->
      editor.hideQuote()
      expect(editor.quote[0].className).not.to.include(editor.classes.expand)

    it "should change the button text to 'Expand'", ->
      editor.hideQuote()
      expect(editor.quote.find("button").text()).to.equal("Expand")

