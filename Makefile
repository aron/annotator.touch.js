package = $(shell node -p -e 'require("./package.json").$(1)')

NAME      = $(call package,display_name)
VERSION   = $(call package,version)
LICENSE   = $(call package,license)
HOMEPAGE  = $(call package,homepage)
COPYRIGHT = 2012-$(shell TZ=UTC date +%Y)

define HEADER
/*  $(NAME) - v$(VERSION)
 *  Copyright $(COPYRIGHT), Compendio <www.compendio.ch>
 *  Released under the $(LICENSE) license
 *  More Information: $(HOMEPAGE)
 */
endef
export HEADER

define USAGE
Usage instructions:
  make watch                watches and recompiles coffee files into lib
  make serve                runs a development server on port 8000
  make serve PORT=[port]    runs a development server on the port specified
  make clean                removes the pkg directory
  make build                creates a development build
  make build MINIFY=true    creates a production build
  make pkg                  creates a production zipped build
  make help                 displays this message
endef
export USAGE

PORT ?= 8000
PKGDIR = pkg
COFFEE = `npm bin`/coffee
UGLIFY = `npm bin`/uglifyjs

PROCESSOR = cat
PACKAGE = $(PKGDIR)/annotator.touch
OUTPUT = $(PACKAGE).js
MIN_OUTPUT = $(PACKAGE).min.js
CSS_OUTPUT = $(PACKAGE).css

ifeq ($(MINIFY), true)
	OUTPUT = $(MIN_OUTPUT)
	PROCESSOR = $(UGLIFY)
endif


default: help

help:
	@echo "$$USAGE"

pkgdir:
	@mkdir -p $(PKGDIR)

clean:
	@rm -rf $(PKGDIR)

serve:
	@echo "Tests are available at http://localhost:$(PORT)/test/index.html"
	@python -m SimpleHTTPServer $(PORT)

watch:
	@$(COFFEE) --watch --output ./lib ./src

javascript: pkgdir
	@echo "$$HEADER" > $(OUTPUT)
	@cat src/touch.coffee src/touch/*.coffee | \
		$(COFFEE) --stdio --print | \
		$(PROCESSOR) >> $(OUTPUT)
	@echo "Created $(OUTPUT)"

stylesheet: pkgdir
	@echo "$$HEADER" > $(CSS_OUTPUT)
	@$(COFFEE) tools/inline.coffee css/annotator.touch.css >> $(CSS_OUTPUT)
	@echo "Created $(CSS_OUTPUT)"

build: javascript stylesheet

pkg:
	@make javascript
	@make javascript MINIFY=true
	@make stylesheet
	@zip -qjJ $(PACKAGE).$(VERSION).zip $(OUTPUT) $(MIN_OUTPUT) $(CSS_OUTPUT) LICENSE
	@echo "Created $(PACKAGE).$(VERSION).zip"

.PHONY: help pkgdir clean serve watch build stylesheet javascript pkg
