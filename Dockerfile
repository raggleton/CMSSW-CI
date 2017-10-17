FROM hepsw/cvmfs-cms

RUN yum install -y yum-plugin-ovl; yum clean all

RUN yum install -y svn git glibc gcc; yum clean all

WORKDIR /app

ADD . /app

CMD ["/bin/bash", "-c", "source run.sh"]