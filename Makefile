# Set some sensible defaults
SHELL := /bin/bash
.SILENT:

# if using GKE for deployment
GCP_PROJECT_ID ?=
GCP_REGION ?= australia-southeast1
GKE_CLUSTER_NAME ?=
GKE_NAMESPACE ?=

# general
OUTPUT_PATH ?= output
HOST_PORT ?= 5000

# application settings
SERVICE_NAME ?= caio-api
SERVICE_VERSION ?= 1.0.0
SERVICE_PORT ?= 5000
LOG_LEVEL ?= debug
GIT_SHA ?= $(shell git rev-parse --short HEAD | cut -c1-5)
REGISTRY_URL ?= localhost
CONTAINER_IMAGE ?= $(REGISTRY_URL)/$(SERVICE_NAME):$(GIT_SHA)

.PHONY: test
test: build run

.PHONY: build
build:
	docker build -t $(CONTAINER_IMAGE) .

.PHONY: push
push:
	docker push $(CONTAINER_IMAGE)

.PHONY: run
run:
	docker run -d \
		-p $(SERVICE_PORT):$(HOST_PORT) \
		-e SERVICE_NAME=$(SERVICE_NAME) \
		-e SERVICE_PORT=$(SERVICE_PORT) \
		-e SERVICE_VERSION=$(SERVICE_VERSION) \
		-e LOG_LEVEL=$(LOG_LEVEL) \
		-e GIT_SHA=$(GIT_SHA) \
		$(CONTAINER_IMAGE)

.PHONY: deploy
deploy: ENV-GCP_PROJECT_ID ENV-GCP_REGION ENV-GKE_CLUSTER_NAME ENV-GKE_NAMESPACE _prepare _auth
	$(KUBECTL) run $(SERVICE_NAME) --image=$(CONTAINER_IMAGE)
	$(KUBECTL) expose deployment $(SERVICE_NAME) --port=$(HOST_PORT) --target-port=$(SERVICE_PORT)

.PHONY: _auth
_auth:
	gcloud container clusters get-credentials \
		--internal-ip \
		--project $(GCP_PROJECT_ID) \
		--region $(GCP_REGION) \
		$(GKE_CLUSTER_NAME)
	kubectl version

.PHONY: _prepare
_prepare: _clear
	mkdir -p $(OUTPUT_PATH)
	mkdir -p .kube/
	cp ~/.kube/config .kube/
	chmod 644 .kube/config
	docker-compose pull 

.PHONY: _clear
_clear:
	echo "Clearing kube config and cleaning helm cache"
	rm -rf .kube/* $(OUTPUT_PATH)/*
	docker-compose down --remove-orphans 2>/dev/null

# check if variable is set
_ENV-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi
