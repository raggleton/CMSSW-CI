#!/bin/bash -e

export MAKEFLAGS
MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# Setup fastjet & fastjet-contrib
# NB use curl not wget as curl available by cvmfs, wget isnt
export FJVER="3.2.1"
FJINSTALLDIR="$(pwd)/fastjet-install"
curl -O http://fastjet.fr/repo/fastjet-${FJVER}.tar.gz
tar xzf fastjet-${FJVER}.tar.gz
mkdir "${FJINSTALLDIR}"
cd fastjet-${FJVER}    
./configure --prefix="${FJINSTALLDIR}" --enable-allplugins --enable-allcxxplugins CXXFLAGS=-fPIC
make "$MAKEFLAGS"
make check
make install

cd ..
# Add fastjet-config to PATH
export PATH="${FJINSTALLDIR}/bin":$PATH

# Test fastjet
ls
g++ short-example.cc -o short-example `fastjet-config --cxxflags --libs --plugins`
./short-example


export FJCONTRIBVER="1.025"
curl -O http://fastjet.hepforge.org/contrib/downloads/fjcontrib-${FJCONTRIBVER}.tar.gz
tar xzf fjcontrib-${FJCONTRIBVER}.tar.gz
cd fjcontrib-${FJCONTRIBVER}
# add HOTVR from SVN - do it this way until it becomes a proper contrib
svn co http://fastjet.hepforge.org/svn/contrib/contribs/HOTVR/trunk HOTVR/
# although we add fastjet-config to path, due to a bug explicitly stating this ensure the necessary fragile library gets built 
./configure --fastjet-config="${FJINSTALLDIR}/bin/fastjet-config" CXXFLAGS=-fPIC
make "$MAKEFLAGS"
make check
make install
make fragile-shared
make fragile-shared-install
cd ..

