#!/bin/bash -e

# Print command before executing it - easier for looking at logs
set -o xtrace

# CRUCIAL for cmsrel, etc as aliases not expanded in non-interactive shells
shopt -s expand_aliases

# Check CVMSFS setup correctly
ls /cvmfs/cms.cern.ch/

WORKDIR="/app"

export CMSSW_GIT_REFERENCE=/app/cmssw.git

# Get number of processors
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# You can use dummy values here if not pushing, but is required for pulling
git config --global user.name "Joe Bloggs"
git config --global user.email "a@b.c"
git config --global user.github "testUHH"

time source setup_sframe.sh

# # Not necessary for the CMSSW config, but shows it works
# git cms-addpkg -y --https RecoMET/METFilters
# cp ../../test_cfg.py .
# cp ../../ttbar_miniaodsim_summer16_v2_PUMoriond17_80X.root .
# scram build -j9
# # This won't work due to Valid site-local-config not found at /cvmfs/cms.cern.ch/SITECONF/local/JobConfig/site-local-config.xml
# cmsRun test_cfg.py
# edmDumpEventContent patTuple.root

# Get a CMSSW release
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
eval `cmsrel CMSSW_8_0_24_patch1`
cd CMSSW_8_0_24_patch1/src
eval `scramv1 runtime -sh`

# Setup custom FastJet
cd ${WORKDIR}
time source setup_fastjet.sh

# Now setup all packages, etc
cd CMSSW_8_0_24_patch1/src
git cms-init -y
git cms-merge-topic -u cms-met:fromCMSSW_8_0_20_postICHEPfilter
git cms-merge-topic gkasieczka:test-httv2-8014
git cms-merge-topic ikrav:egm_id_80X_v2
git-cms-addpkg RecoBTag
git-cms-addpkg PhysicsTools

FJINSTALL=`fastjet-config --prefix`
sed -i "s|use_common_bge_for_rho_and_rhom|set_common_bge_for_rho_and_rhom|g" RecoJets/JetProducers/plugins/FastjetJetProducer.cc
# Fix fastjet contrib
sed -i "s|1.020|1.030|g" $CMSSW_BASE/config/toolbox/slc6_amd64_gcc530/tools/selected/fastjet-contrib.xml
sed -i "s|/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/fastjet-contrib/1.030|$FJINSTALL|g" $CMSSW_BASE/config/toolbox/slc6_amd64_gcc530/tools/selected/fastjet-contrib.xml
# Fix Fastjet
sed -i "s|3.1.0|3.2.1|g" $CMSSW_BASE/config/toolbox/slc6_amd64_gcc530/tools/selected/fastjet.xml
sed -i "s|/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/fastjet/3.2.1|$FJINSTALL|g" $CMSSW_BASE/config/toolbox/slc6_amd64_gcc530/tools/selected/fastjet.xml
scram b clean
scram b $MAKEFLAGS
cd $CMSSW_BASE/external
cd slc6_amd64_gcc530/
git clone https://github.com/ikrav/RecoEgamma-ElectronIdentification.git data/RecoEgamma/ElectronIdentification/data
cd data/RecoEgamma/ElectronIdentification/data
git checkout egm_id_80X_v1
cd $CMSSW_BASE/src
git clone -b RunII_80X_v3 https://github.com/UHH2/UHH2.git
cd UHH2
git clone https://github.com/cms-jet/JECDatabase.git

# Compile SFrame and UHH
cd ${WORKDIR}/SFrame
source setup.sh
make $MAKEFLAGS
cd ${WORKDIR}/CMSSW_8_0_24_patch1/src/UHH2
make $MAKEFLAGS