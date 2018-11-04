#!/bin/bash

set -x

pushd ~
git clone --branch ohif-d4c https://github.com/isb-cgc/ohif-viewer.git

cd /ohif-viewer

### Build a docker image to run the viewer
sudo docker build -t isb-cgc/ohif-viewer -f dockerfile .

popd
