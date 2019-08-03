#!/bin/bash

set -x

### Enable pulling ohif-viewer image from gcr
#sudo ln -s /snap/google-cloud-sdk/current/bin/docker-credential-gcloud /snap/bin/docker-credential-gcloud
export PATH=/snap/google-cloud-sdk/current/bin/:$PATH
gcloud beta auth configure-docker --quiet

pushd ~
git clone --branch ohif-d4c https://github.com/isb-cgc/ohif-viewer.git

#cd /ohif-viewer
#
### Build a docker image to run the viewer
### Note: the image is in gcr. Only rebuild if there is a change to source
#sudo docker build -t isb-cgc/ohif-viewer -f dockerfile .

popd
