# Shared Codex Config Design

## Goal

Make `codex-config` the single source of truth for every shared Codex configuration change across multiple local accounts and future machines.

## Scope

This design covers:

- shared `~/.agents/skills`
- shared `config.toml`
- shared `rules`
- canonical global `AGENTS.md`
- bootstrap behavior for linking multiple `~/.codex*` homes
- workflow rules for recording configuration changes in git

This design does not cover per-account state such as authentication, sessions, memories, or history databases.

## Decisions

### 1. Repository-first shared configuration

All shared configuration must be edited in the tracked `codex-config` repository rather than directly under `~/.agents` or `~/.codex*`.

Reasoning:

- symlink targets should have exactly one canonical source
- GitHub sync only works if the canonical files live in the repository
- account-local state must stay isolated while shared behavior remains auditable

### 2. Shared-vs-local boundary

Tracked and shared:

- `agents/config.toml`
- `agents/rules/`
- `agents/skills/`
- `codex/AGENTS.md`
- `scripts/bootstrap.sh`
- repository documentation for this workflow

Not tracked and not shared:

- `auth.json`
- `sessions/`
- `history.jsonl`
- `memories/`
- sqlite state and logs
- caches and temporary files

### 3. Bootstrap behavior

The bootstrap script should:

- infer the repository root from the script location
- always configure canonical `~/.codex`
- auto-discover every existing `~/.codex*` home by default
- allow repeated `--home <path>` overrides for manual selection
- print the managed homes so the operator can verify the scope

This keeps the default path simple while preventing hardcoded account names.

### 4. Change-recording rule

Any shared configuration change must update the repository first, then re-run bootstrap so symlinked homes stay in sync.

Commits are allowed without confirmation. Pushes require explicit user confirmation.

## Error Handling

- Unknown bootstrap arguments should fail fast with usage text.
- Missing `--home` values should fail fast.
- Duplicate home paths should be deduplicated before linking.
- Canonical `~/.codex` should still be created even if no other homes exist.

## Verification

Verify the script with isolated temporary `HOME` directories:

1. Auto-discovery mode with multiple fake `~/.codex*` homes
2. Manual `--home` mode to confirm only selected homes are linked
3. `--help` output for operator guidance

Also verify that README and AGENTS instructions match the implemented behavior.
