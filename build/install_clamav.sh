#!/bin/bash

set -x

## Install clamav                                                                                                                     
sudo apt install -y clamav clamav-daemon                                                                                           
wget https://raw.githubusercontent.com/isb-cgc/ISB-CGC-Cron/master/gce_vm_tasks/virus_scan.sh?token=AZWqo20xg5GkQJdIYtVRo_O5GZmZezWEks5a_LKtwA%3D%3D -O virus_scan

chmod 0755 virus_scan

sudo cp virus_scan /etc/cron.daily/ 

sudo sed -ie 's/Checks 24/Checks 2/' /etc/clamav/freshclam.conf
