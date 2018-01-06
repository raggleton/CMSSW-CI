#!/usr/bin/env bash

# Some better practices:
set -o xtrace # Print command before executing it - easier for looking at logs
set -o errexit # make your script exit when a command fails.
set -o pipefail # exit status of the last command that threw a non-zero exit code is returned
# set -o nounset # exit when your script tries to use undeclared variables. can't use as external scripts will fail

# CRUCIAL for cmsrel, etc as aliases not expanded in non-interactive shells
shopt -s expand_aliases

source /cvmfs/cms.cern.ch/cmsset_default.sh
ls /etc/
mkdir -p /etc/cvmfs/config.d/


# Hack for CMSSW bug (?)
ln -s /cvmfs/cms.cern.ch/SITECONF /etc/cvmfs/SITECONF

# Avoid xroot client warnings
touch /etc/profile.d/xrootd-protocol.sh
echo '
export XrdSecPROTOCOL=unix
' > /etc/profile.d/xrootd-protocol.sh


# Manual SITECONF, ideally at some point part of /cvmfs/cms.cern.ch
mkdir -p /etc/cms/SITECONF/T2_UK_London_IC/{JobConfig,PhEDEx}
ln -s T2_UK_London_IC /etc/cms/SITECONF/local
echo '
<storage-mapping>
  <lfn-to-pfn protocol="root" destination-match=".*"
    path-match="(.*)" result="root://eospublic.cern.ch/$1"/>
  <lfn-to-pfn protocol="xrootd" destination-match=".*" chain="root"
    path-match="(.*)" result="$1"/>

  <!-- fallback xrootd rules -->
  <lfn-to-pfn protocol="xrootd-uk2" destination-match=".*"
    path-match="(.*)" result="root://xrootd-uk-cms.gridpp.rl.ac.uk/$1"/>
  <lfn-to-pfn protocol="xrootd-eu" destination-match=".*"
    path-match="(.*)" result="root://xrootd.ba.infn.it/$1"/>
  <!-- combine all fallbacks into 1 rule, cmssw can only have 1 fallback -->
  <!-- server chain stops when one server responds - even if it does not have
the file -->
  <lfn-to-pfn protocol="fallbacks" destination-match=".*"
   path-match="(.*)"
result="root://cms-xrd-global.cern.ch,xrootd.ba.infn.it,xrootd.unl.edu/$1?tried=gfe02.grid.hep.ph.ic.ac.uk"/>

  <pfn-to-lfn protocol="direct" destination-match=".*"
    path-match=".*(/store/.*)" result="$1"/>
  <pfn-to-lfn protocol="root" destination-match=".*" chain="direct"
    path-match="(.*)" result="$1"/>
  <pfn-to-lfn protocol="xrootd" destination-match=".*" chain="root"
    path-match="(.*)" result="$1"/>
</storage-mapping>
' > /etc/cms/SITECONF/T2_UK_London_IC/PhEDEx/storage.xml
echo '
<site-local-config>
        <site name="T2_UK_London_IC">
        <event-data>
                <catalog
url="trivialcatalog_file:/etc/cvmfs/SITECONF/local/PhEDEx/storage.xml?protocol=root"/>
                <catalog
url="trivialcatalog_file:/etc/cvmfs/SITECONF/local/PhEDEx/storage.xml?protocol=fallbacks"/>
        </event-data>
                <calib-data>
                        <frontier-connect>
                                <proxy
url="http://squid02.gridpp.rl.ac.uk:3128"/>
                                <proxy
url="http://squid03.gridpp.rl.ac.uk:3128"/>
                                <proxy
url="http://squid04.gridpp.rl.ac.uk:3128"/>
                                <proxy
url="http://squid05.gridpp.rl.ac.uk:3128"/>
                                <server
url="http://cmsfrontier.cern.ch:8000/FrontierInt"/>
                                <server
url="http://cmsfrontier1.cern.ch:8000/FrontierInt"/>
                                <server
url="http://cmsfrontier2.cern.ch:8000/FrontierInt"/>
                               <server
url="http://cmsfrontier3.cern.ch:8000/FrontierInt"/>
                        </frontier-connect>
        </calib-data>
        </site>
</site-local-config>
' > /etc/cms/SITECONF/T2_UK_London_IC/JobConfig/site-local-config.xml

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

