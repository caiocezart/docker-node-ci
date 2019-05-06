# Docker test with NodeJS + multi-stage build + TravisCI

# Table of Contents
  - [Introduction](#introduction)
    - [NodeJS](#nodejs)
    - [Multi-stage build](#multi-stage-build)
    - [TravisCI](#travisci)
  - [Instructions](#instructions)
    - [Build container](#build-container)
    - [Run container](#run-container)
    - [Test](#test)

## Introduction

This repository contains instructions on how to build a NodeJS container application using docker multi-stage build and also uses TravisCI as example of a CI pipeline.

### NodeJS

### Multi-stage build

The multi-stage build will help on having a minimal final container image containing only required files to run the application.

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

## Instructions

### Build container

`docker build -t <image-name-tag> .`

|Argument|Description|Example
|-|-|-|
|-t|Tag the container being build|my-container|

Example: `docker build -t my-container .`

### Run container

`docker run -e port=<app-port> -p <host-port>:<container-port> <image-name-tag>`

|Argument|Description|Example
|-|-|-|
|-d|Detachable mode - run in background|-|
|-e port=`<app-port>`|Port which the application will be listening|`-e port=3000`|
|-p `<host-port>:<container-port>`|Mapping a host port to a container port|`-p 5000:3000`|

Example: `docker run -d -e port=3000 -p 5000:3000 my-container`

### Test

From terminal

`curl localhost:5000/`