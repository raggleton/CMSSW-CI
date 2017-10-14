FROM cern/slc6-base

#USER root

RUN yum update -y && yum install -y svn git

RUN yum update -y && yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm

RUN yum update -y && yum install -y cvmfs cvmfs-config-default

RUN mkdir -p /etc/cvmfs

WORKDIR /app

ADD . /app

CMD ["/bin/bash", "-c", "source run.sh"]