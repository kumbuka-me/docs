.DEFAULT_GOAL := help

## Tool Versions

# renovate: datasource=github-releases depName=kumbuka-me/cli
KUMBUKA_CLI_VERSION ?= v0.0.1

# renovate: datasource=github-releases depName=gi8lino/dev-tools
DEV_TOOLS_VERSION ?= v0.9.0

# renovate: datasource=npm depName=prettier
PRETTIER_VERSION ?= 3.9.8

## Shared development tools

include bin/dev-tools.mk
include $(call dev-tools-module,port)
include $(call dev-tools-module,browser)
include $(call dev-tools-module,help)

## Tools

KUMBUKA_CLI := bin/kumbuka-cli
KUMBUKA_CLI_ASSET ?= kumbuka-cli_{version}_{os}_{arch}.tar.gz
FAVICON_GENERATE := $(DEV_TOOLS_BIN)/favicon-generate
SVG_TO_PNG := $(DEV_TOOLS_BIN)/svg-to-png
SCREENSHOT_SCRIPT := scripts/screenshots/run.sh
NODE_MODULES := node_modules/.package-lock.json
NPM ?= npm
NPX ?= npx

## Site Configuration

SITE_CONFIG ?= site.toml
SITE_OUTPUT ?= site
SITE_PORT = $(call dev-port,site)
SITE_URL = http://127.0.0.1:$(SITE_PORT)/
BUILD_ARGS ?=

## Screenshots

KUMBUKA_SERVER_DIR ?= ../kumbuka
SCREENSHOT_OUTPUT ?= assets/screenshots
SCREENSHOT_EDITOR_SLUG ?= getting-started
SCREENSHOT_VISITS ?= /pages/getting-started,/pages/content/editor,/pages/knowledge/search
SCREENSHOT_BROWSER_CHANNEL ?=
SCREENSHOT_SKIP_BROWSER_INSTALL ?= 0

## Assets

FAVICON_SOURCE ?= assets/favicon.svg
FAVICON_OUTPUT ?= assets
FAVICON_SIZES ?= 16x16 32x32

LOGO_SOURCE ?= assets/kumbuka.svg
LOGO_PNG ?= assets/kumbuka.png
LOGO_PNG_WIDTH ?= 1200

## Formatting

PRETTIER_SOURCES := README.md package.json package-lock.json "content/**/*.md" ".github/**/*.{yml,yaml,json}"


##@ Development

.PHONY: build
build: cli ## Build the production documentation site.
	$(call run-tool,$(KUMBUKA_CLI),build --config "$(SITE_CONFIG)" $(BUILD_ARGS))

.PHONY: check
check: fmt-check build ## Check formatting, build, and verify the GitHub Pages artifacts.
	@test -s "$(SITE_OUTPUT)/index.html"
	@test -s "$(SITE_OUTPUT)/assets/css/app.css"
	@test -s "$(SITE_OUTPUT)/assets/js/static.js"
	@test -f "$(SITE_OUTPUT)/.nojekyll"

.PHONY: serve
serve: $(DEV_PORT) $(OPEN_BROWSER) ## Build, serve, and open the documentation locally.
	$(MAKE) build BUILD_ARGS='--site-url "$(SITE_URL)"'
	@test -s "$(SITE_OUTPUT)/index.html" || { \
		echo "$(SITE_OUTPUT)/index.html does not exist."; \
		exit 1; \
	}
	@echo "Serving Kumbuka documentation at $(SITE_URL)"
	@$(OPEN_BROWSER) "$(SITE_URL)" & \
	browser_pid=$$!; \
	trap 'kill "$$browser_pid" 2>/dev/null || true' EXIT; \
	python3 -m http.server "$(SITE_PORT)" \
		--bind 127.0.0.1 \
		--directory "$(SITE_OUTPUT)"

.PHONY: screenshots
screenshots: $(NODE_MODULES) ## Regenerate product screenshots from the canonical documentation Markdown.
	@test -f "$(KUMBUKA_SERVER_DIR)/go.mod" || { \
		echo "Kumbuka server repository not found: $(KUMBUKA_SERVER_DIR)" >&2; \
		exit 2; \
	}
	@SCREENSHOT_BROWSER_CHANNEL="$(SCREENSHOT_BROWSER_CHANNEL)" \
		SCREENSHOT_SKIP_BROWSER_INSTALL="$(SCREENSHOT_SKIP_BROWSER_INSTALL)" \
		$(SCREENSHOT_SCRIPT) \
			--server "$(KUMBUKA_SERVER_DIR)" \
			--content "$(CURDIR)/content" \
			--output "$(CURDIR)/$(SCREENSHOT_OUTPUT)" \
			--editor-slug "$(SCREENSHOT_EDITOR_SLUG)" \
			--visits "$(SCREENSHOT_VISITS)"

.PHONY: ports-reset
ports-reset: $(DEV_PORT) ## Clear saved local development ports.
	$(call run-tool,$(DEV_PORT),--reset)


##@ Assets

.PHONY: favicon
favicon: $(FAVICON_GENERATE) $(FAVICON_SOURCE) ## Generate PNG favicons from the canonical SVG.
	$(call run-tool,$(FAVICON_GENERATE),--apple-touch "$(FAVICON_SOURCE)" "$(FAVICON_OUTPUT)" $(FAVICON_SIZES))

.PHONY: logo-png
logo-png: $(SVG_TO_PNG) $(LOGO_SOURCE) ## Generate a PNG version of the Kumbuka logo.
	$(call run-tool,$(SVG_TO_PNG),--width "$(LOGO_PNG_WIDTH)" "$(LOGO_SOURCE)" "$(LOGO_PNG)")


##@ Formatting

.PHONY: fmt
fmt: ## Format documentation and GitHub configuration files.
	$(NPX) --yes prettier@$(PRETTIER_VERSION) --write $(PRETTIER_SOURCES)

.PHONY: fmt-check
fmt-check: ## Check documentation and GitHub configuration formatting.
	$(NPX) --yes prettier@$(PRETTIER_VERSION) --check $(PRETTIER_SOURCES)


##@ Dependencies

$(NODE_MODULES): package.json package-lock.json
	$(NPM) ci

$(FAVICON_GENERATE): | $(DEV_TOOLS_BIN)
	$(call download-dev-tool,favicon-generate,$@)

$(SVG_TO_PNG): | $(DEV_TOOLS_BIN)
	$(call download-dev-tool,svg-to-png,$@)

.PHONY: dev-tools
dev-tools: $(DEV_PORT) $(OPEN_BROWSER) $(MAKE_HELP) $(FAVICON_GENERATE) $(SVG_TO_PNG) ## Download the pinned development tools.

.PHONY: cli
cli: $(GITHUB_RELEASE_INSTALL) ## Install the pinned Kumbuka CLI.
	@$(GITHUB_RELEASE_INSTALL) \
		--repo kumbuka-me/cli \
		--tag "$(KUMBUKA_CLI_VERSION)" \
		--asset "$(KUMBUKA_CLI_ASSET)" \
		--binary kumbuka-cli \
		--target "$(KUMBUKA_CLI)"
