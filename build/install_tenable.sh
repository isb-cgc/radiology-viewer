#!/bin/bash

set -x

# Install Tenable package (package previously downloaded from tenable.io)                                                           
sudo gsutil cp  gs://isb-cgc-misc/compute-helpers/NessusAgent-7.0.2-debian6_amd64.deb /tmp
sudo  dpkg -i /tmp/NessusAgent-7.0.2-debian6_amd64.deb

# Link agent (key obtained from tenable.io web app)                                                                                 
sudo /opt/nessus_agent/sbin/nessuscli agent link --key=***REMOVED*** --cloud

# Start agent                                                                                                                       
sudo /etc/init.d/nessusagent start
