XCBUILD = xcodebuild build-for-testing test-without-building ENABLE_TESTABILITY=YES
XCWORKSPACE = -workspace CassowaryUI.xcworkspace
MACOS = -destination 'platform=OS X'
IOS = -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.0'
TVOS = -destination 'platform=tvOS Simulator,name=Apple TV 1080p,OS=11.0'

test-xcode-macos:
	$(XCBUILD) $(MACOS) -scheme Cassowary-Package $(XCWORKSPACE) | xcpretty

test-xcode-ios:
	$(XCBUILD) $(IOS) -scheme Cassowary-Package $(XCWORKSPACE) | xcpretty
	$(XCBUILD) $(IOS) -scheme CassowaryUI $(XCWORKSPACE) | xcpretty

test-xcode-tvos:
	$(XCBUILD) $(TVOS) -scheme Cassowary-Package $(XCWORKSPACE) | xcpretty
