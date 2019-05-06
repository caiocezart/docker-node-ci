# Docker test with NodeJS + multi-stage build + TravisCI

## Table of Contents
  - [Introduction](#introduction)
    - [NodeJS](#nodejs)
    - [Multi-stage build](#multi-stage-build)
    - [TravisCI](#travisci)
    - [GitHub](#github)
  - [Manual Instructions](#manual-instructions)
    - [Run Application Locally](#run-application-locally)
    - [Build](#build)
    - [Run](#run)
    - [Push](#push)
    - [Test](#test)
  - [What is Next](#what-is-next)

## Introduction

This repository contains instructions on how to build a NodeJS container application using docker multi-stage build and also uses TravisCI as example of a CI pipeline.

### NodeJS

This application uses ExpressJS to provide a simple api endpoint and return some information about the app itself.

### Multi-stage build

The multi-stage build will help on having a minimal final container image containing only required files to run the application. The Dockerfile is available [here](Dockerfile)

Stages:

- build
  - install all necessary npm packages including dev ones
  - run linting
  - generate a file with the latest git commit hash
  - generate a file with the application version
  - run tests
  - clear dev npm packages
- final
  - copy `npm_modules` folder
  - copy `server.js` file (entry point)
  - copy routes files
  - copy info files

### TravisCI

TravisCI configuration can be accessed at `.travis.yml` file [here](.travis.yml) and the pipeline consists in two stages:

- build (will always run for all branch pushes and pull request)
  - will execute tests and build the container (tests are part of the container build)
- push (will only run for master)
  - will build container and push to github.com

### GitHub

Master branch will only allow a pull request merge once TravisCI reports succesfull build and push for a commit.

## Manual Instructions

### Run application locally

`npm install && port=5000 npm start`

### Build

`docker build --build-arg COMMIT_HASH=<git-commit-hash> -t <tag-name>:<tag-version> .`

|Argument|Description|Example
|-|-|-|
|--build-arg|Argument variables to be injected to the build|COMMIT_HASH=123456789|
|-t|Tag the container being build|my-container:1.0|
|.|Folder where the files to be built are||

Example: `docker build --build-arg COMMIT_HASH=123456789 -t my-container:1.0 .`

### Run

`docker run -d -e port=<app-port> -p <host-port>:<container-port> <tag-name>:<tag-version>`

|Argument|Description|Example
|-|-|-|
|-d|Detachable mode - run in background|-|
|-e port=`<app-port>`|Port which the application will be listening|`-e port=3000`|
|-p `<host-port>:<container-port>`|Expose a host port to a container port|`-p 5000:3000`|
|`<tag-name>:<tag-version>`|Image to run|my-container:1.0|

Example: `docker run -d -e port=3000 -p 3000:3000 my-container:1.0`

### Push

Depending on which repository the image is being pushed to an authentication might be required.

`docker push `<tag-name>:<tag-version>`

Example: `docker push my-container:1.0`

### Test

From terminal

`curl localhost:5000/`

## What Is Next

This example is a basic demonstration of what can be done using different technologies like NodeJS, Docker and Continuous Integration pipelines.

For a production readiness solution a few changes would be necessary:

- npm packages and containers artefacts used and stored only at private repositories like Artifactory
- npm packages using fixed version numbers
- integration tests on every commit to reduce the chances of broken code moving forward
- adopt a branching strategy and restrict `master` direct commits. E.g: feature and release branches
- usage of a third party tool to manage secrets instead of environment variables
- CI solution based on hosted agents within the local network and with least privilege access
- GIT commit sha extracted from GitHub API instead of local files