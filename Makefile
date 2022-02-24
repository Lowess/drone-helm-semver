.PHONY: plugin release
REPO = lowess/drone-helm-semver
VERSION ?= latest

TEST_VERSION = v1.0.0
TEST_MULTIPLE = true

test:
	docker run -i \
	   -w /gitops \
	   -v $(PWD)/script.sh:/bin/script.sh \
           -v $(PWD)/tests:/gitops \
           -v $(PWD)/plugin:/opt/drone/plugin \
           -e PLUGIN_RELEASE=myrelease \
	   -e PLUGIN_ALLOW_MULTIPLE=$(TEST_MULTIPLE) \
           -e PLUGIN_VERSION=$(TEST_VERSION) \
           lowess/drone-helm-semver

plugin:
	@echo "Building Drone plugin (export VERSION=<version> if needed)"
	docker build . -t $(REPO):$(VERSION)

	@echo "\nDrone plugin successfully built! You can now execute it with:\n"
	@sed -n '/docker run/,/drone-helm-semver/p' README.md

release:
	@echo "Pushing Drone plugin to the registry"
	docker push $(REPO):$(VERSION)
