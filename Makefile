SCHEME = Tablier

.PHONY: build
build: build/spm

.PHONY: build/spm
build/spm:
	swift build

.PHONY: build/xcode
build/xcode:
	xcodebuild build \
		-scheme $(SCHEME) \
		-destination 'platform=macOS'

.PHONY: test
test: test/spm

.PHONY: test/spm
test/spm:
	swift test --parallel

.PHONY: test/xcode
test/xcode:
	xcodebuild test \
		-scheme $(SCHEME) \
		-destination 'platform=macOS'\
		-parallel-testing-enabled YES

.PHONY: test/examples
test/examples:
	swift test --package-path Examples

.PHONY: test/docker
test/docker: clean/spm linuxmain
	docker run -it --rm -v `pwd`:/tablier -w /tablier swift:5.0 swift test  

.PHONY: linuxmain
linuxmain:
	swift test --generate-linuxmain

LATEST_VERSION = $(shell git describe --tags `git rev-list --tags --max-count=1`)

.PHONY: clean
clean: clean/xcode clean/spm
	$(RM) -r $(PROJECT)

.PHONY: clean/xcode
clean/xcode: 
	xcodebuild clean -scheme $(SCHEME)

.PHONY: clean/spm
clean/spm: 
	swift package clean

.PHONY: .FORCE
.FORCE: