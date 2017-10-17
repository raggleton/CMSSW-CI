FROM cern/slc6-base
#FROM hepsw/cvmfs-cms

USER root

RUN sudo yum update -y && sudo yum install -y svn git glibc gcc

RUN sudo yum update -y && sudo yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm

RUN sudo yum update -y && sudo yum install -y cvmfs cvmfs-config-default

RUN mkdir -p /etc/cvmfs

WORKDIR /app

ADD . /app
