#!/usr/bin/env bash

# Some better practices:
set -o xtrace # Print command before executing it - easier for looking at logs
set -o errexit # make your script exit when a command fails.
set -o pipefail # exit status of the last command that threw a non-zero exit code is returned
# set -o nounset # exit when your script tries to use undeclared variables. can't use as external scripts will fail

# CRUCIAL for cmsrel, etc as aliases not expanded in non-interactive shells
shopt -s expand_aliases

# Check CVMFS
ls /cvmfs/cms.cern.ch/

WORKDIR=$(pwd)

export CMSSW_GIT_REFERENCE=$WORKDIR/cmssw.git

# Get number of processors for make
MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# You can use dummy values here if not pushing, but is required for pulling
git config --global user.name "Joe Bloggs"
git config --global user.email "a@b.c"
git config --global user.github "test"

# Get a CMSSW release
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
CMSSW_VERSION=CMSSW_8_0_24_patch1
eval "$(cmsrel $CMSSW_VERSION)"
cd $CMSSW_VERSION/src
eval "$(scramv1 runtime -sh)"

cp $WORKDIR/test_cfg.py .
# cp $WORKDIR/ttbar_miniaodsim_summer16_v2_PUMoriond17_80X.root .
scram build $MAKEFLAGS

# cmsRun won't work out of the box due to Valid site-local-config not found at /cvmfs/cms.cern.ch/SITECONF/local/JobConfig/site-local-config.xml
# Looks for site-local-config.xml from CMS_PATH...let's hack it
# Don't worry, this won't affect anything else
export CMS_PATH=/cvmfs/cms-ib.cern.ch/
klist
scp ${KRB_USERNAME}@lxplus.cern.ch:/afs/cern.ch/work/${KRB_USERNAME:0:1}/${KRB_USERNAME}/ExampleRootFiles/2017B_MINIAOD_DATA/2017B_JetHT_EC3BBDF0-C7CD-E711-A70B-0025905A6092_small.root 2017B_JetHT_EC3BBDF0-C7CD-E711-A70B-0025905A6092_small.root
cmsRun test_cfg.py
edmDumpEventContent patTuple.root

