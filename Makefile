APP=spoter
BIN_FOLDER=bin
DOC_SERVER=localhost:4242
IGNORED_FOLDER=.ignore
COVERAGE_FILE=coverage.txt
MODULE_NAME := $(shell go list -m)
VENDOR_FOLDER=vendor

.PHONY: all
#all:	@ run all main rules (install test build) 
all: install test build

.PHONY: help
#help:	@ List available rules on this project
help: 
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| sort | tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
#install:	@ Install dependencies
install:
	@go mod vendor

.PHONY: build
#build:	@ Build packages or binaries (app)
build:
	CGO_ENABLED=1 go build -tags static -ldflags "-s -w -X main.appName=${APP}" -o ${BIN_FOLDER}/${APP} ${MODULE_NAME}/cmd/${APP}
	@echo "build success" `ls ./${BIN_FOLDER}/${APP}` "!"

.PHONY: test
#test:	@ Run units tests and generate coverage file
test: --private-create-ignored-folder
	@go test -v -count=1 -race -coverprofile=${IGNORED_FOLDER}/${COVERAGE_FILE} -covermode=atomic $$(go list ./... | grep -v ${APP}_tester)
	@go tool cover -func ${IGNORED_FOLDER}/${COVERAGE_FILE} | grep total:

.PHONY: doc
#doc:	@ Run a server to render documentation with the godoc server
doc:
	$(eval pid := ${shell nohup godoc -http=${DOC_SERVER} >> /dev/null & echo $$! ; })
	@echo "server started:"
	@echo "\tDoc location: http://${DOC_SERVER}/pkg/git.manomano.tech/component-go/pkg"
	@echo "\texecute the following command to turn off server: kill $(pid)"

.PHONY: clean
#clean:	@ cleanup the ignored folders
clean:
	@rm -rf ${IGNORED_FOLDER}
	@rm -rf ${VENDOR_FOLDER} 

.PHONY: fclean
#fclean:	@ invoke clean and remove binaries if exist
fclean: clean
	@rm -rf ${BIN_FOLDER}

# Privates functions

--private-create-ignored-folder:
	@if [ ! -d ${IGNORED_FOLDER} ]; then \
		mkdir -p ${IGNORED_FOLDER}; \
	fi