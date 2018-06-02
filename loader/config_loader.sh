#!/bin/bash
# Configuration needed by the script in ./load

set -x

ME=$USER

# For some reason, ~/.gsutil is owned by root
sudo chmod -R $ME:$ME ~/.gsutil
 
# Install a few additional components
sudo apt-get install -y python-pip unzip
sudo pip install httplib2