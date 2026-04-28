# Privacy Policy

`claude-code-mac-notify` is an open-source, local-only plugin. The author does not collect, store, or transmit any user data.

## What the plugin does

When triggered by a Claude Code hook event (`Stop`, `Notification`, or `PermissionRequest`), the plugin's `notify.sh` script:

1. Reads the hook payload from standard input. The payload is provided by Claude Code itself and contains the current working directory, the session id, and the path to the session's transcript file. None of this leaves your machine.
2. Reads the latest `slug` line from your transcript JSONL file (`~/.claude/projects/...`) so the banner subtitle can show your session title.
3. Calls `terminal-notifier` (or, as a fallback, `osascript`) to display a macOS Notification Center banner.

## What the plugin does **not** do

- It does not make any network requests.
- It does not collect telemetry, analytics, or crash reports.
- It does not send the session title, hook payload, or any other data to the author or any third party.
- It does not write any logs.

## Third-party software invoked

The plugin invokes `terminal-notifier` and `osascript`. Those tools are governed by their own licenses and have their own behavior. Refer to their documentation:

- [`terminal-notifier`](https://github.com/julienXX/terminal-notifier) — MIT.
- `osascript` — part of macOS.

Neither tool sends data off-device when used as documented in this plugin.

## Permissions used by the plugin

- Reads `~/.claude/projects/<sanitized-cwd>/<session-id>.jsonl` (your local Claude Code transcript) only to extract the session slug.
- Reads `~/.claude/hooks/notify.sh` (or, when installed via the plugin manager, `~/.claude/plugins/cache/.../scripts/notify.sh`).
- Calls macOS Notification Center via `terminal-notifier` or `osascript`.

That is the full set.

## Changes

If this policy ever changes (for example, if a new feature requires a different scope), the change will appear in this file and in [`CHANGELOG.md`](CHANGELOG.md) before being released.

## Contact

Questions about this policy: maicon.pavi.vieira@gmail.com.
