.DEFAULT_GOAL := build

COMMIT_HASH = `git rev-parse --short HEAD 2>/dev/null`
BUILD_DATE = `date +%FT%T%z`

GO = go
BINARY_DIR=bin

BUILD_DEPS:= github.com/alecthomas/gometalinter
GODIRS_NOVENDOR = $(shell go list ./... | grep -v /vendor/)
GOFILES_NOVENDOR = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
PACKAGE_COMMONS=github.com/reportportal/service-analyzer/vendor/gopkg.in/reportportal/commons-go.v1

BUILD_INFO_LDFLAGS=-ldflags "-extldflags '"-static"' -X ${PACKAGE_COMMONS}/commons.repo=${REPO_NAME} -X ${PACKAGE_COMMONS}/commons.branch=${COMMIT_HASH} -X ${PACKAGE_COMMONS}/commons.buildDate=${BUILD_DATE} -X ${PACKAGE_COMMONS}/commons.version=${v}"
IMAGE_NAME=reportportal/migrations$(IMAGE_POSTFIX)

.PHONY: vendor test build

help:
	@echo "build      - go build"
	@echo "test       - go test"
	@echo "checkstyle - gofmt+golint+misspell"


test:
	go test $(glide novendor)

checkstyle:
	gometalinter --vendor ./... --fast --disable=gas --disable=errcheck --disable=gotype --deadline 10m

fmt:
	gofmt -l -w -s ${GOFILES_NOVENDOR}


# Builds server
build: checkstyle test
	CGO_ENABLED=0 GOOS=linux $(GO) build ${BUILD_INFO_LDFLAGS} -o ${BINARY_DIR}/migrate ./

# Builds the container
build-image:
	docker build -t "$(IMAGE_NAME)" --build-arg version=${VERSION} -f Dockerfile .


clean:
	if [ -d ${BINARY_DIR} ] ; then rm -r ${BINARY_DIR} ; fi
