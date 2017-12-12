#!/bin/bash -e

set -u

# Run before install script to ensure vars set, etc
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
    ans=$(git config --global "$settingName")
    if [ "$ans" == "" ]
    then
        echo "git $settingName not set - setting it to $newValue"
        git config --global "$settingName" "$newValue"
    fi
}

echo "Doing pre_install"

# Check CVMSFS
ls /cvmfs/cms.cern.ch/

# Store top location
export WORKDIR=$(pwd)

export CMSSW_GIT_REFERENCE=$WORKDIR/cmssw.git
export MAKEFLAGS="-j9"
MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# Required for pulling
setGitSetting "user.name" "Joe Bloggs"
setGitSetting "user.email" "a@b.c"
setGitSetting "user.github" "testUHH"