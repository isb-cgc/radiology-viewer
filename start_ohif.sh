#!/bin/bash

set -x

pushd ~/ohif-viewer
docker-compose -f docker-compose.all.yml -p dcm4chee up -d
