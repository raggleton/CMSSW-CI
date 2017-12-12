FROM hepsw/cvmfs-cms

RUN rpm --rebuilddb && yum install -y svn git glibc gcc

WORKDIR /app

ADD . /app

CMD ["/bin/bash", "-c", "source pre_install.sh && source setup_sframe.sh && source minimal_install.sh && source post_install"]