#!/usr/bin/env bash

# Some better practices:
set -o xtrace # Print command before executing it - easier for looking at logs
set -o errexit # make your script exit when a command fails.
set -o pipefail # exit status of the last command that threw a non-zero exit code is returned
# set -o nounset # exit when your script tries to use undeclared variables. can't use as external scripts will fail

# CRUCIAL for cmsrel, etc as aliases not expanded in non-interactive shells
shopt -s expand_aliases

# Check CVMSFS setup correctly
# Need to manually setup STIECONF as we're not a proper site

# ls /cvmfs/cms.cern.ch/
# sudo mkdir -p /cvmfs/cms.cern.ch
# mkdir -p /etc/cvmfs/config.d/
# cp default.local /etc/cvmfs/default.local
# cp cms.cern.ch.local /etc/cvmfs/config.d/cms.cern.ch.local
# service autofs restart
# cvmfs_config reload
# cvmfs_config setup
# cvmfs_config chksetup
# test this actually links
# mount -t cvmfs cms.cern.ch /cvmfs/cms.cern.ch

# Check CVMSFS
ls /cvmfs/cms.cern.ch/
ls -l /cvmfs/cms.cern.ch/SITECONF/local/

# Store top location
WORKDIR=$(pwd)

export CMSSW_GIT_REFERENCE=$WORKDIR/cmssw.git

# Get number of processors for make
# Sometimes compiling will error with c++: internal compiler error: Killed (program cc1plus)
# This means you need to reduce the number passed onto make
# np=$(grep -c ^processor /proc/cpuinfo)
# let np/=2
export MAKEFLAGS
MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"
# export MAKEFLAGS="-j2"

# You can use dummy values here if not pushing, but is required for pulling
git config --global user.name "Joe Bloggs"
git config --global user.email "a@b.c"
git config --global user.github "testUHH"

# Get a CMSSW release
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
CMSSW_VERSION=CMSSW_8_0_24_patch1
eval "$(cmsrel $CMSSW_VERSION)"
cd $CMSSW_VERSION/src
eval "$(scramv1 runtime -sh)"

# git cms-init -y
cp $WORKDIR/test_cfg.py .
cp $WORKDIR/ttbar_miniaodsim_summer16_v2_PUMoriond17_80X.root .
scram build $MAKEFLAGS
# This won't work due to Valid site-local-config not found at /cvmfs/cms.cern.ch/SITECONF/local/JobConfig/site-local-config.xml
cmsRun test_cfg.py
edmDumpEventContent patTuple.root

