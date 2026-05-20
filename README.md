# Free hook: verify-before-stop.sh

This is the **gold-tier hook** from the [Claude Code Productivity Hook Pack](https://landing-ianymu.vercel.app), released free.

## What it stops

The #1 cause of regressions in Claude Code sessions: Claude saying **"all tests passing ✅" / "done!"** when they actually aren't.

## How

When Claude tries to end a session (`Stop` hook fires):
1. Check if any files changed (git diff + untracked)
2. If yes, require a `VERIFIED` log entry from the last 5 minutes
3. If missing, block the stop and tell Claude exactly what to do

The model has to either prove it verified, or admit it didn't.

## Install (60 seconds)

```bash
# 1. Drop into your project
mkdir -p .claude/hooks
curl -O https://landing-ianymu.vercel.app/free-hook/verify-before-stop.sh
mv verify-before-stop.sh .claude/hooks/
chmod +x .claude/hooks/verify-before-stop.sh

# 2. Add to .claude/settings.json
# {
#   "hooks": {
#     "Stop": [{
#       "matcher": "*",
#       "hooks": [
#         { "type": "command", "command": "bash .claude/hooks/verify-before-stop.sh" }
#       ]
#     }]
#   }
# }

# 3. Restart Claude Code session
```

## Want the rest?

The full **6-hook pack** also includes:

- `force-progress-update.sh` — survives conversation compaction (gold tier)
- `cost-tracker.sh` — logs every $ of Opus burn (gold tier)
- `block-secrets.sh` — pre-commit guard for sk-ant-, JWT, AWS keys
- `pre-compact-diary.sh` — preserves WIP context before compaction
- `enforce-autoplan.sh` — blocks code-write until a plan exists

**$49 launch price, 30-day money-back, instant download:**

→ https://landing-ianymu.vercel.app

Built by Ian (`ian.y.mu@gmail.com`) — running 14 parallel Claude Code projects over 12 months.
