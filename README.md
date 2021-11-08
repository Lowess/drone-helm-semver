drone-helm-semver
====================

* Author: `Florian Dambrine <florian@gumgum.com>`

A [Drone plugin](https://readme.drone.io/plugins/overview/) to help deal with Helm `values.yaml` image tag semantic versioning updates when using a [Gitops workflow](https://www.weave.works/technologies/gitops/).

# :notebook: Usage

* Bump up the `.image.tag` stored in a values file named `*verity-go-api--production.yaml` located in the `gitops` folder

```yaml
---

kind: pipeline
type: docker
name: gitops
steps:
  - name: gitops_clone
    image: alpine/git
    commands:
      - git clone https://bitbucket.org/gumgum/verity-onprem-ops/ gitops

  - name: gitops_autosemver
    image: lowess/drone-helm-semver
    settings:
        folder: gitops
        release: verity-go-api--production
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
      author_email: 'noreply@gumgum.com'
```

---

# :gear: Parameter Reference

| Parameter      | Description                                                                           | Example                    |
| -------------- | ------------------------------------------------------------------------------------- | -------------------------- |
| `folder`       | The Gitops folder where the `find` command will be executed                           | `gitops`                   |
| `release`      | The name the file holding `values.yaml` for the release                               | `mychart--production.yaml` |
| `version`      | The Docker image version to set in the `values.yaml` of the realease                  | `v1.0.0`                   |
| `version_path` | The [JMESPath](https://jmespath.org/contents.html) expression to the Docker image tag | `.image.tag`               |

---

# :beginner: Development

* Run the plugin directly from a built Docker image:

```bash
docker run -i \
           -v /Users/florian/Workspace/verity-onprem-ops:/gitops \
           -v $(pwd)/plugin:/opt/drone/plugin \
           -e PLUGIN_RELEASE=verity-go-api--production \
           -e PLUGIN_VERSION=snapshot \
           lowess/drone-helm-semver
```
