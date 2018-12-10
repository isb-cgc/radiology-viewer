#!/bin/bash

set -x

sudo mount -o discard,defaults /dev/disk/by-id/google-dicom-db /mnt/disks/dicom-db
sudo mount -o discard,defaults /dev/disk/by-id/google-dicom-index /mnt/disks/dicom-index