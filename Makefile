PROJECT = Tablier.xcodeproj
XCCONFIG = Configs/SwiftPM.xcconfig

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
clean: 
	$(RM) -r $(PROJECT)

.PHONY: .FORCE
.FORCE: