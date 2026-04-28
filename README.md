# claude-code-mac-notify

macOS Notification Center alerts and sounds for [Claude Code](https://www.anthropic.com/claude-code) intervention triggers. Three events, three distinct sounds, clickable banner that activates `Claude.app`.

| Event | Sound | Banner message |
| --- | --- | --- |
| `Stop` (turn ends) | Glass | Turn finished |
| `Notification` (input needed, permission prompt) | Tink | Input needed |
| `PermissionRequest` matching `ExitPlanMode` (plan ready for review) | Hero | Plan ready for review |

The banner subtitle shows the current session's title (the slug from your transcript), so when several sessions run in parallel you can tell which one wants you.

## Why

If you keep more than one Claude Code session running at once, you have probably looked at four terminals trying to find the one that finished its turn. This hook fires a banner with the session title every time Claude needs you, plays a different sound per event, and brings `Claude.app` to the front when you click it.

## Requirements

**Required**

- macOS (the script calls `osascript`, which ships with macOS).
- [`jq`](https://stedolan.github.io/jq/) — usually preinstalled on macOS via the Xcode Command Line Tools. If not: `brew install jq`.
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — any reasonably recent version that supports the [`hooks`](https://code.claude.com/docs/en/hooks-guide.md) configuration in `~/.claude/settings.json` and the [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces.md).

**Optional but recommended**

- [`terminal-notifier`](https://github.com/julienXX/terminal-notifier) — `brew install terminal-notifier`. **Without it the plugin still works**: it falls back to `osascript display notification` and you still get banners with sound. You only lose two things: clicking the banner does nothing (instead of bringing `Claude.app` to the foreground), and per-session banner deduplication via `-group` is unavailable.

## Install (recommended: as a plugin)

```text
/plugin marketplace add maiconpavi/claude-code-mac-notify
/plugin install claude-code-mac-notify@maiconpavi-plugins
```

Then:

1. Trigger any banner once (start and end a quick turn). macOS will ask whether to allow notifications from `terminal-notifier` — click **Allow**. If you dismiss this prompt, every banner after that is silently dropped.
2. Tune your `terminal-notifier` notification settings (see the section below).
3. **If you previously installed this hook by hand**, remove the three matching entries (`Stop`, `Notification`, `PermissionRequest` with matcher `ExitPlanMode` pointing at `notify.sh`) from `~/.claude/settings.json` so each event does not fire twice.

## Install (manual, no plugin)

If you would rather not enable a plugin:

```bash
# terminal-notifier is optional — drop it if you don't want clickable banners
brew install jq terminal-notifier
mkdir -p ~/.claude/hooks
curl -fsSL https://raw.githubusercontent.com/maiconpavi/claude-code-mac-notify/main/scripts/notify.sh \
  -o ~/.claude/hooks/notify.sh
chmod +x ~/.claude/hooks/notify.sh
```

Then merge the entries from [`hooks/hooks.json`](hooks/hooks.json) into the `hooks` object in your `~/.claude/settings.json`. When merging by hand, replace `${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh` with `$HOME/.claude/hooks/notify.sh` and prefix the command with `bash`. The result looks like:

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command",
        "command": "bash $HOME/.claude/hooks/notify.sh 'Turn finished' Glass",
        "async": true, "timeout": 3 } ] }
    ],
    "Notification": [
      { "hooks": [ { "type": "command",
        "command": "bash $HOME/.claude/hooks/notify.sh 'Input needed' Tink",
        "async": true, "timeout": 3 } ] }
    ],
    "PermissionRequest": [
      { "matcher": "ExitPlanMode",
        "hooks": [ { "type": "command",
          "command": "bash $HOME/.claude/hooks/notify.sh 'Plan ready for review' Hero",
          "async": true, "timeout": 3 } ] }
    ]
  }
}
```

## Recommended macOS notification settings

Open `System Settings → Notifications → terminal-notifier` and configure:

| Setting | Recommended | Why |
| --- | --- | --- |
| **Allow notifications** | On | Required. macOS asks once on the first banner; if you missed the prompt, toggle it on here. |
| **Show in: Desktop** | On | Banner appears on your active space. |
| **Show in: Notification Center** | On | A missed banner stays reachable in the side panel. |
| **Show in: Lock Screen** | Off | Off by default to avoid leaking session titles when away from the Mac. Turn on if your Mac is private. |
| **Alert Style** | **Persistent** | Persistent banners stay until clicked or dismissed. Temporary banners disappear in ~5 seconds, easy to miss when alt-tabbing. |
| **Badge application icon** | On | Adds a count on the `terminal-notifier` Dock icon if pinned. Optional. |
| **Play sound for notification** | On | Required. The hook is built around audible cues — the three events use Glass, Tink, and Hero sounds so you can recognize them without looking. |
| **Show previews** | Default | The session title is the whole point of the subtitle. |
| **Notification grouping** | Off | The hook already deduplicates per session via `terminal-notifier -group "claude-code-<session_id>"`, so each session collapses its own banners. Leaving the OS grouping on would over-collapse across sessions. |

Focus / Do Not Disturb modes apply normally. While a Focus mode is on, banners may be filtered or routed to the Notification Center summary. The hook still fires; macOS decides whether to surface it.

## How it works

`notify.sh` reads the [hook stdin payload](https://code.claude.com/docs/en/hooks.md) (`cwd`, `session_id`, `transcript_path`), looks up the most recent `slug` line in the transcript JSONL to get the session title, and fires a banner via `terminal-notifier`. The banner uses `-activate com.anthropic.claudefordesktop` so clicking it brings `Claude.app` to the foreground (whichever tab was last active is what you see). If `terminal-notifier` is missing, it falls back to `osascript display notification` (banner still fires, but click is inert).

## Customization

- **Pick different sounds**: the second positional argument to `notify.sh` is any sound name from `/System/Library/Sounds/` (without the `.aiff` extension). Try Funk, Pop, Submarine, Bottle, Frog, Purr.
- **Add more triggers**: any of [the supported hook events](https://code.claude.com/docs/en/hooks-guide.md) (such as `PreCompact`, `SessionStart`, `UserPromptSubmit`) can be wired to the same script with a different reason and sound.
- **Drop the click handler**: `terminal-notifier` is what makes the banner clickable. If you remove it, banners still fire via `osascript` but clicking does nothing — handy if you do not want the brew dependency.

## Limitations

- Click activates `Claude.app` but does not focus the specific session tab. The Mac app does not currently expose a `claude://focus?session=<id>` URL scheme; the existing `claude://resume?session=<id>` deep link spawns a duplicate tab, which is worse than just bringing the app to the front. If Anthropic adds a tab-focus URL, this README will be updated.

## Contributing

PRs welcome — especially Linux/Windows ports, additional event coverage, and richer customization.

## License

[MIT](LICENSE).
