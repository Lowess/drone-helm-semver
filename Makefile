.PHONY: plugin release
REPO = lowess/drone-helm-semver
VERSION ?= latest

plugin:
	@echo "Building Drone plugin (export VERSION=<version> if needed)"
	docker build . -t $(REPO):$(VERSION)

	@echo "\nDrone plugin successfully built! You can now execute it with:\n"
	@sed -n '/docker run/,/drone-helm-semver/p' README.md

release:
	@echo "Pushing Drone plugin to the registry"
	docker push $(REPO):$(VERSION)
