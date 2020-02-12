# DEFAULTS
SHELL := /bin/bash
# un-comment to make it more verbose
# .SILENT:
OUTPUT_PATH ?= output
KUBECTL = docker-compose run --rm kubectl
HELM = docker-compose run --rm helm
YQ = docker-compose run --rm yq

# GKE
GCP_PROJECT_ID ?= $(shell $(YQ) yq r config.yaml gcp.projectId)
GCP_REGION ?= $(shell $(YQ) yq r config.yaml gcp.region)
GKE_CLUSTER_NAME ?= $(shell $(YQ) yq r config.yaml gcp.clusterName)

# APPLICATION
REGISTRY_URL ?= $(shell $(YQ) yq r config.yaml registryUrl)
SERVICE_NAME ?= $(shell $(YQ) yq r config.yaml application.name)
SERVICE_VERSION ?= $(shell $(YQ) yq r config.yaml application.version)
LOG_LEVEL ?= $(shell $(YQ) yq r config.yaml application.logLevel)
SERVICE_PORT ?= $(shell $(YQ) yq r config.yaml k8s.servicePort)
HOST_PORT ?= $(shell $(YQ) yq r config.yaml k8s.hostPort)
GIT_SHA ?= $(shell git rev-parse HEAD)
SHORT_GIT_SHA ?= $(shell git rev-parse --short HEAD)
CONTAINER_IMAGE ?= $(REGISTRY_URL)/$(SERVICE_NAME):$(SHORT_GIT_SHA)
LATEST ?= $(REGISTRY_URL)/$(SERVICE_NAME):latest

.PHONY: test
test: build run

.PHONY: build
build:
	docker build -t $(CONTAINER_IMAGE) \
		--build-arg ARG_SERVICE_NAME=$(SERVICE_NAME) \
		--build-arg ARG_SERVICE_VERSION=$(SERVICE_VERSION) \
		--build-arg ARG_GIT_SHA=$(GIT_SHA) \
		.
	docker tag $(CONTAINER_IMAGE) $(LATEST)

.PHONY: push
push:
	docker push $(CONTAINER_IMAGE)
	docker push $(LATEST)

.PHONY: run
run:
	docker run -d \
		-p $(HOST_PORT):$(SERVICE_PORT) \
		-e SERVICE_PORT=$(SERVICE_PORT) \
		-e LOG_LEVEL=$(LOG_LEVEL) \
		$(CONTAINER_IMAGE)

.PHONY: deploy
deploy: _ENV-GCP_PROJECT_ID _ENV-GCP_REGION _ENV-GKE_CLUSTER_NAME _prepare _auth _template
	$(KUBECTL) apply -f $(OUTPUT_PATH)/kube.yaml

.PHONY: forward
forward:
	kubectl port-forward service/$(SERVICE_NAME) $(HOST_PORT):$(HOST_PORT)

.PHONY: _template
_template: _prepare
	$(HELM) template helm \
		--values "config.yaml" \
		--set k8s.image=$(CONTAINER_IMAGE) \
		--set k8s.hostPort=$(HOST_PORT) \
		--set k8s.servicePort=$(SERVICE_PORT) \
		> $(OUTPUT_PATH)/kube.yaml
	echo "Helm output written to $(OUTPUT_PATH)/kube.yaml"

.PHONY: _auth
_auth:
	gcloud container clusters get-credentials \
		--project $(GCP_PROJECT_ID) \
		--zone $(GCP_REGION) \
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
	rm -rf .kube/* $(OUTPUT_PATH)/*
	# docker-compose down --remove-orphans 2>/dev/null

# check if variable is set
_ENV-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi
