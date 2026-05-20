#!/bin/bash
# verify-before-stop.sh — FREE sample from Claude Code Productivity Hook Pack
# Full pack: https://landing-ianymu.vercel.app
#
# What it does:
#   When Claude Code tries to end a session, this hook blocks the Stop event
#   unless either: (a) no files changed, OR (b) Claude has logged a recent
#   verification action. Stops "lies of completion".
#
# Install:
#   1. Drop this file into .claude/hooks/
#   2. chmod +x .claude/hooks/verify-before-stop.sh
#   3. Add to .claude/settings.json under hooks.Stop[*].hooks[]:
#        { "type": "command", "command": "bash .claude/hooks/verify-before-stop.sh" }
#   4. Restart your Claude Code session

INPUT=$(cat)

STOP_HOOK_ACTIVE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print('true' if d.get('stop_hook_active') else 'false')" 2>/dev/null)
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

VERIFY_LOG=".claude/state/stop-verify.log"
mkdir -p .claude/state

# No file changes = pure conversation, allow stop
HAS_CHANGES=$(git diff --name-only 2>/dev/null | head -5)
HAS_UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | grep -v '.claude/state/' | head -5)
if [ -z "$HAS_CHANGES" ] && [ -z "$HAS_UNTRACKED" ]; then
    exit 0
fi

# Files changed → require verification in the last 5 minutes
if [ -f "$VERIFY_LOG" ]; then
    FIVE_MIN_AGO=$(date -v-5M +%s 2>/dev/null || date -d '5 minutes ago' +%s 2>/dev/null || echo 0)
    LAST_VERIFY=$(grep '|VERIFIED' "$VERIFY_LOG" 2>/dev/null | tail -1 | cut -d'|' -f1)
    LAST_ACTION=$(grep '|VERIFY_ACTION' "$VERIFY_LOG" 2>/dev/null | tail -1 | cut -d'|' -f1)
    if [ -n "$LAST_VERIFY" ] && [ "$LAST_VERIFY" -gt "$FIVE_MIN_AGO" ] 2>/dev/null; then
        if [ -n "$LAST_ACTION" ] && [ "$LAST_ACTION" -gt "$FIVE_MIN_AGO" ] 2>/dev/null; then
            echo "$(date +%s)|STOP_ALLOWED" >> "$VERIFY_LOG"
            exit 0
        fi
    fi
fi

echo "$(date +%s)|STOP_BLOCKED" >> "$VERIFY_LOG"
echo "BLOCKED: 文件有改动但未验证。Claude 必须先：" >&2
echo "  1) 跑测试/build/curl 验证产出" >&2
echo "  2) echo \"\$(date +%s)|VERIFY_ACTION|<什么>\" >> .claude/state/stop-verify.log" >&2
echo "  3) echo \"\$(date +%s)|VERIFIED\" >> .claude/state/stop-verify.log" >&2
echo "" >&2
echo "Want all 6 hooks? Full pack at https://landing-ianymu.vercel.app — $49 launch price" >&2
exit 2
