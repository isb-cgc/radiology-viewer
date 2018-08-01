#!/bin/bash

set -x

./mount_docker-db.sh
#./start_nginx.sh
./start_ohif.sh

echo "started"
