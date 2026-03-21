APP_NAME = Shuttle
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
INSTALL_DIR = /Applications
CLI_LINK = $(HOME)/.local/bin/shuttle

.PHONY: all clean install uninstall

all: $(APP_BUNDLE)

$(APP_BUNDLE): Sources/ShuttleApp.swift Resources/Info.plist
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@cp Resources/Info.plist $(APP_BUNDLE)/Contents/
	@swiftc \
		-o $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME) \
		-target arm64-apple-macosx14.0 \
		-parse-as-library \
		Sources/ShuttleApp.swift \
		-framework SwiftUI \
		-framework AppKit
	@echo "Build complete: $(APP_BUNDLE)"

clean:
	rm -rf $(BUILD_DIR)

install: $(APP_BUNDLE)
	@echo "Installing $(APP_NAME) to $(INSTALL_DIR)..."
	@cp -R $(APP_BUNDLE) $(INSTALL_DIR)/
	@echo "Creating CLI symlink at $(CLI_LINK)..."
	@mkdir -p $(dir $(CLI_LINK))
	@ln -sf $(INSTALL_DIR)/$(APP_NAME).app/Contents/MacOS/$(APP_NAME) $(CLI_LINK)
	@echo "Done! Use 'shuttle copy \"text\"' from terminal or open Shuttle from Dock."

uninstall:
	@echo "Removing $(APP_NAME)..."
	@rm -rf $(INSTALL_DIR)/$(APP_NAME).app
	@rm -f $(CLI_LINK)
	@echo "Uninstalled."
