#!/bin/bash

set -x

CONFIG_BUCKET=$1

# Install Tenable package (package previously downloaded from tenable.io)                                                           
sudo gsutil cp  gs://isb-cgc-misc/compute-helpers/NessusAgent-7.0.2-debian6_amd64.deb /tmp
sudo  dpkg -i /tmp/NessusAgent-7.0.2-debian6_amd64.deb

# Get the key from GCS
sudo gsutil cp gs://$CONFIG_BUCKET/tenable_key.txt tenable_key.txt
KEY=$(<tenable_key.txt)
sudo rm tenable_key.txt


# Link agent (key obtained from tenable.io web app)                                                                                 
sudo /opt/nessus_agent/sbin/nessuscli agent link --key=$KEY --cloud

# Start agent                                                                                                                       
sudo /etc/init.d/nessusagent start
