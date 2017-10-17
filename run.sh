#!/bin/bash

# CRUCIAL for cmsrel, etc as aliases not expanded in non-interactive shells
shopt -s expand_aliases

ls /cvmfs/cms.cern.ch/

export CMSSW_GIT_REFERENCE=/app/cmssw.git

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo $SCRAM_ARCH
alias cmsrel
export SCRAM_ARCH="slc6_amd64_gcc530"
eval `cmsrel CMSSW_8_0_28`
cd CMSSW_8_0_28/src
eval `scramv1 runtime -sh`

# You can use dummy values here if not pushing, but is required for pulling
git config --global user.name "Joe Bloggs"
git config --global user.email "a@b.c"
git config --global user.github "testUHH"

# Not necessary for the CMSSW config, but shows it works
git cms-addpkg -y --https RecoMET/METFilters
cp ../../test_cfg.py .
cp ../../ttbar_miniaodsim_summer16_v2_PUMoriond17_80X.root .
scram build -j9
cmsRun test_cfg.py
edmDumpEventContent patTuple.root
