#!/bin/bash

set -x

## Install clamav                                                                                                                     
sudo apt install -y clamav clamav-daemon                                                                                           
wget https://raw.githubusercontent.com/isb-cgc/ISB-CGC-Cron/master/gce_vm_tasks/virus_scan.sh?token=AKBQyIdXio073v7hMOxWHnXCCp#Dqxgl7ks5alcxdwA%3D%3D -O virus_scan
chmod 0755 virus_scan                                                                                                              
sudo cp virus_scan /etc/cron.daily/                                                                                                
sudo sed -ie 's/Checks 24/Checks 2/' freshclam.conf                                                                                
