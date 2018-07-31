#!/bin/bash

set -x

./mount_orthanc-db.sh
./start_nginx.sh
./start_ohif.sh

echo "started"
