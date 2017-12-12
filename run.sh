#!/usr/bin/env bash

# Some better practices:
set -o xtrace # Print command before executing it - easier for looking at logs
set -o errexit # make your script exit when a command fails.
set -o pipefail # exit status of the last command that threw a non-zero exit code is returned
# set -o nounset # exit when your script tries to use undeclared variables. can't use as external scripts will fail

# CRUCIAL for cmsrel, etc as aliases not expanded in non-interactive shells
shopt -s expand_aliases

getToolVersion() {
    # Get CMSSW tool version using scram
    # args: <toolname>
    local toolname="$1"
    scram tool info "$toolname" | grep -i "Version : " | sed "s/Version : //"
}

setGitSetting() {
    # Check if git config setting is blank, if so set it to a value
    # args: <setting name> <new value>
    settingName="$1"
    newValue="$2"
    ans=$(git config "$settingName")
    if [ "$ans" == "" ]
    then
        echo "git $settingName not set - setting it to $newValue"
        git config "$settingName" "$newValue"
    fi
}

# Check CVMSFS
ls /cvmfs/cms.cern.ch/

# Store top location
WORKDIR=$(pwd)

export CMSSW_GIT_REFERENCE=$WORKDIR/cmssw.git

# Get number of processors for make
# Sometimes compiling will error with c++: internal compiler error: Killed (program cc1plus)
# This means you need to reduce the number passed onto make
# np=$(grep -c ^processor /proc/cpuinfo)
# let np/=2
export MAKEFLAGS="-j9"
MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

git config -l --local

# Required for pulling
setGitSetting "user.name" "Joe Bloggs"
setGitSetting "user.email" "a@b.c"
setGitSetting "user.github" "testUHH"

# Get a CMSSW release - need to do this first to get ROOT, compilers, etc
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
CMSSW_VERSION=CMSSW_8_0_24_patch1
eval "$(cmsrel $CMSSW_VERSION)"
cd $CMSSW_VERSION/src
eval "$(scramv1 runtime -sh)"

# Setup SFrame
cd "${WORKDIR}"
FJ_VER="3.2.1"
FJCONTRIB_VER="1.025"
time source setup_sframe.sh "$FJ_VER" "$FJCONTRIB_VER"

# Setup custom FastJet
cd "${WORKDIR}"

time source setup_fastjet.sh

# Now setup all packages, etc
cd $CMSSW_VERSION/src
time git cms-init -y
# Additional MET filters
time git cms-merge-topic -u cms-met:fromCMSSW_8_0_20_postICHEPfilter
# why this? why not gregor's PR? https://github.com/cms-sw/cmssw/pull/14837
time git cms-merge-topic gkasieczka:test-httv2-8014
time git cms-merge-topic ikrav:egm_id_80X_v2
# Do we actually need these?
# git-cms-addpkg RecoBTag
# git-cms-addpkg PhysicsTools

sed -i "s|use_common_bge_for_rho_and_rhom|set_common_bge_for_rho_and_rhom|g" RecoJets/JetProducers/plugins/FastjetJetProducer.cc

# Fix fastjet contrib
# CMSSW splits fastjet-contrib into 2 parts - the fragile lib part ("fastjet-contrib")
# and the other libs ("fastjet-contrib-archive")
# We have to update both
OLD_FJCONTRIB_VER=$(getToolVersion fastjet-contrib)
FJCONFIG_TOOL_FILE=$CMSSW_BASE/config/toolbox/$SCRAM_ARCH/tools/selected/fastjet-contrib.xml
FJINSTALL=$(fastjet-config --prefix)
sed -i "s|$OLD_FJCONTRIB_VER|$FJCONTRIB_VER|g" "$FJCONFIG_TOOL_FILE"
sed -i "s|/cvmfs/cms.cern.ch/$SCRAM_ARCH/external/fastjet-contrib/$FJCONTRIB_VER|$FJINSTALL|g" "$FJCONFIG_TOOL_FILE"
cat "$FJCONFIG_TOOL_FILE"

OLD_FJCONTRIBARCHIVE_VER=$(getToolVersion fastjet-contrib-archive)
FJCONFIG_ARCHIVE_TOOL_FILE=$CMSSW_BASE/config/toolbox/$SCRAM_ARCH/tools/selected/fastjet-contrib-archive.xml
sed -i "s|$OLD_FJCONTRIBARCHIVE_VER|$FJCONTRIB_VER|g" "$FJCONFIG_ARCHIVE_TOOL_FILE"
sed -i "s|/cvmfs/cms.cern.ch/$SCRAM_ARCH/external/fastjet-contrib/$FJCONTRIB_VER|$FJINSTALL|g" "$FJCONFIG_ARCHIVE_TOOL_FILE"
cat "$FJCONFIG_ARCHIVE_TOOL_FILE"

# Fix Fastjet
OLD_FJ_VER=$(getToolVersion fastjet)
FJ_TOOL_FILE=$CMSSW_BASE/config/toolbox/$SCRAM_ARCH/tools/selected/fastjet.xml
sed -i "s|$OLD_FJ_VER|$FJ_VER|g" "$FJ_TOOL_FILE"
sed -i "s|/cvmfs/cms.cern.ch/$SCRAM_ARCH/external/fastjet/$FJ_VER|$FJINSTALL|g" "$FJ_TOOL_FILE"
cat "$FJ_TOOL_FILE"

# Important - setup the updated tool locations
scram setup fastjet
scram setup fastjet-contrib
scram setup fastjet-contrib-archive

scram b clean
time scram b $MAKEFLAGS

cd "$CMSSW_BASE/external/$SCRAM_ARCH/"
git clone https://github.com/ikrav/RecoEgamma-ElectronIdentification.git data/RecoEgamma/ElectronIdentification/data
cd data/RecoEgamma/ElectronIdentification/data
git checkout egm_id_80X_v1
cd "$CMSSW_BASE/src"
git clone -b RunII_80X_v3 https://github.com/UHH2/UHH2.git
cd UHH2
git clone https://github.com/cms-jet/JECDatabase.git

# Fix Makefile to point to correct fastjet
mv "$WORKDIR/coreMakefile" "$CMSSW_BASE/src/UHH2/core/Makefile"
cat "$CMSSW_BASE/src/UHH2/core/Makefile"
# Fix Makefile to point to be more generic
mv "$WORKDIR/commonMakefile" "$CMSSW_BASE/src/UHH2/common/Makefile"
cat "$CMSSW_BASE/src/UHH2/common/Makefile"

# Compile SFrame and UHH
cd "${WORKDIR}/SFrame"
source setup.sh
time make $MAKEFLAGS
cd "$CMSSW_BASE/src/UHH2"
time make $MAKEFLAGS
