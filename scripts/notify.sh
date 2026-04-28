#!/usr/bin/env bash
# macOS Notification Center alert for Claude Code intervention triggers.
# Click → activates Claude.app (focuses whichever tab is foreground). Subtitle shows session title.
# Note: claude://resume?session=<id> deep-link works but spawns a duplicate tab; not used.
# Args: $1 = reason text (e.g. "Turn finished"), $2 = sound name (Glass, Tink, Hero, ...)
reason="${1:-Claude}"
sound="${2:-Glass}"

payload="$(cat 2>/dev/null || true)"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)"
[ -z "$cwd" ] && cwd="$PWD"
sid="$(printf '%s' "$payload" | jq -r '.session_id // empty' 2>/dev/null)"
transcript="$(printf '%s' "$payload" | jq -r '.transcript_path // empty' 2>/dev/null)"

# Fall back to deriving transcript path from cwd + session_id.
if [ -z "$transcript" ] && [ -n "$sid" ] && [ -n "$cwd" ]; then
    sanitized="$(printf '%s' "$cwd" | sed 's|/|-|g; s|\.|-|g')"
    transcript="$HOME/.claude/projects/${sanitized}/${sid}.jsonl"
fi

# Resolve subtitle: prefer the title Claude.app shows, fall back to a clean
# preview of the first user message, then to the slug, then to the cwd basename.
title=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    # 1. customTitle — same string Claude.app shows in /resume picker and Mac sidebar.
    title="$(jq -r 'select(.type=="custom-title") | .customTitle // empty' "$transcript" 2>/dev/null \
        | awk 'NF' | tail -1)"

    # 2. First plain-text user message (skip tool_result follow-ups), normalize + truncate.
    if [ -z "$title" ]; then
        title="$(jq -r '
            select(.type=="user"
              and (.message.content | type == "string"
                   or (.message.content | type == "array" and (.[0]?.type == "text"))))
            | (if (.message.content | type == "string")
                 then .message.content
                 else .message.content[0].text
               end)
        ' "$transcript" 2>/dev/null \
            | awk 'NF' | head -1 | tr '\n' ' ' \
            | sed 's/[[:space:]]\{1,\}/ /g; s/^ //; s/ $//' \
            | cut -c 1-60)"
    fi

    # 3. slug — original v1.0.0 behavior, kept as a final transcript-based fallback.
    if [ -z "$title" ]; then
        title="$(jq -r '.slug // empty' "$transcript" 2>/dev/null | awk 'NF' | tail -1)"
    fi
fi

# 4. cwd basename — used when there is no transcript at all.
if [ -z "$title" ]; then
    title="$(printf '%s' "$cwd" | awk -F/ '{ if (NF>=2) print $(NF-1)"/"$NF; else print $NF }')"
fi

subtitle="$title"

# Prefer terminal-notifier (clickable, deep-links to session). Fall back to osascript.
TN="$(command -v terminal-notifier 2>/dev/null)"
if [ -n "$TN" ] && [ -n "$sid" ]; then
    "$TN" \
        -title "Claude Code" \
        -subtitle "$subtitle" \
        -message "$reason" \
        -sound "$sound" \
        -group "claude-code-$sid" \
        -activate "com.anthropic.claudefordesktop" \
        >/dev/null 2>&1 || true
else
    esc_reason=$(printf '%s' "$reason"   | sed 's/"/\\"/g')
    esc_sub=$(   printf '%s' "$subtitle" | sed 's/"/\\"/g')
    osascript -e "display notification \"$esc_reason\" with title \"Claude Code\" subtitle \"$esc_sub\" sound name \"$sound\"" >/dev/null 2>&1 || true
fi
