include Makefile.org

INFO  ?= echo [INFO]
OK    ?= echo [OK]
DOCKER ?= docker

.PHONY: docker-build
docker-build:
	@$(INFO) $(DOCKER) build
	echo $(DOCKER) buildx build -f Dockerfile.ubi9 --build-arg TARGETARCH=amd64 --build-arg TARGETOS=linux -t us.icr.io/${REGISTRY_NAMESPACE}/${REGISTRY_IMAGE}:${REGISTRY_IMAGE_TAG_SHORT} .
	$(DOCKER) buildx build -f Dockerfile.ubi9 --build-arg TARGETARCH=amd64 --build-arg TARGETOS=linux -t us.icr.io/${REGISTRY_NAMESPACE}/${REGISTRY_IMAGE}:${REGISTRY_IMAGE_TAG_SHORT} .
	@$(OK) $(DOCKER) build