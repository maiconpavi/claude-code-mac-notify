# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-04-28

### Changed
- Banner subtitle now mirrors the title that Claude.app shows in its sidebar and the `/resume` picker. The script reads the latest `customTitle` line from the transcript JSONL, which is exactly what the app uses. No network calls.
- When a session has no `customTitle` (most short-lived sessions), the subtitle falls back to the first plain-text user message, normalized (whitespace collapsed, truncated to 60 characters). This is far more informative than the random kebab slug.
- The previous slug-only behavior is kept as a third-tier fallback for sessions with no `customTitle` and no plain-text user message (rare, e.g. sessions started with image-only input). The cwd-basename final fallback for sessions with no transcript at all is unchanged.

## [1.0.0] - 2026-04-28

### Added
- Initial release.
- `notify.sh` helper that fires macOS Notification Center banners with sound for Claude Code intervention triggers.
- Plugin manifest (`.claude-plugin/plugin.json`) and single-plugin marketplace listing (`.claude-plugin/marketplace.json`).
- Hooks definitions (`hooks/hooks.json`) for `Stop` (turn finished, Glass), `Notification` (input needed, Tink), and `PermissionRequest` matching `ExitPlanMode` (plan ready, Hero).
- Banner subtitle pulled from the session's `slug` line in the transcript JSONL so multi-session users can see which session needs attention.
- Click handler via `terminal-notifier -activate com.anthropic.claudefordesktop` to bring `Claude.app` to the foreground; falls back to `osascript` when `terminal-notifier` is missing.
- Per-session deduplication via `terminal-notifier -group "claude-code-<session_id>"`.
- README with plugin install, manual install, recommended macOS Notification Settings, and customization guides.

[Unreleased]: https://github.com/maiconpavi/claude-code-mac-notify/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/maiconpavi/claude-code-mac-notify/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/maiconpavi/claude-code-mac-notify/releases/tag/v1.0.0
