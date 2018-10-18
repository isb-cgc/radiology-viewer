#!/bin/bash
# This is script is called after the initial reboot of a dicom-viewer VM.
# We want to execute run_viewer.sh as the same user that instantiated the VM.

# $1=VIEWER_VERSION
# $2=WEBAPP

set -x

PROGNAME=$(basename "$0")

if [ "$#" -ne 2 ]; then
    echo "Usage: ./$PROGNAME <quip-viewer version> <server alias> <webapp>"
    exit 1;
fi

cd /home/dvproc/radiology-viewer

./run_viewer.sh $1 $2
