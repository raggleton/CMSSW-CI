# CMSSW-CI

Trying to get a working example of setting up CMSSW in a CI system (chosen Travis for ease).
We do this by using docker. (Travis doesn't support vagrant/virtualbox)

So we need: SLC6 + CVMSFS (to get all the software). The easiest way is to use someone else's image :)

## Images/containers

**DO NOT USE** cern/slc6-base: https://gitlab.cern.ch/linuxsupport/slc6-base/blob/master/slc6-base-docker.ks.
It doesn't have `root` access, so `yum install` etc fail on travis (but work locally...).

Instead stick to `hepsw/cvmfs-cms` from https://github.com/hepsw/docks. This already has (old) versions of everything installed.

Here we have told our image to run `run.sh`, which sets up CMSSW and checks out & compiles a package as a demonstration.

To build the image:

```
docker pull hepsw/cvmfs-cms
sudo docker build -t mycmssw -f Dockerfile .
```

- `-t` is to "tag" the image with the name `mycmssw`.
- `-f Dockerfile` tells it to use Dockerfile to specify the build.
- `.` specifies the build context (i.e all files in local dir get sent to the docker daemon).

You can then push to docker hub.

To run it:

```
sudo docker run --privileged --name myCI -ti -v $PWD:/app mycmssw
```

This will run `run.sh` automatically. If you don't want this to happen, append `/bin/bash` to the command to go into a terminal.

- `--privileged` is required to mount CVMFS correctly.
- `--name myCI` is to give it a name, so you can refer to it e.g. in `docker exec` or `docker rm`.
- `-i` is for interactive mode, so you can see what it's doing.
- `-t` is  to allocate a pseudo-tty.
- `-v $PWD:/app` maps the current dir to `/app` in the image - you can edit on local machine and changes will be shown in container.
- `mycmssw` is the tag you used in the `build` command above.

In this example, we setup CMSSW, checkout a package, run a simple CMSSW config, and inspect the output file.

**NB** for now, running `cmsRun` doesn't work due to a CVMSFS cofiguration error.

## Notes

- If you see `Rpmdb checksum is invalid: dCDPT(pkg checksums): openssh-clients.x86_64 0:5.3p1-123.el6_9 - u` when doing `yum install`, you need to first do `yum install -y yum-plugin-ovl`: https://github.com/CentOS/sig-cloud-instance-images/issues/15 -> Nope doesn't work.

- Maybe try appending `; yum clean all` to all yum commands

- **SOLUTION**: Use `rpm --rebuilddb` first as per https://github.com/moby/moby/issues/10180

- `yum update` will try and update a lot of packages - maybe not worth it/needed?

- You have to set `user.github` to pull from CMS. But a dummy value is OK if you don't need to push.

- `glibc gcc` packages are necessary as some headers are missing, and `scram build` will fail.

## Useful links

- CVMFS: https://cernvm.cern.ch/portal/filesystem/quickstart

## Outstanding issues

- How to run `cmsRun` with files from xrootd? Or too perilous? Maybe host in git LFS?

