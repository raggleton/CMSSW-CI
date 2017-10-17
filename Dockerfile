FROM hepsw/cvmfs-cms

# https://github.com/CentOS/sig-cloud-instance-images/issues/15
RUN yum install -y yum-plugin-ovl; yum clean all
#RUN yum update -y && yum install -y svn git glibc gcc
RUN yum install -y svn git glibc gcc; yum clean all

WORKDIR /app

ADD . /app

CMD ["/bin/bash", "-c", "source run.sh"]