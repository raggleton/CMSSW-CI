# CMSSW-CI

This branch is for deploying & running UHH code on CERN's gitlab with gitlab-ci.

To get things to run, we just need a `.gitlab-ci.yml`.

To get CMSSW etc runing we need: SLC6 + CVMFS (to get all the software). This is easy to setup - we don't even need a docker image (yet).

To use CVMFS in gitlab just add:

```yaml
tags:
    - cvmfs
```

The SLC6 image is the default, but you can also explicity specify it with:
```yaml
image: gitlab-registry.cern.ch/ci-tools/ci-worker:slc6
```

## Notes

- Also note that in the `script` part of `.gitlab-ci.yml`, each line is executed in its own shell. So doing:

```yaml
script:
    - source /cvmfs/cms.cern.ch/cmsset_default.sh
    - cmsrel CMSSW_X_Y_Z
```

won't work, because even if setup.sh defines `cmsrel`, it won't persist until the next line AFAICT.


- gitlab comes with it's own docker image registry, which may prove useful...

## Setting up CVMFS

If you run `cmsRun` you'll find it errors with:

```
Valid site-local-config not found at /cvmfs/cms.cern.ch/SITECONF/local/JobConfig/site-local-config.xml
```

This is because normally your site admin has setup SITECONF/local to link to somewhere like T2_DE_DESY. We don't have that, so have to do it ourselves.
To solve this is a bit non-trivial. It requires `cvmfs_config`, which you can install via `sudo yum install https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm && sudo yum install -y cvmfs cvmfs-config`.

**BROKEN**: cannot install CVMFS at `/cvmfs` already exists and is owned by `root`. How to get around this???

Add `export CMS_LOCAL_SITE=T2_DE_DESY` to `/etc/cvmfs/config.d/cms.cern.ch.local`.

Also want to have in `/etc/cvmfs/default.local`:

```
# Repositories: cms.cern.ch is vital for CMS, grid.cern.ch provides a Grid-UI and is a recommended addition
CVMFS_REPOSITORIES=cms.cern.ch,grid.cern.ch,sft.cern.ch
CVMFS_HTTP_PROXY="DIRECT"
```

Then you need to restart CVMFS: `cvmfs_config reload; cvmfs_config setup` (are both required?)

## Issues:

- `c++: internal compiler error: Killed (program cc1plus)` : most likely run out of swap memory - try reducing the number of parallel makes (`-jX`)


## Links

- https://cern.service-now.com/service-portal/topic.do?topic=Gitlab
- https://cern.service-now.com/service-portal/article.do?n=KB0003690
- https://cern.service-now.com/service-portal/article.do?n=KB0004284
- https://gitlab.cern.ch/gitlabci-examples/cvmfs_access
- https://gitlab.cern.ch/gitlabci-examples/custom_ci_worker
- https://jenkinsdocs.web.cern.ch/chapters/slaves/custom-docker.html
- https://gitlab.cern.ch/groups/gitlabci-examples
- https://gitlab.cern.ch/help/ci/docker/using_docker_images.md#overwrite-image-and-services
- https://docs.gitlab.com/ee/ci/yaml/README.html
- https://gitlab.cern.ch/help/user/project/container_registry