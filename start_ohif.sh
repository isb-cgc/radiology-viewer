#!/bin/bash

set -x

pushd /home/dvproc/Viewers

METEOR_PACKAGE_DIRS="../Packages" meteor --settings ../config/orthancDICOMWeb.json
