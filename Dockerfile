FROM cern/slc6-base
USER root
WORKDIR /app
ADD . /app
CMD ["source", "run.sh"]