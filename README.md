# Shuttle

Bridge between terminal and Mac -- copy code snippets and fix broken URLs.

## What It Does

Shuttle is a lightweight macOS app with two features:

### 1. Copy Popup
Send text from the terminal to a popup window with a "Copy to Clipboard" button. No more manually selecting text in Terminal.

```bash
# Copy text directly
shuttle copy "your text here"

# Pipe text from a command
cat file.txt | shuttle copy

# Copy a code snippet
shuttle copy "$(pbpaste)"
```

### 2. URL Fixer
Terminal line wrapping breaks long URLs (like authentication URLs from CLI tools). Shuttle strips all whitespace and newlines to reconstruct the clean URL.

```bash
# Fix a broken URL from the command line
shuttle url "https://example.com/really/long/
path/that/got/wrapped"
```

Or click the Shuttle dock icon to open the URL Fixer GUI -- paste the broken URL and get a clean one with "Copy" and "Open in Browser" buttons.

## Install

Requires macOS 14+ and Xcode Command Line Tools.

```bash
git clone https://github.com/brandankraft/Shuttle.git
cd Shuttle
make
make install
```

This builds the app to `/Applications/Shuttle.app` and creates a CLI symlink at `~/.local/bin/shuttle`.

## Uninstall

```bash
make uninstall
```

## Usage

### From Terminal (CLI)

```bash
# Pop up a window with text and a Copy button
shuttle copy "some text to copy"

# Fix a broken URL
shuttle url "https://broken-url-with-
line-breaks"

# Pipe into shuttle
echo "piped text" | shuttle copy
```

### From Dock

Click the Shuttle icon in the Dock (or in /Applications) to open the URL Fixer window. Paste a broken URL, and it strips whitespace/newlines automatically. Then copy the clean URL or open it directly in your browser.

## Claude Code Skill

Shuttle includes a skill for [Claude Code](https://claude.com/claude-code) that lets the AI assistant send text directly to your clipboard.

### Install the Skill

Copy the skill file to your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/shuttle
cp claude-skill/SKILL.md ~/.claude/skills/shuttle/SKILL.md
```

### What It Does

Once installed, Claude Code can invoke `shuttle copy` to pop up a window with code, commands, or URLs whenever you need to copy something. No more fighting with terminal text selection.

## How It Works

- Native SwiftUI app compiled with `swiftc`
- Single source file, no Xcode project needed
- CLI and GUI in one binary
- Popup windows float above other windows for visibility

## License

MIT
