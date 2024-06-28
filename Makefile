PLATFORM=$(shell docker version --format '{{.Server.Os}}/{{.Server.Arch}}')
DERIVATIVES=$(shell ls context)

.DEFAULT_GOAL := all
.PHONY: all clean help test $(DERIVATIVES) $(TEST)

all: $(DERIVATIVES) ## Build Docker images for all derivatives

help: ## Display a list of the public targets
	@grep -E -h "^[a-z]+:.*##" $(MAKEFILE_LIST) | sed -e 's/\(.*\):.*## *\(.*\)/\1|\2/' | column -s '|' -t

_derivates: ## Output derivatives as JSON list
	@echo $(DERIVATIVES) | jq --compact-output --raw-input 'split(" ") | map(select(. != ""))'

$(DERIVATIVES): ## Build Docker image for derivative
	docker buildx build --target $@ --platform=$(PLATFORM) --file Dockerfile --tag ghcr.io/reload/https-proxy:$@ --load context

test: base
	GOSS_SLEEP=5 dgoss run ghcr.io/reload/https-proxy:base
