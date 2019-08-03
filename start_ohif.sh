#!/bin/bash

set -x

export PROJECT=$1
export PATH=/snap/google-cloud-sdk/current/bin/:$PATH
pushd ~/ohif-viewer
docker-compose -f docker-compose.all.yml -p dcm4chee up -d
