FROM hepsw/cvmfs-cms

RUN rpm --rebuilddb && yum install -y svn git glibc gcc

WORKDIR /app

ADD . /app

CMD ["/bin/bash", "-c", "source run.sh"]