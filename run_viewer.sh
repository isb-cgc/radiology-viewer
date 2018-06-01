#!/bin/bash

set -x

./mount_orthanc-db.sh
#./start_nginx.sh
#./start_osimis.sh
./start_orthanc.sh
./start_ohif.sh

echo "started"
