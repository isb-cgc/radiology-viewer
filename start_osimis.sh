#!/bin/bash

set -x

pushd osimis
docker-compose up --build -d
popd
