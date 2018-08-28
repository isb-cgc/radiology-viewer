#!/bin/bash

set -x

pushd ~/ohif-viewer

###Build a docker image to run the viewer
sudo docker build -t isb-cgc/ohif-viewer -f dockerfile .

popd
