describe "Touch.Viewer", ->
  viewer = null

  beforeEach ->
    defaultViewer = new Annotator.Viewer()
    viewer = new Annotator.Plugin.Touch.Viewer(defaultViewer)

  it "should have the 'annotator-touch-widget' class", ->
    expect(viewer.element[0].className).to.include("annotator-touch-widget")

  describe "#hideAllControls()", ->
    it "should remove the hide class from all list items", ->
      viewer.element.append('<li class="annotator-item annotator-visible"></li>')
      viewer.element.append('<li class="annotator-item annotator-visible"></li>')
      viewer.element.append('<li class="annotator-item annotator-visible"></li>')

      viewer.hideAllControls()
      expect(viewer.element.find('.annotator-visible').length).to.equal(0)
