# CMSSW-CI

This branch is a bare-bones example for running on CERN's GitLab with gitlab-ci.

To get things to run, we just need a `.gitlab-ci.yml`.

More info at: https://twiki.cern.ch/twiki/bin/view/Main/RobinGitlabCICMSSW

## Notes

- To get CMSSW etc runing we need: SLC6 + CVMFS (to get all the software). This is easy to setup - we don't even need to fiddle with docker.

- To use CVMSFS in gitlab just need:

```yaml
tags:
    - cvmfs
```

- The SLC6 part comes for free (or do I have to specify it vs cc7?).

- Have to set `user.name`, `user.github`, `user.email` in git global config before doing `cmsrel`.

- Must also use `shopt -s expand_aliases` in bash script to use aliases e.g. `cmsrel`.

- Need to configure cmsRun to use dummy `site-local-config.xml` & `storage.xml` files, do this by changing `CMS_PATH` before running `cmsRun`. This avoids the error:

```
Valid site-local-config not found at /cvmfs/cms.cern.ch/SITECONF/local/JobConfig/site-local-config.xml
```

Normally one would set `CMS_LOCAL_SITE` in `/etc/cvmfs/config.d/cms.cern.ch.local` then do `cvmfs_config reload`, but we are not allowed to do that. We do it in the same way cms-bot does it.

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
- https://github.com/cms-sw/cms-bot/commit/d9aafc1cb411bd96702bb14333e064fd3f1a72d5