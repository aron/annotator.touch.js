fs   = require "fs"
FFI  = require "node-ffi"
libc = new FFI.Library(null, "system": ["int32", ["string"]])
run  = libc.system
pkg  = require "./package"

VERSION = pkg.version
PACKAGE = "annotator.touch"
OUTPUT  = "pkg/#{PACKAGE}.min.js"
STYLES  = "pkg/#{PACKAGE}.css"
COFFEE  = "`npm bin`/coffee"
UGLIFY  = "`npm bin`/uglifyjs"
HEADER  = """
/*  Touch Annotator Plugin - v#{VERSION}
 *  Copyright 2012, Compendio <www.compendio.ch>
 *  Released under the MIT license
 *  More Information: http://github.com/aron/annotator.touch.js
 */
"""

task "watch", "Watch the coffee directories and output to ./lib", ->
  run "#{COFFEE} --watch --output ./lib ./src"

task "serve", "Serve the current directory", ->
  run "python -m SimpleHTTPServer 8000"

task "test", "Open the test suite in the browser", ->
  run "open http://localhost:8000/test/index.html"

option "", "--no-minify", "Do not minify build scripts with `cake build`"
task "build", "Concatenates and minifies CSS & JS", (options) ->
  MINIFY = if options['no-minify'] then "cat" else UGLIFY

  run """
  mkdir -p pkg && echo "#{HEADER}" > #{OUTPUT} &&
  cat src/touch.coffee src/touch/*.coffee |
  #{COFFEE} --stdio --print | #{MINIFY} >> #{OUTPUT} && echo "" >> #{OUTPUT}
  """
  utils.inline ["css/annotator.touch.css"], STYLES

task "pkg", "Creates a zip package with minified scripts", ->
  invoke "build"
  run "zip -jJ pkg/#{PACKAGE}.#{VERSION}.zip #{OUTPUT} #{STYLES}"

utils =
  dataurlify: (css) ->
    # NB: path to image is "src/..." because the CSS urls start with "../img"
    b64_str = (name) -> fs.readFileSync("src/#{name}.png").toString('base64')
    b64_url = (m...) -> "url('data:image/png;base64,#{b64_str(m[2])}')"
    css.replace(/(url\(([^)]+)\.png\))/g, b64_url)

  inline: (src, dest) ->
    run "echo '#{HEADER}' > #{dest}"
    run "cat #{src.join(' ')} >> #{dest}"
    code = fs.readFileSync(dest, 'utf8')
    fs.writeFileSync(dest, @dataurlify(code))
