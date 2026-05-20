# verify-before-stop.sh

> A Claude Code Stop hook that blocks the session from ending until verification is logged. Stops "lies of completion" cold.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-rose)](https://docs.anthropic.com/en/docs/claude-code)
[![No deps](https://img.shields.io/badge/dependencies-zero-emerald)](#install)

## The problem

If you've used Claude Code for more than a week, you've seen this:

```
Claude: "All tests passing ✅"
You:    [merges]
Prod:   [breaks]
You:    [2h debugging]
Tomorrow: [same cycle]
```

The model isn't lying on purpose — it's just optimistic about its own work. The fix isn't a better prompt. The fix is a **workflow guard**.

## What this does

A Stop hook that fires when Claude tries to end a session. Logic:

1. Check `git diff` + untracked files
2. If files changed → require a `VERIFIED` log entry in `.claude/state/stop-verify.log` from the last 5 minutes
3. If missing → block the stop, print exact instructions for what the model must do
4. If no files changed → allow stop (pure conversation, no friction)

The model has to **prove** it verified, or **admit** it didn't. The block forces a follow-up turn.

## Install (60 seconds)

```bash
# 1. Drop into your project
mkdir -p .claude/hooks
curl -O https://raw.githubusercontent.com/ianymu/claude-verify-before-stop/main/verify-before-stop.sh
mv verify-before-stop.sh .claude/hooks/
chmod +x .claude/hooks/verify-before-stop.sh

# 2. Add to .claude/settings.json
```

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "*",
      "hooks": [
        { "type": "command", "command": "bash .claude/hooks/verify-before-stop.sh" }
      ]
    }]
  }
}
```

```bash
# 3. Restart Claude Code session
```

## How verification works

Inside a Claude session, the agent needs to log what it verified:

```bash
# Example: after running tests
npm test
echo "$(date +%s)|VERIFY_ACTION|npm test passed" >> .claude/state/stop-verify.log
echo "$(date +%s)|VERIFIED" >> .claude/state/stop-verify.log
```

Or via curl for HTTP services, `psql` for DB schemas, `playwright` for UI, etc. — whatever proves the work actually works.

The hook gives the model a **5-minute window**: log a `VERIFIED` entry, then it can end the session.

## Why this works (12-month battle test)

Battle-tested on 14 parallel Claude Code projects shipping on 6 platforms (web, WeChat, X, Reddit, etc.). Real wins:

- Eliminated **"AI says tests pass, they didn't"** regressions
- Forces **explicit verification logging** which doubles as an audit trail
- Survives **conversation compaction** (log file persists)
- **Zero deps** — pure bash + python3 stdlib (already on every Mac/Linux)

## Want the rest?

This is the **gold-tier hook** from a larger 6-hook pack I maintain.

The other 5:

| Hook | What it stops |
|------|---------------|
| `force-progress-update.sh` | Mid-session context drift (every 5 actions → checkpoint) |
| `cost-tracker.sh` | Surprise $40 Opus bills (logs spend to `costs.jsonl` realtime) |
| `block-secrets.sh` | API key leaks (PreToolUse scan for `sk-ant-`, JWT, AWS, GitHub PATs) |
| `pre-compact-diary.sh` | Lost WIP context when conversation compacts |
| `enforce-autoplan.sh` | "Let me just implement this quickly" → 4h of regret |

**Full pack: [$49 launch price](https://landing-ianymu.vercel.app)** (regular $79), 30-day money-back, instant download.

Or just use this one for free — it delivers most of the value.

## License

MIT — use, modify, redistribute, fork. Just don't claim you wrote it.

## Contributing

Issues / PRs welcome. If you build a complementary hook, link it in your PR and I'll add it to the README.

## Contact

Ian — `ian.y.mu@gmail.com` — [landing page](https://landing-ianymu.vercel.app)
