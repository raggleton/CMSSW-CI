#!/bin/bash -e

# This script downloads & compiles FastJet and FastJet-contrib, along with HOTVR
# It also builds all necessary libraries for CMSSW (the fragile one)
#
# Usage:
# ./setup_fastjet.sh <FASTJET VERSION> <FASTJET-CONTRIB VERSION>
#

# some sane defaults incase the user hasn't specified anything
export FJVER="3.2.1"
export FJCONTRIBVER="1.025"
if [ "$#" -eq 2 ]
then
    FJVER="$1"
    FJCONTRIBVER="$2"
else
    echo "You didn't specify 2 arguments, using default versions"
fi

echo "Deploying fastjet $FJVER and fastjet-contrib $FJCONTRIBVER"

export MAKEFLAGS="-j9"
MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# Setup fastjet & fastjet-contrib
# NB use curl not wget as curl available by cvmfs, wget isnt
FJINSTALLDIR="$(pwd)/fastjet-install"
curl -O http://fastjet.fr/repo/fastjet-${FJVER}.tar.gz
tar xzf fastjet-${FJVER}.tar.gz
mkdir "${FJINSTALLDIR}"
cd fastjet-${FJVER}    
./configure --prefix="${FJINSTALLDIR}" --enable-allplugins --enable-allcxxplugins CXXFLAGS=-fPIC
make $MAKEFLAGS
make check
make install

cd ..
# Add fastjet-config to PATH
export PATH="${FJINSTALLDIR}/bin":$PATH

# Test fastjet
ls
g++ short-example.cc -o short-example `fastjet-config --cxxflags --libs --plugins`
./short-example


curl -O http://fastjet.hepforge.org/contrib/downloads/fjcontrib-${FJCONTRIBVER}.tar.gz
tar xzf fjcontrib-${FJCONTRIBVER}.tar.gz
cd fjcontrib-${FJCONTRIBVER}
# add HOTVR from SVN - do it this way until it becomes a proper contrib
svn co http://fastjet.hepforge.org/svn/contrib/contribs/HOTVR/trunk HOTVR/
# although we add fastjet-config to path, due to a bug explicitly stating this ensure the necessary fragile library gets built 
./configure --fastjet-config="${FJINSTALLDIR}/bin/fastjet-config" CXXFLAGS=-fPIC
make $MAKEFLAGS
make check
make install
make fragile-shared
make fragile-shared-install
cd ..

