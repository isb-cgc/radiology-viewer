#!/bin/bash
# This is script is called after the initial reboot of a camic-viewer VM.
# We want to execute run_viewer.sh as the same user that instantiated the VM.

set -x

PROGNAME=$(basename "$0")

if [ "$#" -ne 0 ]; then
    echo "Usage: ./$PROGNAME <quip-viewer version> <admin email> <ip addr> <server alias> <webapp>"
    exit 1;
fi

cd /home/dvproc/radiology-viewer

./run_viewer.sh 
