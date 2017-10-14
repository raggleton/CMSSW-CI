FROM cern/slc6-base
USER root
RUN mkdir -p /etc/cvmfs/
WORKDIR /app
ADD . /app
CMD ["source", "run.sh"]