---
name: shuttle
description: Use when sending code, URLs, or text to Brandan's clipboard via the Shuttle Mac app. Triggers when sharing code snippets, authentication URLs, or any text Brandan needs to copy.
---

# Shuttle - Terminal to Mac Bridge

Shuttle sends text to both the Mac Shuttle app (popup window) AND Telegram. Use it whenever Brandan needs to copy something. Always use `shuttle-send` (not `shuttle`) so it goes to both places.

## When to Use

- Sharing code snippets that Brandan wants to copy
- Providing authentication URLs (which often get broken by terminal line wrapping)
- Any time you'd normally say "copy this" -- use Shuttle instead so Brandan can one-click copy

## Commands

### Copy text (sends to Shuttle app + Telegram)
```bash
shuttle-send copy "text to copy here"
```

### Copy multi-line text (use heredoc)
```bash
shuttle-send copy "$(cat <<'EOF'
line 1
line 2
line 3
EOF
)"
```

### Fix a broken URL (cleans and sends to both)
```bash
shuttle-send url "https://example.com/broken/
url/from/terminal/wrapping"
```

### Pipe text
```bash
echo "some output" | shuttle-send copy
```

## Behavior

- **Mac Shuttle app:** Floating window with text and "Copy to Clipboard" button. Window closes after copy.
- **Telegram:** Text sent as a message to Brandan's Telegram bot. He can copy from there on his phone.
- **URLs:** Shuttle app shows "Open in Browser" button. Telegram sends the cleaned URL.
- Both happen simultaneously.

## Location

- App: `/Applications/Shuttle.app`
- CLI (app only): `~/.local/bin/shuttle`
- CLI (both): `~/.local/bin/shuttle-send`
- Source: `~/Shuttle/`
- Repo: https://github.com/brandankraft/Shuttle
