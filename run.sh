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
echo "export CMS_LOCAL_SITE=/etc/cms/SITECONF/T2_DE_DESY" > /etc/cvmfs/config.d/cms.cern.ch.local
# Hack for CMSSW bug (?)
ln -s /cvmfs/cms.cern.ch/SITECONF /etc/cvmfs/SITECONF
mkdir -p /etc/cms/SITECONF/T2_DE_DESY/{JobConfig,PhEDEx}
ln -s T2_DE_DESY /etc/cms/SITECONF/local
echo '
<storage-mapping>

<!-- Specific for Load Test 07 input files-->
  <lfn-to-pfn protocol="srm"
    path-match=".*/LoadTest07_DESY_(.*)_.*_.*"
    result="srm://dcache-se-cms.desy.de:8443/srm/managerv1?SFN=/pnfs/desy.de/cms/tier2/store/phedex_monarctest/monarctest_DESY/MonarcTest_DESY_$1"/>
<!-- For SRM2 -->
  <lfn-to-pfn protocol="srmv2"
    path-match=".*/LoadTest07_DESY_(.*)_.*_.*"
    result="srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/store/phedex_monarctest/monarctest_DESY/MonarcTest_DESY_$1"/>

<!-- DCMS MC production -->
  <lfn-to-pfn protocol="direct"
    path-match="/+store/DCMS/(.*)"
    result="/pnfs/desy.de/cms/analysis/dcms/$1"/>
  <lfn-to-pfn protocol="direct"
    path-match="/+store/unmerged/DCMS/(.*)"
    result="/pnfs/desy.de/cms/analysis/dcms/unmerged/$1"/>
  <pfn-to-lfn protocol="direct"
    path-match="/pnfs/desy.de/cms/analysis/dcms/unmerged/(.*)"
    result="/store/unmerged/DCMS/$1"/>
  <pfn-to-lfn protocol="direct"
    path-match="/pnfs/desy.de/cms/analysis/dcms/(.*)"
    result="/store/DCMS/$1"/>

<!-- Special directories -->
  <lfn-to-pfn protocol="srm"
    path-match="/+store/PhEDEx_LoadTest07/(.*)"
    result="srm://dcache-se-cms.desy.de:8443/srm/managerv1?SFN=/pnfs/desy.de/cms/tier2/loadtest/$1"/>
  <pfn-to-lfn protocol="direct"
    path-match="/pnfs/desy.de/cms/tier2/loadtest/(.*)"
    result="/store/PhEDEx_LoadTest07/$1"/>
<!-- For SRM2 -->
  <lfn-to-pfn protocol="srmv2"
    path-match="/+store/PhEDEx_LoadTest07/(.*)"
    result="srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=/pnfs/desy.de/cms/tier2/loadtest/$1"/>

<!-- unmerged/temp directories -->
  <lfn-to-pfn protocol="direct"
    path-match="/+store/unmerged/(.*)"
    result="/pnfs/desy.de/cms/tier2/unmerged/$1"/>
  <pfn-to-lfn protocol="direct"
    path-match="/pnfs/desy.de/cms/tier2/unmerged/(.*)"
    result="/store/unmerged/$1"/>
  <lfn-to-pfn protocol="direct"
    path-match="/+store/temp/(.*)"
    result="/pnfs/desy.de/cms/tier2/temp/$1"/>
  <pfn-to-lfn protocol="direct"
    path-match="/pnfs/desy.de/cms/tier2/temp/(.*)"
    result="/store/temp/$1"/>

<!-- Open JobRobot sample via xrootd - dirty hack! -->
  <lfn-to-pfn protocol="dcap"
    path-match="/+store/mc/JobRobot/(.*)"
    result="root://dcache-cms-xrootd.desy.de/pnfs/desy.de/cms/tier2/store/mc/JobRobot/$1"/>
  <lfn-to-pfn protocol="dcap"
    path-match="/+store/mc/CMSSW_4_2_3/RelValProdTTbar/GEN-SIM-RECO/MC_42_V12_JobRobot-v1/(.*)"
    result="root://dcache-cms-xrootd.desy.de/pnfs/desy.de/cms/tier2/store/mc/CMSSW_4_2_3/RelValProdTTbar/GEN-SIM-RECO/MC_42_V12_JobRobot-v1/$1"/>

