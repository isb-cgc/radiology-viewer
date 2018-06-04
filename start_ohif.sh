#!/bin/bash

set -x

pushd ./Viewers/OHIFViewer

METEOR_PACKAGE_DIRS="../Packages" meteor --settings ../config/orthancDICOMWeb.json

popd
