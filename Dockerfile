FROM cern/slc6-base
WORKDIR /code
ADD . /code
RUN sudo yum install https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
RUN sudo yum install cvmfs cvmfs-config-default
RUN cvmfs_config setup
RUN mkdir /etc/cvmfs/
RUN cp /code/default.local /etc/cvmfs/default.local
RUN cvmfs_config probe

CMD ["cat", "/cvmfs/cms.cern.ch/cmsset_default.sh"]