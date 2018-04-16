#!/bin/bash

set -x

pushd osimis
sudo docker-compose up --build -d
popd
