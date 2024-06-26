PLATFORM=$(shell docker version --format '{{.Server.Os}}/{{.Server.Arch}}')
DERIVATIVES=$(shell ls context)

.DEFAULT_GOAL := all
.PHONY: all build clean help _platforms test

all: $(DERIVATIVES) ## Build Docker images for all derivatives

help: ## Display a list of the public targets
	@grep -E -h "^[a-z]+:.*##" $(MAKEFILE_LIST) | sed -e 's/\(.*\):.*## *\(.*\)/\1|\2/' | column -s '|' -t

_derivates: ## Output platforms as JSON list
	@echo $(DERIVATIVES) | jq --compact-output --raw-input 'split(" ") | map(select(. != ""))'

_platforms: ## Output platforms as JSON list
	@echo $(PLATFORMS) | jq --compact-output --raw-input 'split(",") | map(select(. != ""))'

$(DERIVATIVES): Dockerfile context ## Build Docker image for derivative
	docker buildx build --target $@ --platform=$(PLATFORM) --file Dockerfile --tag ghcr.io/reload/https-proxy:$@ --load context

test: base
	dgoss run ghcr.io/reload/https-proxy:base
