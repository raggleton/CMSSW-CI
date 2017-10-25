#!/bin/bash
# Setup fastjet & fastjet-contrib
FJVER="3.2.2"
FJINSTALLDIR="fastjet-install"
wget http://fastjet.fr/repo/fastjet-${FJVER}.tar.gz
tar xvzf fastjet-${FJVER}.tar.gz
mkdir ${FJINSTALLDIR}
cd fastjet-${FJVER}    
./configure --prefix=`pwd`/../${FJINSTALLDIR}/
make
make check
make install

cd ..
g++ short-example.cc -o short-example `${FJINSTALLDIR}/bin/fastjet-config --cxxflags --libs —plugins`
./short-example


FJCONTRIBVER="1.030"
wget http://fastjet.hepforge.org/contrib/downloads/fjcontrib-${FJCONTRIBVER}.tar.gz
tar xvzf fjcontrib-${FJCONTRIBVER}.tar.gz
cd fjcontrib-${FJCONTRIBVER}
./configure --fastjet-config=`pwd`/../${FJINSTALLDIR}/bin/fastjet-config
make
make check
make install


