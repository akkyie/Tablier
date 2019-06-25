PROJECT = Tablier.xcodeproj
XCCONFIG = Configs/SwiftPM.xcconfig

.PHONY: xcodeproj
xcodeproj: $(PROJECT)
$(PROJECT): .FORCE
	swift package generate-xcodeproj --enable-code-coverage --xcconfig-overrides $(XCCONFIG)

.PHONY: clean
clean: 
	$(RM) -r $(PROJECT)

.PHONY: .FORCE
.FORCE: