#!/bin/bash
#Install the OHIF viewer

set -x

# Get Viewer 
git clone git@github.com:OHIF/Viewers.git

# Install meteor
curl https://install.meteor.com/ | sh

cd Viewers

# Instruct Meteor to install all dependent NPM Packages
METEOR_PACKAGE_DIRS="../Packages" meteor npm install
