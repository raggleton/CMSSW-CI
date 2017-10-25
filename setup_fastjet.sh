#!/bin/bash -e
# Setup fastjet & fastjet-contrib
# NB use curl not wget as curl available by cvmfs, wget isnt
FJVER="3.2.1"
FJINSTALLDIR="fastjet-install"
curl -O http://fastjet.fr/repo/fastjet-${FJVER}.tar.gz
tar xzf fastjet-${FJVER}.tar.gz
mkdir ${FJINSTALLDIR}
cd fastjet-${FJVER}    
./configure --prefix=`pwd`/../${FJINSTALLDIR}/
make
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
# ./configure --fastjet-config=`pwd`/../${FJINSTALLDIR}/bin/fastjet-config
./configure
make
make check
make install
cd ..

