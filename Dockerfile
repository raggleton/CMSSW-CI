FROM cern/slc6-base
USER root
WORKDIR /app
ADD . /app
CMD ["/bin/bash", "-c", "sudo", "source", "run.sh"]