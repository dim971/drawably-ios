SIMULATOR ?= iPhone 17 Pro
DERIVED := .build/showcase
PROJECT := Showcase/DrawablyShowcase.xcodeproj

.PHONY: test build lint format showcase project clean

test:
	swift test

build:
	swift build

lint:
	swiftformat --lint .
	swiftlint lint --quiet

format:
	swiftformat .

project:
	cd Showcase && xcodegen generate

showcase: project
	xcodebuild -project $(PROJECT) -scheme DrawablyShowcase \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR)' \
		-derivedDataPath $(DERIVED) build
	xcrun simctl boot "$(SIMULATOR)" 2>/dev/null || true
	xcrun simctl install booted "$(DERIVED)/Build/Products/Debug-iphonesimulator/DrawablyShowcase.app"
	xcrun simctl launch booted dev.drawably.showcase

clean:
	rm -rf .build Showcase/DrawablyShowcase.xcodeproj
