#!/bin/bash

set -x

./mount_dicom-db.sh
#./start_nginx.sh
./start_ohif.sh

echo "started"
