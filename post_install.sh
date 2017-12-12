#!/bin/bash -e

set -u

echo "Doing post_install"

# Run after the install script to setup things correctly
rm -rf "$CMSSW_BASE/src/UHH2"
mv $WORKDIR/UHH2 $CMSSW_BASE/src
ls $CMSSW_BASE/src

# Compile SFrame and UHH
cd "${WORKDIR}/SFrame"
source setup.sh
time make $MAKEFLAGS
cd "$CMSSW_BASE/src/UHH2"
ls
echo "I will scram build here"
# time make $MAKEFLAGS