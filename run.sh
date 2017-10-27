#!/bin/bash -e

# Print command before executing it - easier for looking at logs
set -o xtrace

# CRUCIAL for cmsrel, etc as aliases not expanded in non-interactive shells
shopt -s expand_aliases

# Check CVMSFS setup correctly
# Need to manually setup STIECONF as we're not a proper site

# ls /cvmfs/cms.cern.ch/
sudo mkdir -p /cvmfs/cms.cern.ch
mkdir -p /etc/cvmfs/config.d/
cp default.local /etc/cvmfs/default.local
cp cms.cern.ch.local /etc/cvmfs/config.d/cms.cern.ch.local
# service autofs restart
# cvmfs_config reload
cvmfs_config setup
# cvmfs_config chksetup
# test this actually links
sudo mount -t cvmfs cms.cern.ch /cvmfs/cms.cern.ch

ls /cvmfs/cms.cern.ch/
ls -l /cvmfs/cms.cern.ch/SITECONF/local/

# Store top location
WORKDIR=`pwd`

export CMSSW_GIT_REFERENCE=$WORKDIR/cmssw.git

# Get number of processors for make
# Sometimes compiling will error with c++: internal compiler error: Killed (program cc1plus)
# This means you need to reduce the number passed onto make
# np=$(grep -c ^processor /proc/cpuinfo)
# let np/=2
# export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"
export MAKEFLAGS="-j2"

# You can use dummy values here if not pushing, but is required for pulling
git config --global user.name "Joe Bloggs"
git config --global user.email "a@b.c"
git config --global user.github "testUHH"

# time source setup_sframe.sh

# Get a CMSSW release
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
CMSSW_VERSION=CMSSW_8_0_24_patch1
eval `cmsrel $CMSSW_VERSION`
cd $CMSSW_VERSION/src
eval `scramv1 runtime -sh`

# git cms-init -y
# git cms-merge-topic -u cms-met:fromCMSSW_8_0_20_postICHEPfilter
cp $WORKDIR/test_cfg.py .
cp $WORKDIR/ttbar_miniaodsim_summer16_v2_PUMoriond17_80X.root .
scram build $MAKEFLAGS
# This won't work due to Valid site-local-config not found at /cvmfs/cms.cern.ch/SITECONF/local/JobConfig/site-local-config.xml
cmsRun test_cfg.py
edmDumpEventContent patTuple.root

exit

# Setup custom FastJet
cd ${WORKDIR}
time source setup_fastjet.sh

# Now setup all packages, etc
cd $CMSSW_VERSION/src
git cms-init -y
# Additional MET filters
git cms-merge-topic -u cms-met:fromCMSSW_8_0_20_postICHEPfilter
# why this? why not gregor's PR? https://github.com/cms-sw/cmssw/pull/14837
git cms-merge-topic gkasieczka:test-httv2-8014
git cms-merge-topic ikrav:egm_id_80X_v2
# Do we actually need these?
# git-cms-addpkg RecoBTag
# git-cms-addpkg PhysicsTools

FJINSTALL=`fastjet-config --prefix`
sed -i "s|use_common_bge_for_rho_and_rhom|set_common_bge_for_rho_and_rhom|g" RecoJets/JetProducers/plugins/FastjetJetProducer.cc

# Fix fastjet contrib
# versions are defined in setup_fastjet.sh
FJCONTRIBVER="1.025"
FJCONFIG_TOOL_FILE=$CMSSW_BASE/config/toolbox/$SCRAM_ARCH/tools/selected/fastjet-contrib.xml
sed -i "s|1.020|$FJCONTRIBVER|g" $FJCONFIG_TOOL_FILE
sed -i "s|/cvmfs/cms.cern.ch/$SCRAM_ARCH/external/fastjet-contrib/$FJCONTRIBVER|$FJINSTALL|g" $FJCONFIG_TOOL_FILE

# Fix Fastjet
FJVER=`fastjet-config --version`
FJ_TOOL_FILE=$CMSSW_BASE/config/toolbox/$SCRAM_ARCH/tools/selected/fastjet.xml
sed -i "s|3.1.0|$FJVER|g" $FJ_TOOL_FILE
sed -i "s|/cvmfs/cms.cern.ch/$SCRAM_ARCH/external/fastjet/$FJVER|$FJINSTALL|g" $FJ_TOOL_FILE
scram b clean
scram b $MAKEFLAGS

cd $CMSSW_BASE/external/$SCRAM_ARCH/
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
cd $CMSSW_BASE/src/UHH2
make $MAKEFLAGS