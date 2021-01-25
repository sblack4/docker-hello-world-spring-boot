REGISTRY_NAME=eus1devaksregistry
REGISTRY_URL=$(REGISTRY_NAME).azurecr.io
IMAGE_NAME := $(shell basename $$(pwd))
GIT_HASH := $(shell git rev-parse --short HEAD)
IMAGE_TAG := $(GIT_HASH)
DOCKER_FULL_TAG=$(REGISTRY_URL)/$(IMAGE_NAME):$(IMAGE_TAG)
DOCKER_FULL_TAG := $(shell echo $(DOCKER_FULL_TAG) | awk '{ print tolower($$0) }')

all: push

acr_login_ad_user:
	@echo logging into ACR with user account through Azure CLI
	az acr login --name $(REGISTRY_NAME)

acr_login_msi:
	@echo logging into ACR with MSI through Azure CLI
	az login --identity
	az acr login --name $(REGISTRY_NAME)

build:
	@echo Building $(DOCKER_FULL_TAG)
	docker build -t $(DOCKER_FULL_TAG) .

push: acr_login_ad_user build
	@echo Pushing $(DOCKER_FULL_TAG)
	docker push $(DOCKER_FULL_TAG)
	@echo Image $(IMAGE_NAME) has new tag $(IMAGE_TAG)
