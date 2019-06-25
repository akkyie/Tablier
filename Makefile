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

.PHONY: xcodeproj
xcodeproj: $(PROJECT)
$(PROJECT): .FORCE
	swift package generate-xcodeproj --enable-code-coverage --xcconfig-overrides $(XCCONFIG)

LATEST_VERSION = $(shell git describe --tags `git rev-list --tags --max-count=1`)
.PHONY: update
update: .FORCE
ifeq ($(VERSION),)
	$(error No VERSION specified; run `make $@ VERSION=x.y.z`)
endif
ifeq ($(VERSION),$(LATEST_VERSION))
	$(error Tag "$(VERSION)" already exists)
endif
	echo $(VERSION) > ./VERSION
	git add ./VERSION
	git commit -m "Bump version to $(VERSION)"
	git tag $(VERSION)

.PHONY: clean
clean: clean/xcode
	$(RM) -r $(PROJECT)

.PHONY: clean/xcode
clean/xcode: 
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME)

.PHONY: .FORCE
.FORCE: