FROM hepsw/cvmfs-cms

RUN rpm --rebuilddb && yum install -y git glibc gcc

WORKDIR /app

ADD . /app

CMD ["/bin/bash", "-c", "source /app/pre_install.sh && source /app/setup_sframe.sh && source /app/minimal_install.sh && source /app/post_install.sh"]