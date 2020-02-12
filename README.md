# Docker test with NodeJS + multi-stage build + TravisCI

![TravisCI](https://travis-ci.com/caiocezart/docker-node-ci.svg?branch=master)

## Table of Contents
  - [Introduction](#introduction)
    - [NodeJS](#nodejs)
    - [Application settings](#Application-settings)
    - [Multi-stage build](#multi-stage-build)
    - [TravisCI](#travisci)
    - [Kubernetes](#kubernetes)
  - [Running Instructions](#running-instructions)
    - [Requirements](#requirements)
    - [Makefile config](#makefile-config)
    - [Targets](#targets)
  - [Manual instructions](#Manual-instructions)
  - [What is Next](#what-is-next)

## Introduction

This repository contains instructions on how to build a NodeJS container application using docker multi-stage build and also uses TravisCI as example of a CI pipeline.

### NodeJS

This application uses ExpressJS to provide a simple api endpoint and return some information about the app itself.

### Application settings

The application settings can be configured through the [config.yaml](config.yaml) file. There you can set the app name, version number and gcp/gke settings in case of a kubernetes deployment.

### Multi-stage build

The multi-stage build will help on having a minimal final container image containing only required files to run the application. The Dockerfile is available [here](Dockerfile)

Stages:

- build
  - install all necessary npm packages including dev ones
  - run linting
  - run tests
  - clear dev npm packages
- final
  - copy `node_modules` folder
  - copy `server.js` file (entry point)
  - copy applcation files

### TravisCI

TravisCI example pipeline has been provided with image build and push to a repository. This pipeline is configured to push the image to DockerHub. CI configuration can be found at `.travis.yml` file [here](.travis.yml).

- build (will always run for all branch pushes and pull request)
will execute lint, tests and build the container (tests are part of the container build)
- push (will only run for master)
will build container, tag with git commit hash and push to dockerhub.com

### Kubernetes

A deployment and a service manifest is provided through a custom helm template that will automatically get the last image tag generated and can be deployed to a local or remote kubernetes cluster.

Tests can be done through a port-forward on the service created.

`kubectl port-forward service/<app-name> <service-port>:<host-port>`

## Running Instructions

This project is based on the 3musketeers (https://3musketeers.io/) approach, which is simply using a combination of Makefile + Docker + docker-compose. This combination provides consistency across multiple CI/CD tooling as your scripts will be all abstracted by the Makefile and you won't be locked to the tool language. Also makes it easier to run it locally as Docker images will contain all the requirements to build and run the application.

### Requirements

- [Docker](https://docs.docker.com/install/)
- [docker-compose](https://docs.docker.com/compose/install/)

### Makefile config

Please do a quick review on the [config.yaml](config.yaml) file and configure accordingly to your environment before running make commands.

Un-comment the `.SILENT:` line if you desire a more verbose logging from Makefile.

It might take a few seconds to start running due to `docker-compose` image pulling.

### Targets

- `make build`

Build local image, tag with `GIT_SHORT_SHA` and update `latest` tag.

- `make push`

Push recently built image to local or remote registry (settings on [config.yaml](config.yaml)).

- `make run`

Run local image.

- `make test`

This target will run `make build` and `make run`

- `make deploy`

Runs a custom helm template with config values from [config.yaml](config.yaml) and deploy a Deployment and a Service to your currently configure Kubernetes (kubeconfig) context.

#### MAKE SURE TO BE POINTING TO THE RIGHT CLUSTER.

PS.: You might need to adjust the `_auth` target on the `Makefile` if your cluster is private.

If your cluster does not have ingress configured, you can test the service running:

`kubectl port-forward service/application-name host-port:host-port`

or 

`make forward`


## Manual instructions

If you wish to run docker commands by yourself, here is a brief explanation of most common commands:

`docker build -t <tag-name>:<tag-version> .`

|Argument|Description|Example
|-|-|-|
|--build-arg|Argument variables to be injected to the build|COMMIT_HASH=123456789|
|-t|Tag the container being build|test-api:12345|
|.|Folder where the files to be built are|-|

Example: `docker build -t test-api:12345 .`

#### Run

```
docker run -d \
	-p <SERVICE_PORT>:<HOST_PORT> \
	-e SERVICE_NAME=<SERVICE_NAME> \
	-e SERVICE_PORT=<SERVICE_PORT> \
	-e SERVICE_VERSION=<SERVICE_VERSION> \
	-e LOG_LEVEL=<LOG_LEVEL> \
	-e GIT_SHA=<GIT_SHA> \
	<CONTAINER_IMAGE>
```

|Argument|Description|Example
|-|-|-|
|-d|Detachable mode - run in background|-|
|-e port=`<app-port>`|Port which the application will be listening|`-e port=3000`|
|-p `<SERVICE_PORT>:<HOST_PORT>`|Expose a host port to a container port|`-p 5000:3000`|
|-e SERVICE_NAME=<SERVICE_NAME>|Application name|`test-api`|
|-e SERVICE_PORT=<SERVICE_PORT>|Application port running inside container|`5000`|
|-e SERVICE_VERSION=<SERVICE_VERSION>|Application version|`1.0.0`|
|-e LOG_LEVEL=<LOG_LEVEL>|Log level|`info` `debug` `error`|
|-e GIT_SHA=<GIT_SHA>|GIT short SHA|`12345`|
|`<CONTAINER_IMAGE>`|Image to run|test-api:12345|

Example: 
```
docker run -d \
  -p 3000:3000 \
  -e SERVICE_NAME=test-api \
  -e SERVICE_PORT=5000 \
  -e SERVICE_VERSION=1.0.0 \
  -e LOG_LEVEL=info \
  -e GIT_SHA=12345 \
  test-api:12345
```

#### Push

Depending on which repository the image is being pushed to an authentication might be required.

`docker push <CONTAINER_IMAGE>`

Example: `docker push test-api:12345`

#### Test

From terminal

`curl localhost:5000/info`

## What Is Next

This example is a basic demonstration of what can be done using different technologies like NodeJS, Docker and Continuous Integration pipelines.

For a production readiness solution a few changes would be necessary but not limited to:

- npm packages and containers artefacts used and stored only at private repositories like Artifactory which can be scanned and signed by Security
- pipelines to adopt binary authentication to guarantee atestation throughout its life-cycle
- continuous deployment strategies like blue/green or canary
- store any secrets on a proper management tool like sealed-secrets or vault
- CI solution based on hosted agents within the local network and with least privilege access
- Configure repository to only accept a Pull Request after receiving a pass from the CI pipeline
- npm packages using fixed version numbers
- integration tests on every commit to reduce the chances of broken code moving forward
- adopt a branching strategy and restrict `master` direct commits.
- GIT commit sha extracted from GitHub API instead of local files
