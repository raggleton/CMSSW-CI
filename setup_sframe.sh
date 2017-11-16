#!/bin/bash -e

# Done this way as builtin git is old and doesn't support git clone -b <TAG> <REPO>
# The --depth 1 stops you form checking everything out immediately
git clone --depth 1 https://github.com/UHH2/SFrame.git
cd SFrame
git checkout tags/SFrame-04-00-01
cd ..
