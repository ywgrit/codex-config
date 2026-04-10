# Update Script Design

## Goal

Add a dedicated `update.sh` workflow for machines that already cloned `codex-config`.

## Scope

This design covers:

- pulling the latest shared configuration from the tracked git remote
- refusing to continue when the local repository has uncommitted changes
- re-running `scripts/bootstrap.sh` after a successful pull
- forwarding bootstrap arguments such as `--home`
- printing useful status output for the operator

This design does not cover first-time cloning, automatic stashing, automatic commits, or automatic pushes.

## Decisions

### 1. `update.sh` is for existing clones only

The script assumes the repository already exists locally. First-time setup remains the job of `scripts/bootstrap.sh` plus a manual `git clone`.

### 2. Dirty working tree must stop the update

Before pulling, `update.sh` must check repository status and abort if tracked or untracked changes exist.

Reasoning:

- this matches the user's explicit requirement
- it prevents accidental overwrite or confusing merge states
- it keeps the sync workflow predictable

### 3. Pull strategy is fast-forward only

The script should run `git pull --ff-only` so it never creates implicit merge commits.

### 4. Bootstrap is always rerun after a successful pull

After pulling, the script should invoke `scripts/bootstrap.sh "$@"` to refresh symlinks for all managed homes or the manually provided subset.

### 5. Operator-visible status output

The script should print:

- current repository root
- current branch
- starting commit
- ending commit
- whether the repository was already up to date or actually advanced

## Error Handling

- dirty working tree: print an actionable error and exit non-zero
- no upstream branch: let `git pull --ff-only` fail loudly
- bootstrap failure: exit immediately because `set -euo pipefail` is active
- bad bootstrap arguments: let `bootstrap.sh` validate and fail

## Verification

Verify the script with isolated temporary repositories:

1. dirty working tree causes an immediate non-zero exit before pull
2. clean clone can pull a newer commit from origin and then rerun bootstrap
3. forwarded `--home` arguments reach `bootstrap.sh`
4. `--help` output explains the workflow
