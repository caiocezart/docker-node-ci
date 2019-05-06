# Docker test with NodeJS + multi-stage build + TravisCI

# Table of Contents
- [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
    - [NodeJS](#nodejs)
    - [Multi-stage build](#multi-stage-build)
    - [TravisCI](#travisci)
  - [Instructions](#instructions)
    - [Build container](#build-container)
    - [Run container](#run-container)
    - [Test](#test)

## Introduction

This repository contains instructions on how to build a NodeJS container application using docker multi-stage build and also uses TravisCI as example of CI pipeline.

### NodeJS

### Multi-stage build
This example will:

- install all necessary npm packages, run tests
- copy over the `npm_modules` folder and the node start point file `server.js`

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