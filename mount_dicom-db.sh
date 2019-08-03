#!/bin/bash

set -x

sudo mount -o discard,defaults /dev/disk/by-id/google-dicom-db /mnt/disks/dicom-db
