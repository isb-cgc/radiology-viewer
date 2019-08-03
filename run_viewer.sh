#!/bin/bash

set -x

PROJECT=$1
MACHINE_URL=$2

ls -la $HOME

./mount_dicom-db.sh

ls -la $HOME

#./start_nginx.sh
./start_ohif.sh $PROJECT $MACHINE_URL

ls -la $HOME

echo "started"
