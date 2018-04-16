#!/bin/bash
# This is script is called after the initial reboot of a camic-viewer VM.
# We want to execute run_viewer.sh as the same user that instantiated the VM.

# $1=VIEWER_VERSION
# $2=SERVER_ADMIN
# $3=SERVER_NAME
# $4=SERVER_ALIAS
# $5=WEBAPP

set -x

PROGNAME=$(basename "$0")

if [ "$#" -ne 5 ]; then
    echo "Usage: ./$PROGNAME <quip-viewer version> <admin email> <ip addr> <server alias> <webapp>"
    exit 1;
fi

cd /home/dvproc/radiology-viewer

./run_viewer.sh $1 $2 $3 $4 $5
