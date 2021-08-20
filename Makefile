PROJECT = Tablier.xcodeproj
XCCONFIG = Configs/SwiftPM.xcconfig
SCHEME = Tablier-Package

.PHONY: build
build: build/spm

.PHONY: build/spm
build/spm:
	swift build

.PHONY: build/xcode
build/xcode:
	xcodebuild build -project $(PROJECT) -scheme $(SCHEME)

.PHONY: test
test: test/spm

.PHONY: test/spm
test/spm:
	swift test --parallel

.PHONY: test/xcode
test/xcode:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -parallel-testing-enabled YES

.PHONY: test/examples
test/examples:
	swift test --package-path Examples

.PHONY: test/docker
test/docker: clean/spm linuxmain
	docker run -it --rm -v `pwd`:/tablier -w /tablier swift:5.0 swift test  

.PHONY: xcodeproj
xcodeproj: $(PROJECT)
$(PROJECT): .FORCE
	swift package generate-xcodeproj \
		--enable-code-coverage \
		--skip-extra-files \
		--xcconfig-overrides $(XCCONFIG)

.PHONY: linuxmain
linuxmain:
	swift test --generate-linuxmain

.PHONY: lint/xcodeproj
lint/xcodeproj:
	./Scripts/check_xcodeproj_diff.sh

LATEST_VERSION = $(shell git describe --tags `git rev-list --tags --max-count=1`)

.PHONY: clean
clean: clean/xcode clean/spm
	$(RM) -r $(PROJECT)

.PHONY: clean/xcode
clean/xcode: 
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME)

.PHONY: clean/spm
clean/spm: 
	swift package clean

.PHONY: .FORCE
.FORCE: