drone-helm-semver
====================

* Author: `Florian Dambrine <florian@gumgum.com>`

A [Drone plugin](https://readme.drone.io/plugins/overview/) to help deal with Helm `values.yaml` image tag semantic versioning updates when using a [Gitops workflow](https://www.weave.works/technologies/gitops/).

# :notebook: Usage

* Bump up the `.image.tag` stored in a values file named `*myrelease.yaml` located in the `gitops` folder

```yaml
---

kind: pipeline
type: docker
name: gitops
steps:
  - name: gitops_clone
    image: alpine/git
    commands:
      - git clone https://github.com/<yourcompany>/<gitops-repo> gitops

  - name: gitops_autosemver
    image: lowess/drone-helm-semver
    settings:
        folder: gitops
        release: myrelease
        version_path: .image.tag
        version: ${DRONE_TAG}

  - name: gitops_push
    image: appleboy/drone-git-push
    settings:
      branch: master
      remote:
        from_secret: gitops_remote
      force: true
      commit: true
      path: gitops
      commit_message: '[GITOPS] :robot: ${DRONE_COMMIT_MESSAGE/\\n/}'
      author_name: 'GitOps'
      author_email: 'noreply@<mycompany>.com'
```

---

# :gear: Parameter Reference

| Parameter                       | Description                                                                                                                                                                 | Example                    |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `folder`                        | The Gitops folder where the `find` command will be executed                                                                                                                 | `gitops`                   |
| `release`                       | The name the file holding `values.yaml` for the release                                                                                                                     | `mychart--production.yaml` |
| `version`                       | The Docker image version to set in the `values.yaml` of the realease                                                                                                        | `v1.0.0`                   |
| `version_path`                  | The [JMESPath](https://jmespath.org/contents.html) expression to the Docker image tag                                                                                       | `.image.tag`               |
| `allow_multiple`                | If true and multiple releases are matched with the `find` command it will process them all in a loop                                                                        | `false`                    |
| `auto_suffix_release`           | If true the plugin suffixes `release` with `production` when `DRONE_TAG` is present or uses `staging` when `DRONE_BRANCH` is `master` or `main`                             | `false`                    |
| `auto_suffix_release_separator` | Used to compute the final release name when `auto_suffix_release` is `true` the release name will be computed this way `<release><auto_suffix_release_separator><production | staging>`                  | `--` |

---

# :beginner: Development

* Run the plugin directly from a built Docker image:

```bash
# Adjust the following accordingly
export GITOPS_REPO="~/workspace/<my-gitops-repo-root>"
export GITOPS_RELEASE="myrelease"
export GITOPS_VERSION="v1.0.0"

docker run -i \
           -v ${GITOPS_REPO}:/gitops \
           -v $(pwd)/plugin:/opt/drone/plugin \
           -e PLUGIN_RELEASE=${GITOPS_RELEASE} \
           -e PLUGIN_VERSION=${GITOPS_VERSION} \
           lowess/drone-helm-semver
```
