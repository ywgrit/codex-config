# codex-config

Canonical Codex configuration for multiple local accounts and new machines.

## What This Repo Tracks

- `agents/config.toml`
- `agents/rules/default.rules`
- `agents/skills/opencli-*`
- `codex/AGENTS.md`

## What This Repo Does Not Track

These files are account or machine state, not shared configuration:

- `auth.json`
- `sessions/`
- `history.jsonl`
- `memories/`
- `logs_*.sqlite`
- `state_*.sqlite`
- `cache/`
- `tmp/`
- `shell_snapshots/`

## Bootstrap On A New Machine

```bash
git clone <your-github-repo> ~/Documents/github/codex-config
cd ~/Documents/github/codex-config
./scripts/bootstrap.sh
```

After bootstrap:

- shared skills live under `~/.agents/skills`
- shared config lives at `~/.agents/config.toml`
- shared rules live at `~/.agents/rules`
- canonical global AGENTS file lives at `~/.codex/AGENTS.md`
- other Codex homes link their `AGENTS.md`, `config.toml`, and `rules/` back to the canonical files

## Supported Local Homes

The bootstrap script currently links these homes when they exist:

- `~/.codex`
- `~/.codex-163`
- `~/.codex-yyl`

It is safe to rerun the script after pulling updates.