<!-- Normal stuff here -->
 <!-- remote xrootd fallback via European redirector -->
  <lfn-to-pfn protocol="remote-xrootd"
    path-match="/+store/(.*)"
    result="root://xrootd-cms.infn.it//store/$1"/>
  <pfn-to-lfn protocol="remote-xrootd"
    path-match="/+store/(.*)"
    result="/store/$1"/>
 <!-- End of redirector stuff --> 
  <lfn-to-pfn protocol="direct"
    path-match="/+(.*)"
    result="/pnfs/desy.de/cms/tier2/$1"/>
  <lfn-to-pfn protocol="dcap" chain="direct"
    path-match="(.*)"
    result="dcap://dcache-cms-dcap.desy.de/$1"/>
  <lfn-to-pfn protocol="gsidcap" chain="direct"
    path-match="(.*)"
    result="gsidcap://dcache-cms-gsidcap.desy.de:22128/$1"/>
  <lfn-to-pfn protocol="srm" chain="direct"
    path-match="(.*)"
    result="srm://dcache-se-cms.desy.de:8443/srm/managerv1?SFN=$1"/>
  <pfn-to-lfn protocol="direct"
    path-match="/pnfs/desy.de/cms/tier2/(.*)"
    result="/$1"/>
  <pfn-to-lfn protocol="srm" chain="direct"
    path-match=".*\?SFN=(.*)"
    result="$1"/>
<!-- For SRM2 -->
  <lfn-to-pfn protocol="srmv2" chain="direct"
    path-match="(.*)"
    result="srm://dcache-se-cms.desy.de:8443/srm/managerv2?SFN=$1"/>
  <pfn-to-lfn protocol="srmv2" chain="direct"
    path-match=".*\?SFN=(.*)"
    result="$1"/>
</storage-mapping>
' > /etc/cms/SITECONF/T2_DE_DESY/PhEDEx/storage.xml
echo '
<site-local-config>
 <site name="T2_DE_DESY">
    <event-data>
      <catalog url="trivialcatalog_file:/cvmfs/cms.cern.ch/SITECONF/local/PhEDEx/storage.xml?protocol=dcap"/>
      <catalog url="trivialcatalog_file:/cvmfs/cms.cern.ch/SITECONF/local/PhEDEx/storage.xml?protocol=remote-xrootd"/>
    </event-data>
    <source-config>
      <statistics-destination name="cms-udpmon-collector.cern.ch:9331" />
    </source-config>
    <local-stage-out>
      <command value="gfal2"/>
      <catalog url="trivialcatalog_file:/cvmfs/cms.cern.ch/SITECONF/local/PhEDEx/storage.xml?protocol=srmv2"/>
      <se-name value="dcache-se-cms.desy.de"/>
      <phedex-node value="T2_DE_DESY"/>
    </local-stage-out>
    <fallback-stage-out>
      <se-name value="grid-srm.physik.rwth-aachen.de"/>
      <phedex-node value="T2_DE_RWTH"/>
      <lfn-prefix value="srm://grid-srm.physik.rwth-aachen.de:8443/srm/managerv2?SFN=/pnfs/physik.rwth-aachen.de/cms"/>
      <command value="gfal2"/>
    </fallback-stage-out>
    <calib-data>
      <frontier-connect>
        <load balance="proxies"/>
        <proxy url="http://grid-squid02.desy.de:3128"/>
        <proxy url="http://grid-squid04.desy.de:3128"/>
        <proxy url="http://grid-squid06.desy.de:3128"/>
        <backupproxy url="http://cmsbpfrontier.cern.ch:3128"/>
        <backupproxy url="http://cmsbproxy.fnal.gov:3128"/>
        <server url="http://cmsfrontier.cern.ch:8000/FrontierInt"/>
        <server url="http://cmsfrontier1.cern.ch:8000/FrontierInt"/>
        <server url="http://cmsfrontier2.cern.ch:8000/FrontierInt"/>
        <server url="http://cmsfrontier3.cern.ch:8000/FrontierInt"/>
      </frontier-connect>
    </calib-data>
 </site>
 </site-local-config>
' > /etc/cms/SITECONF/T2_DE_DESY/JobConfig/site-local-config.xml

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

