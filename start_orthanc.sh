#!/bin/bash

set -x

pushd orthanc
sudo docker-compose up --build -d
popd
