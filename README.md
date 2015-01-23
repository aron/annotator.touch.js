Touch Annotator Plugin
======================

A plugin for the [OKFN Annotator][#annotator] that improves the usability of
the tool on touch devices. It has been tested on the following devices.

 - iPhone running iOS 5
 - iPad running iOS 5
 - Samsung Galaxy Tab running Android 3.2
 - Android Emulator running Android 4

[#annotator]: http://okfnlabs.org/annotator/

There is a [demo available online][#demo].

[#demo]: http://aron.github.com/annotator.touch.js

Usage
-----

The plugin requires the _annotator.js_ and _annotator.css_ to be included on
the page. See the annotator [Getting Started][#ann-install] guide for
instructions then simply include the _annotator.touch.js_ and
_annotator.touch.css_ file in your page. These can be downloaded from the
GitHub [releases page][#download].

[#download]: http://github.com/aron/annotator.touch.js/releases

```html
<link rel="stylesheet" href="./annotator.css" />
<link rel="stylesheet" href="./annotator.touch.css" />
<script src="./jquery.js"></script>
<script src="./annotator.js"></script>
<script src="./annotator.touch.js"></script>
```

Then set up the annotator as usual calling `"addPlugin"`.

```javascript
jQuery('#content').annotator().annotator("addPlugin", "Touch");
```

[#ann-install]: https://github.com/okfn/annotator/wiki/Getting-Started

Options
-------

There are a few options that can be provided to the `"addPlugin"` call.

```javascript
jQuery('#content').annotator().annotator("addPlugin", "Touch", {
  force: true,
  useHighlighter: true
});
```

 - `force`: Forces the touch controls to be loaded into the page. This is
   useful for testing or if the annotator will always be used in a touch
   device (say when bundled into an application).
 - `useHighlighter`: Some touch devices do not allow the browser access to the
   selected text using `window.getSelection()`. highlighter.js is provided
   in the _/vendor/_ directory to try and address this issue. If you wish to
   use this feature it needs to be manually enabled (as it can't be feature
   detected). Include the script in your page and set this option to true.

Example
-------

The _example.html_ file provided gives a demo of the plugin in action. The
various options can be toggled by adding query string parameters.

For example http://localhost:8000/example.html?force&highlighter:

 - force: Enable the plugin on desktop browsers.
 - highlighter: Use the highlighter.js fallback.

Development
-----------

If you're interested in developing the plugin. You can install the developer
dependancies by running the following command in the base directory:

    $ npm install

Development requires _node_ and _npm_ binaries to be intalled on your system.
It has been tested with `node --version 0.10.7` and `npm --version 1.2.21`.
Details on installation can be found on the [node website][#node].

Run the local server:

    $ make serve

Then visit http://localhost:8000 in your browser.

There is a _Makefile_ containing useful commands included.

    $ make serve # serves the directory at http://localhost:8000 (requires python)
    $ make watch # compiles .coffee files into lib/*.js when they change
    $ make build # creates compiled JavaScript and CSS in the pkg directory
    $ make pkg   # creates a zip file of production files

[#node]: http://nodejs.org/

### Repositories

The `development` branch should always contain the latest version of the
plugin but it is not guaranteed to be in working order. The `master` branch
should always have the latest stable code and each release can be found under
an appropriately versioned tag.

### Testing

Unit tests are located in the test/ directory and can be run by visiting
http://localhost:8000/test/index.html in your browser.

### Frameworks

The plugin uses the following libraries for development:

 - [Mocha][#mocha]: As a BDD unit testing framework.
 - [Sinon][#sinon]: Provides spies, stubs and mocks for methods and functions.
 - [Chai][#chai]:   Provides all common assertions.

[#mocha]: http://visionmedia.github.com/mocha/
[#sinon]: http://chaijs.com/
[#chai]:  http://sinonjs.org/docs/

License
-------

This plugin was commissioned and open sourced by Compendio.

Copyright 2012, Compendio Bildungsmedien AG
Neunbrunnenstrasse 50
8050 Zürich
www.compendio.ch

Released under the [MIT license][#license]
