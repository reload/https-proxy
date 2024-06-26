PLATFORMS=$(shell docker version --format '{{.Server.Os}}/{{.Server.Arch}}')

.DEFAULT_GOAL := build
.PHONY: all build clean help _platforms test

all: PLATFORMS=linux/amd64,linux/arm64

help: ## Display a list of the public targets
	@grep -E -h "^[a-z]+:.*##" $(MAKEFILE_LIST) | sed -e 's/\(.*\):.*## *\(.*\)/\1|\2/' | column -s '|' -t

_platforms: ## Output platforms as JSON list
	@echo $(PLATFORMS) | jq --compact-output --raw-input 'split(",") | map(select(. != ""))'

build: ## Build Docker image for the HTTPS proxy
	docker buildx build --platform=$(PLATFORMS) --file Dockerfile --tag ghcr.io/reload/https-proxy:latest --load .

test:
	dgoss run -e PROFILE=none ghcr.io/reload/https-proxy:latest
