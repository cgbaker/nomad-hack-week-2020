PLUGIN_BINARY=inkyphat-device
export GO111MODULE=on

default: build

.PHONY: clean
clean: ## Remove build artifacts
	rm -rf ${PLUGIN_BINARY} launcher

build:
	go build -o ${PLUGIN_BINARY} .

.PHONY: eval
eval: deps build
	./launcher device ./${PLUGIN_BINARY} 

.PHONY: fmt
fmt:
	@echo "==> Fixing source code with gofmt..."
	gofmt -s -w ./...

.PHONY: bootstrap
bootstrap: deps # install all dependencies

.PHONY: launcher
deps:  ## Install build and development dependencies
	@echo "==> Updating build dependencies..."
	go build github.com/hashicorp/nomad/plugins/shared/cmd/launcher
