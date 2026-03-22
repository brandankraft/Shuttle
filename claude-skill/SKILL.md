---
name: shuttle
description: Use when sending code, URLs, or text to the user's clipboard via the Shuttle Mac app. Triggers when sharing code snippets, authentication URLs, or any text the user needs to copy.
---

# Shuttle - Terminal to Mac Bridge

Shuttle pops up a window with text and a "Copy to Clipboard" button. Use it whenever the user needs to copy something from a terminal session.

## When to Use

- Sharing code snippets the user wants to copy
- Providing authentication URLs (which often get broken by terminal line wrapping)
- Any time you'd normally say "copy this" -- use Shuttle instead for one-click copy

## Commands

### Copy text
```bash
shuttle copy "text to copy here"
```

### Copy multi-line text (use heredoc)
```bash
shuttle copy "$(cat <<'EOF'
line 1
line 2
line 3
EOF
)"
```

### Fix a broken URL
```bash
shuttle url "https://example.com/broken/
url/from/terminal/wrapping"
```

### Pipe text
```bash
echo "some output" | shuttle copy
```

## Behavior

- A floating window appears with the text displayed in a monospace font
- "Copy to Clipboard" button copies the text and the window closes automatically
- For URLs: also shows an "Open in Browser" button
- The app quits after the user copies or closes the window (when invoked from CLI)

## Location

- App: `/Applications/Shuttle.app`
- CLI: `~/.local/bin/shuttle`
- Source: `~/Shuttle/`
- Repo: https://github.com/brandankraft/Shuttle
