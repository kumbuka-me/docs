.DEFAULT_GOAL := help

## Tool Versions

# renovate: datasource=github-releases depName=kumbuka-me/cli
KUMBUKA_CLI_VERSION ?= v0.0.1

# renovate: datasource=github-releases depName=gi8lino/dev-tools
DEV_TOOLS_VERSION ?= v0.7.0

# renovate: datasource=npm depName=prettier
PRETTIER_VERSION ?= 3.9.6

## Shared development tools

include bin/dev-tools.mk
include $(call dev-tools-module,port)
include $(call dev-tools-module,browser)
include $(call dev-tools-module,help)

## Tools

KUMBUKA_CLI := bin/kumbuka-cli
KUMBUKA_CLI_ASSET ?= kumbuka-cli_{version}_{os}_{arch}.tar.gz
NPX ?= npx

## Site Configuration

SITE_CONFIG ?= site.toml
SITE_OUTPUT ?= site
SITE_PORT = $(call dev-port,site)
SITE_URL = http://127.0.0.1:$(SITE_PORT)/
BUILD_ARGS ?=

## Formatting

PRETTIER_SOURCES := README.md "content/**/*.md" ".github/**/*.yml"


##@ Development

.PHONY: build
build: kumbuka-cli ## Build the production documentation site.
	$(call run-tool,$(KUMBUKA_CLI),build --config "$(SITE_CONFIG)" $(BUILD_ARGS))

.PHONY: check
check: build ## Build and verify the static site artifacts required by GitHub Pages.
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

.PHONY: ports-reset
ports-reset: $(DEV_PORT) ## Clear saved local development ports.
	$(call run-tool,$(DEV_PORT),--reset)


##@ Formatting

.PHONY: fmt
fmt: ## Format Markdown and workflow files.
	$(NPX) --yes prettier@$(PRETTIER_VERSION) --write $(PRETTIER_SOURCES)

.PHONY: fmt-check
fmt-check: ## Check Markdown and workflow formatting.
	$(NPX) --yes prettier@$(PRETTIER_VERSION) --check $(PRETTIER_SOURCES)


##@ Dependencies

.PHONY: kumbuka-cli
kumbuka-cli: $(GITHUB_RELEASE_INSTALL) ## Install the pinned Kumbuka CLI.
	@$(GITHUB_RELEASE_INSTALL) \
		--repo kumbuka-me/cli \
		--tag "$(KUMBUKA_CLI_VERSION)" \
		--asset "$(KUMBUKA_CLI_ASSET)" \
		--binary kumbuka-cli \
		--target "$(KUMBUKA_CLI)"



