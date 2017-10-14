FROM cern/slc6-base

USER root

RUN yum install -y svn git

WORKDIR /app

ADD . /app

CMD ["/bin/bash", "-c", "source run.sh"]