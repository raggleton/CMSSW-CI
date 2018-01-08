#!/usr/bin/env bash

# Some better practices:
set -o xtrace # Print command before executing it - easier for looking at logs
set -o errexit # make your script exit when a command fails.
set -o pipefail # exit status of the last command that threw a non-zero exit code is returned
# set -o nounset # exit when your script tries to use undeclared variables. can't use as external scripts will fail

# CRUCIAL for cmsrel, etc as aliases not expanded in non-interactive shells
shopt -s expand_aliases

# Manual SITECONF
mkdir -p /etc/cms/SITECONF/local/{JobConfig,PhEDEx}
echo '
<storage-mapping>
  <lfn-to-pfn protocol="root" destination-match=".*" path-match="(.*)" result="root://eospublic.cern.ch/$1"/>
  <lfn-to-pfn protocol="xrootd" destination-match=".*" chain="root" path-match="(.*)" result="$1"/>

  <!-- fallback xrootd rules -->
  <lfn-to-pfn protocol="xrootd-uk2" destination-match=".*" path-match="(.*)" result="root://xrootd-uk-cms.gridpp.rl.ac.uk/$1"/>
  <lfn-to-pfn protocol="xrootd-eu" destination-match=".*" path-match="(.*)" result="root://xrootd.ba.infn.it/$1"/>
  <!-- combine all fallbacks into 1 rule, cmssw can only have 1 fallback -->
  <!-- server chain stops when one server responds - even if it does not have the file -->
  <lfn-to-pfn protocol="fallbacks" destination-match=".*" path-match="(.*)" result="root://cms-xrd-global.cern.ch,xrootd.ba.infn.it,xrootd.unl.edu/$1?tried=gfe02.grid.hep.ph.ic.ac.uk"/>

  <pfn-to-lfn protocol="direct" destination-match=".*" path-match=".*(/store/.*)" result="$1"/>
  <pfn-to-lfn protocol="root" destination-match=".*" chain="direct" path-match="(.*)" result="$1"/>
  <pfn-to-lfn protocol="xrootd" destination-match=".*" chain="root" path-match="(.*)" result="$1"/>
</storage-mapping>
' > /etc/cms/SITECONF/local/PhEDEx/storage.xml
echo '
<site-local-config>
        <site name="T2_UK_London_IC">
        <event-data>
                <catalog url="trivialcatalog_file:/etc/cms/SITECONF/local/PhEDEx/storage.xml?protocol=root"/>
                <catalog url="trivialcatalog_file:/etc/cms/SITECONF/local/PhEDEx/storage.xml?protocol=fallbacks"/>
        </event-data>
                <calib-data>
                        <frontier-connect>
                                <proxy url="http://squid02.gridpp.rl.ac.uk:3128"/>
                                <proxy url="http://squid03.gridpp.rl.ac.uk:3128"/>
                                <proxy url="http://squid04.gridpp.rl.ac.uk:3128"/>
                                <proxy url="http://squid05.gridpp.rl.ac.uk:3128"/>
                                <server url="http://cmsfrontier.cern.ch:8000/FrontierInt"/>
                                <server url="http://cmsfrontier1.cern.ch:8000/FrontierInt"/>
                                <server url="http://cmsfrontier2.cern.ch:8000/FrontierInt"/>
                               <server url="http://cmsfrontier3.cern.ch:8000/FrontierInt"/>
                        </frontier-connect>
        </calib-data>
        </site>
</site-local-config>
' > /etc/cms/SITECONF/local/JobConfig/site-local-config.xml

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
cp $WORKDIR/ttbar_miniaodsim_summer16_v2_PUMoriond17_80X.root .
scram build $MAKEFLAGS

# cmsRun won't work out of the box due to Valid site-local-config not found at /cvmfs/cms.cern.ch/SITECONF/local/JobConfig/site-local-config.xml
# Looks for site-local-config.xml from CMS_PATH...let's hack it
# Don't worry, this won't affect anything else
export CMS_PATH=/etc/cms/
cmsRun test_cfg.py
edmDumpEventContent patTuple.root

