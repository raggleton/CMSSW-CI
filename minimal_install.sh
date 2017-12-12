#!/bin/bash -e

set -u

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc630
eval `cmsrel CMSSW_9_4_1`
cd CMSSW_9_4_1/src
eval `scramv1 runtime -sh`
git cms-init
scram b -j 20
cd $CMSSW_BASE/src
git clone -b RunII_94X_v1 https://github.com/UHH2/UHH2.git
cd UHH2
git clone https://github.com/cms-jet/JECDatabase.git
