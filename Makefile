IMAGE_VERSION := $(shell cat image.yaml | egrep ^version  | cut -d"\"" -f2)
CONTAINER_TOOLS_IMAGE_VERSION := $(shell cat container-tools-overrides.yaml | egrep ^version  | cut -d"\"" -f2)
CLIENTS_IMAGE_VERSION := $(shell cat only-clients-overrides.yaml | egrep ^version  | cut -d"\"" -f2)
BUILD_ENGINE := podman
TOOLS_IMAGE := quay.io/gcamposo/java11-tools
.DEFAULT_GOAL := build

.PHONY: build-all
build-all:
	cekit -v build --overrides-file tutorial-tools-overrides.yaml $(BUILD_ENGINE) --no-squash
	docker-squash ${TOOLS_IMAGE}:${IMAGE_VERSION} --tag=${TOOLS_IMAGE}:${IMAGE_VERSION}
	cekit -v build --overrides-file container-tools-overrides.yaml $(BUILD_ENGINE) --no-squash
	docker-squash quay.io/rhdevelopers/container-tools:${CONTAINER_TOOLS_IMAGE_VERSION} --tag=quay.io/rhdevelopers/container-tools:${CONTAINER_TOOLS_IMAGE_VERSION}
	cekit -v build --overrides-file only-clients-overrides.yaml $(BUILD_ENGINE) --no-squash
	docker-squash quay.io/rhdevelopers/clients:${CLIENTS_IMAGE_VERSION} --tag=quay.io/rhdevelopers/clients:${CLIENTS_IMAGE_VERSION}

.PHONY: test
test: build
	cekit -v test --overrides-file tutorial-tools-overrides.yaml behave
	cekit -v test --overrides-file container-tools-overrides.yaml behave
	cekit -v test --overrides-file only-clients-overrides behave

.PHONY: build-tools
build-tools:
	cekit -v build --overrides-file tutorial-tools-overrides.yaml $(BUILD_ENGINE) --no-squash
	docker-squash ${TOOLS_IMAGE}:${IMAGE_VERSION} --tag=${TOOLS_IMAGE}:${IMAGE_VERSION}

.PHONY: push-tools
push-tools:
	$(BUILD_ENGINE) push ${TOOLS_IMAGE}:$(IMAGE_VERSION)

.PHONY:	build-clients
build-clients:
	cekit -v build --overrides-file only-clients-overrides.yaml $(BUILD_ENGINE) --no-squash
	docker-squash quay.io/rhdevelopers/clients:${CLIENTS_IMAGE_VERSION} --tag=quay.io/rhdevelopers/clients:${IMAGE_VERSION}

.PHONY:	push-clients
push-clients:
	$(BUILD_ENGINE) push quay.io/rhdevelopers/clients:$(CLIENTS_IMAGE_VERSION)

.PHONY:	build-container-tools
build-container-tools:
	cekit -v build --overrides-file container-tools-overrides.yaml $(BUILD_ENGINE) --no-squash
	docker-squash quay.io/rhdevelopers/container-tools:${CONTAINER_TOOLS_IMAGE_VERSION} --tag=quay.io/rhdevelopers/container-tools:${IMAGE_VERSION}

.PHONY:	push-container-tools
push-container-tools:
	$(BUILD_ENGINE) push quay.io/rhdevelopers/container-tools:$(CONTAINER_TOOLS_IMAGE_VERSION)

.PHONY: push-all
push-all:
	$(BUILD_ENGINE) push ${TOOLS_IMAGE}:$(IMAGE_VERSION)
	$(BUILD_ENGINE) push quay.io/rhdevelopers/container-tools:$(CONTAINER_TOOLS_IMAGE_VERSION)
	$(BUILD_ENGINE) push quay.io/rhdevelopers/clients:$(CLIENTS_IMAGE_VERSION)

.PHONY: clean
clean:
	rm -Rf target
