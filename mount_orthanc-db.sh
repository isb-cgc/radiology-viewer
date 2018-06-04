#!/bin/bash

set -x

sudo mount -o discard,defaults /dev/disk/by-id/google-orthanc-db /mnt/disks/orthanc-db
#sudo mount -o discard,defaults /dev/disk/by-id/google-orthanc-index /mnt/disks/orthanc-index
