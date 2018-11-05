#!/bin/bash

set -x

PROJECT=$1

./mount_dicom-db.sh
#./start_nginx.sh
./start_ohif.sh $PROJECT

echo "started"
