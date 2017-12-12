#!/bin/bash -e

echo "Doing post_install"
cd $WORKDIR

# Run after the install script to setup things correctly
rm -rf "$CMSSW_BASE/src/UHH2"
mv /app/UHH2 $CMSSW_BASE/src
ls $CMSSW_BASE/src

# Compile SFrame and UHH
cd "${WORKDIR}/SFrame"
source setup.sh
time make $MAKEFLAGS
cd "$CMSSW_BASE/src/UHH2"
ls
echo "I will scram build here"
./nothere
if [ ! -e "blah.txt" ];
then
	exit 1
fi
# time make $MAKEFLAGS