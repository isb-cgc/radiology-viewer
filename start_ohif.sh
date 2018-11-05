#!/bin/bash

set -x

export PROJECT=$1

pushd ~/ohif-viewer
docker-compose -f docker-compose.all.yml -p dcm4chee up -d
