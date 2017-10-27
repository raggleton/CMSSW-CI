# CMSSW-CI

This branch is for running on CERN's gitlab with gitlab-ci.

To get things to run, we just need a `.gitlab-ci.yml`.

To get CMSSW etc runing we need: SLC6 + CVMFS (to get all the software). This is easy to setup - we don't even need a docker image (yet).

To use CVMSFS in gitlab just add:

```yaml
tags:
    - cvmfs
```

The SLC6 part comes for free (or do I have to specify it vs cc7?).

## Notes

- Also note that in the `script` part of `.gitlab-ci.yml`, each line is executed in its own shell. So doing:

```yaml
script:
    - source /cvmfs/cms.cern.ch/cmsset_default.sh
    - cmsrel CMSSW_X_Y_Z
```

won't work, because even if setup.sh defines cmsrel, it won't persist until the next line AFAICT.


- gitlab comes with it's own docker image registry, which may prove useful...


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