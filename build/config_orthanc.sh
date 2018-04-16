#!/bin/bash

set -x


sudo mkdir /etc/orthanc

### Run Orthanc to generate a config file that we will modify
sudo docker run --rm --entrypoint=cat jodogne/orthanc /etc/orthanc/orthanc.json > /tmp/orthanc.json
sudo cp /tmp/orthanc.json /etc/orthanc/orthanc.json

### Get the username/password from GCS
sudo gsutil cp gs://web-app-deployment-files/dev/dicom-viewer/user.txt user.txt
sudo gsutil cp gs://web-app-deployment-files/dev/dicom-viewer/pw.txt pw.txt
OUSER=$(<user.txt)
OPW=$(<pw.txt)
sudo rm user.txt pw.txt

### Change the authorization in the config file
sudo sed -ie "s/\"orthanc\" : \"orthanc\"/\"$OUSER\" : \"$OPW\"/" /etc/orthanc/orthanc.json

### Create the mount point for the DB, which we keep on a separate image that survives replacing the VM
sudo mkdir -p /mnt/disks/orthanc-db

