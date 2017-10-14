#!/bin/bash

yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
yum install -y cvmfs cvmfs-config-default
mkdir -p /etc/cvmfs
cvmfs_config setup
cp default.local /etc/cvmfs/default.local
cvmfs_config setup
mkdir -p /cvmfs/cms.cern.ch
mount -t cvmfs cms.cern.ch /cvmfs/cms.cern.ch
ls /cvmfs/cms.cern.ch/

export CMSSW_GIT_REFERENCE=/app/cmssw.git

source /cvmfs/cms.cern.ch/cmsset_default.sh
# cmsrel CMSSW_9_2_13
# cd CMSSW_9_2_13/src
# cmsenv

cmsrel CMSSW_8_0_28
cd CMSSW_8_0_28/src
cmsenv
git config --global user.name "Joe Bloggs"
git config --global user.email "a@b.c"
git config --global user.github "jjjjjjj"

git cms-addpkg -y --https FWCore/Framework
scram build
