# Inline CSS images.
fs = require("fs")

dataurlify = (css) ->
  # NB: path to image is "src/..." because the CSS urls start with "../img"
  b64Str = (name) -> fs.readFileSync("src/#{name}.png").toString('base64')
  b64Url = (m...) -> "url('data:image/png;base64,#{b64Str(m[2])}')"
  css.replace(/(url\(([^)]+)\.png\))/g, b64Url)

destination = process.argv.slice().pop()

if destination && fs.existsSync(destination)
  code = fs.readFileSync(destination, 'utf8')
  process.stdout.write(dataurlify(code))
else
  console.error("Usage:\n  $ coffee tools/inline.coffee {CSS_FILE}")
  process.exit(1)
