VERSION = $(shell gobump show -r)
CURRENT_REVISION = $(shell git rev-parse --short HEAD)
BUILD_LDFLAGS = "-X main.revision=$(CURRENT_REVISION)"
ifdef update
  u=-u
endif

deps:
	go get ${u} github.com/golang/dep/cmd/dep
	dep ensure

devel-deps: deps
	go get ${u} github.com/golang/lint/golint \
	  github.com/haya14busa/goverage          \
	  github.com/mattn/goveralls              \
	  github.com/motemen/gobump               \
	  github.com/Songmu/goxz/cmd/goxz         \
	  github.com/Songmu/ghch                  \
	  github.com/tcnksm/ghr

test: deps
	go test ./...

lint: devel-deps
	go vet ./...
	go list ./... | xargs golint -set_exit_status

cover: devel-deps
	goverage -v -race -covermode=atomic ./...

build: deps
	go build -ldflags=$(BUILD_LDFLAGS)

crossbuild: devel-deps
	goxz -pv=v$(VERSION) -build-ldflags=$(BUILD_LDFLAGS) \
	  -os=linux,darwin,windows -arch=amd64 -d=./dist/v$(VERSION)

bump: devel-deps
	_tools/releng

upload:
	ghr v$(VERSION) dist/v$(VERSION)

release: bump crossbuild upload

.PHONY: deps devel-deps test lint cover build crossbuild bump upload release
