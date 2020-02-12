# Set some sensible defaults
SHELL := /bin/bash
# .SILENT:

# if using GKE for deployment
GCP_PROJECT_ID ?=
GCP_REGION ?= australia-southeast1
GKE_CLUSTER_NAME ?=
GKE_NAMESPACE ?=

# general
OUTPUT_PATH ?= output

.PHONY: test
test:

.PHONY: build
build:

.PHONY: deploy
deploy: env-GCP_PROJECT_ID env-GCP_REGION env-GKE_CLUSTER_NAME env-GKE_NAMESPACE _prepare _auth

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
_env-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi
