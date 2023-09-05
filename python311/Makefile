SHELL := /bin/bash
IMAGE = python311

.PHONY: help

help:
	@grep -E '^[\%a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

build: ## Build image
	docker build -t \
	$(IMAGE) \
	.

start: ## Start container
	docker run -ti --rm \
	$(IMAGE)

clean: ## Remove image
	docker rmi \
	$(IMAGE)
