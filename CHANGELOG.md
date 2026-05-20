# Changelog

## [1.0.0] — 2026-05-20

### Added
- `verify-before-stop.sh` — Stop hook that blocks session-end when files changed but no verification logged
- Demo SVG showing the hook in action (lies of completion → forced rerun)
- Animated terminal example in README
- 5-minute default verification TTL with configurable window
- `stop_hook_active` loop guard
- `.claude/state/stop-verify.log` audit trail (timestamped VERIFY_ACTION + VERIFIED entries)

### Battle-tested on
- macOS 14+, Ubuntu 22+
- Claude Code v2.0.x through v2.1.145
- 14 parallel projects, 12+ months production use

### Known limitations
- Does not catch fabricated VERIFIED log entries (rare in practice)
- Does not work on Windows (PRs welcome)
- Best used alongside the full 6-hook pack at https://landing-ianymu.vercel.app
