SHELL := /bin/bash

PROJECT_NAME := "gohttpd"
PKG := "$(PROJECT_NAME)"

# 镜像名
IMAGE_NAME := helailiang/gohttpd

# 支持命令行传参，否则默认 latest
# 默认 TAG 是 latest，除非从命令行传入
TAG ?= latest
REPO ?= docker.io

# 完整镜像标签
IMAGE_TAGGED := $(REPO)/$(IMAGE_NAME):$(TAG)

.PHONY: build
build:
	@echo "拉取最新代码"
	@git pull
	@echo "building 'gohttpd', linux binary file will output to 'build/gohttpd'"
	@mkdir -p build
	@go build -o build/gohttpd main.go

.PHONY: image-build
# build image for remote repositories, e.g. make image-build REPO=addr TAG=latest
image-build:
	@echo "拉取最新代码"
	@git pull
	@echo "docker build -f Dockerfile -t $(IMAGE_TAGGED) ."
	@docker build -f Dockerfile -t $(IMAGE_TAGGED) .

.PHONY: image-push
# push docker image to remote repositories, e.g. make image-push REPO=addr TAG=latest
image-push: image-build
	@echo "Pushing $(IMAGE_TAGGED)"
	@docker push $(IMAGE_TAGGED)

.PHONY: push
# push docker image to remote repositories, e.g. make push TAG=latest
push: image-build
	@echo "Pushing $(IMAGE_TAGGED)"
	@docker push $(IMAGE_TAGGED)