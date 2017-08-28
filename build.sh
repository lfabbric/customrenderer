#!/bin/bash

# set version
VERSION=1.0.0

# set file name
ZIPFILE=${PWD##*/}-$VERSION.zip

# remove the existing zip file
if [ ! -d build ]; then
    mkdir build
fi
rm -f build/$ZIPFILE
cd src

# load in the basic plugin files
zip ../build/$ZIPFILE *
