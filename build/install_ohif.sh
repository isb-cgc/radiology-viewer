#!/bin/bash

set -x

pushd ~/ohif-viewer

###Build a docker image to run the viewer
docker build -t isb-cgc/ohif-viewer -f dockerfile .

popd
