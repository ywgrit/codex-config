# codex-config

Canonical Codex configuration for multiple local accounts and new machines.

## What This Repo Tracks

- `agents/config.toml`
- `agents/rules/default.rules`
- `agents/skills/opencli-*`
- `codex/AGENTS.md`
- `scripts/bootstrap.sh`
- `docs/superpowers/specs/`
- `docs/superpowers/plans/`

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
git clone <your-github-repo> <where-you-want-codex-config>
cd <where-you-want-codex-config>
./scripts/bootstrap.sh
```

After bootstrap:

- shared skills live under `~/.agents/skills`
- shared config lives at `~/.agents/config.toml`
- shared rules live at `~/.agents/rules`
- canonical global AGENTS file lives at `~/.codex/AGENTS.md`
- other Codex homes link their `AGENTS.md`, `config.toml`, and `rules/` back to the canonical files
- the repo path is inferred from the location of `scripts/bootstrap.sh`, so the clone destination is your choice

## Update An Existing Machine

For machines that already cloned this repo, use:

```bash
./scripts/update.sh
```

`update.sh` is the standard sync command for existing clones:

- it aborts when the local repository has uncommitted changes
- it runs `git pull --ff-only`
- it reruns `scripts/bootstrap.sh`

You can forward bootstrap arguments through it:

```bash
./scripts/update.sh --home "$HOME/.codex" --home "$HOME/.codex-163"
```

## Bootstrap Options

By default, the bootstrap script:

- always configures the canonical `~/.codex` home
- auto-discovers every existing `~/.codex*` directory under the current `HOME`

If you want to manage a specific subset of homes, repeat `--home`:

```bash
./scripts/bootstrap.sh --home "$HOME/.codex" --home "$HOME/.codex-163"
```

When `--home` is provided, only the canonical `~/.codex` home and the paths you list are managed.

## Shared Configuration Workflow

This repository is the single source of truth for every shared Codex configuration change.

- Add or update shared skills in `agents/skills/`
- Change shared defaults in `agents/config.toml`
- Change shared rules in `agents/rules/`
- Change canonical global instructions in `codex/AGENTS.md`
- Change bootstrap behavior in `scripts/bootstrap.sh`

Do not treat `~/.agents` or `~/.codex*` as the source of truth. Those locations are linked working copies created by the bootstrap script.

Recommended maintenance flow:

```bash
cd <where-you-cloned-codex-config>
# edit tracked files in this repo
./scripts/bootstrap.sh
git status
git add <changed-files>
git commit -m "<title>" -m "<detailed body: what changed, why, verification>"
# ask for confirmation before running git push
```

If a future agent installs a shared skill or changes shared configuration for any account, that change must also be recorded in this repository so every account can reuse it.

## Supported Local Homes

The bootstrap script no longer hardcodes specific account names.

- Default mode: auto-discovers every existing `~/.codex*`
- Manual mode: use `--home <path>` repeatedly to choose the exact homes to manage

It is safe to rerun the script after pulling updates.
