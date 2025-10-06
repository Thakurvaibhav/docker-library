IMAGE_NAME ?= utils
REGISTRY ?= vaibhavthakur
TAG ?= latest
PLATFORM ?= linux/amd64
BUILD_ARGS ?=

# Version overrides example:
# make build TAG=v1.0.0 KUBECTL_VERSION=v1.32.0

GIT_SHA := $(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
DATE := $(shell date -u +%Y%m%dT%H%M%SZ)

DOCKER_BUILDKIT=1
export DOCKER_BUILDKIT

build:
	@echo "[BUILD] $(REGISTRY)/$(IMAGE_NAME):$(TAG) (sha=$(GIT_SHA))"
	docker build \
		--platform $(PLATFORM) \
		--build-arg BUILD_DATE=$(DATE) \
		--build-arg VCS_REF=$(GIT_SHA) \
		$(BUILD_ARGS) \
		-t $(REGISTRY)/$(IMAGE_NAME):$(TAG) .

push: build
	@echo "[PUSH] $(REGISTRY)/$(IMAGE_NAME):$(TAG)"
	docker push $(REGISTRY)/$(IMAGE_NAME):$(TAG)

push-sha: build
	@echo "[TAG] adding git sha tag"
	docker tag $(REGISTRY)/$(IMAGE_NAME):$(TAG) $(REGISTRY)/$(IMAGE_NAME):$(GIT_SHA)
	docker push $(REGISTRY)/$(IMAGE_NAME):$(GIT_SHA)

multi-arch:
	@echo "[BUILD] multi-arch $(REGISTRY)/$(IMAGE_NAME):$(TAG)"
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg BUILD_DATE=$(DATE) \
		--build-arg VCS_REF=$(GIT_SHA) \
		$(BUILD_ARGS) \
		-t $(REGISTRY)/$(IMAGE_NAME):$(TAG) --push .

clean:
	@echo "[CLEAN] removing local image"
	- docker rmi $(REGISTRY)/$(IMAGE_NAME):$(TAG) 2>/dev/null || true

print-versions:
	@echo "== Build Args =="; \
	egrep '^ARG ' Dockerfile || true

.PHONY: build push push-sha multi-arch clean print-versions
