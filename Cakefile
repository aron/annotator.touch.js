fs   = require "fs"
FFI  = require "node-ffi"
libc = new FFI.Library(null, "system": ["int32", ["string"]])
run  = libc.system

VERSION = "0.1.0"
OUTPUT  = "pkg/annotator.touch.min.js"
STYLES  = "pkg/annotator.touch.css"
COFFEE  = "node_modules/.bin/coffee"
UGLIFY  = "node_modules/.bin/uglifyjs"
HEADER  = """
/*  Touch Annotator Plugin - v#{VERSION}
 *  Copyright 2012, Compendio
 */
"""

task "watch", "Watch the coffee directories and output to ./lib", ->
  run "#{COFFEE} --watch --output ./lib ./src"

task "serve", "Serve the current directory", ->
  run "python -m SimpleHTTPServer 8000"

task "test", "Open the test suite in the browser", ->
  run "open http://localhost:8000/test/index.html"

task "build", ->
  run "mkdir -p pkg"
  run """
  echo "#{HEADER}" > #{OUTPUT} && 
  cat src/touch.coffee src/touch/*.coffee | 
  #{COFFEE} --stdio --print | 
  #{UGLIFY} >> #{OUTPUT} && 
  echo "" >> #{OUTPUT}
  """
  utils.inline ["css/annotator.touch.css"], STYLES

task "pkg", ->
  invoke "build"
  run "zip -jJ annotator.touch.#{VERSION}.zip  #{OUTPUT} #{STYLES}"

utils = 
  dataurlify: (css) ->
    # NB: path to image is "src/..." because the CSS urls start with "../img"
    b64_str = (name) -> fs.readFileSync("src/#{name}.png").toString('base64')
    b64_url = (m...) -> "url('data:image/png;base64,#{b64_str(m[2])}')"
    css.replace(/(url\(([^)]+)\.png\))/g, b64_url)

  inline: (src, dest) ->
    run "cat #{src.join(' ')} > #{dest}"
    code = fs.readFileSync(dest, 'utf8')
    fs.writeFileSync(dest, @dataurlify(code))
