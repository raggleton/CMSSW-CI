#!/bin/bash -e

export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# Setup fastjet & fastjet-contrib
# NB use curl not wget as curl available by cvmfs, wget isnt
FJVER="3.2.1"
FJINSTALLDIR="fastjet-install"
curl -O http://fastjet.fr/repo/fastjet-${FJVER}.tar.gz
tar xzf fastjet-${FJVER}.tar.gz
mkdir ${FJINSTALLDIR}
cd fastjet-${FJVER}    
./configure --prefix=`pwd`/../${FJINSTALLDIR}/ --enable-allplugins --enable-allcxxplugins CXXFLAGS=-fPIC
make $MAKEFLAGS
make check
make install

cd ..
# Add fastjet-config to PATH
export PATH=`pwd`/${FJINSTALLDIR}/bin:$PATH

# Test fastjet
ls
g++ short-example.cc -o short-example `fastjet-config --cxxflags --libs --plugins`
./short-example


FJCONTRIBVER="1.030"
curl -O http://fastjet.hepforge.org/contrib/downloads/fjcontrib-${FJCONTRIBVER}.tar.gz
tar xzf fjcontrib-${FJCONTRIBVER}.tar.gz
cd fjcontrib-${FJCONTRIBVER}
# although we add fastjet-config to path, due to a bug explicitly stating this ensure the necessary fragile library gets built 
./configure --fastjet-config=`pwd`/../${FJINSTALLDIR}/bin/fastjet-config CXXFLAGS=-fPIC
make $MAKEFLAGS
make check
make install
make fragile-shared
make fragile-shared-install
cd ..

