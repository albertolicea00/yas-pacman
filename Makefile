# Developer shortcuts — same targets across the whole YAS suite.
APP := yas-pacman

.PHONY: setup build test run icon release clean help

help: ## list targets
	@grep -E '^[a-z]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'

setup: ## configure the build (cmake preset: default)
	cmake --preset default

build: ## compile (configures first if needed)
	@[ -d build/default ] || cmake --preset default
	cmake --build --preset default

test: build ## build + run the full test suite
	ctest --preset default --output-on-failure

run: build ## build + launch the app
	./build/default/$(APP)

icon: ## regenerate icons/app.icns from icons/icon-left.svg (macOS packaging)
	sh scripts/make-icns.sh icons/icon-left.svg icons/app.icns

release: ## optimized build
	cmake --preset release
	cmake --build --preset release

clean: ## wipe the build environment completely
	rm -rf build/
