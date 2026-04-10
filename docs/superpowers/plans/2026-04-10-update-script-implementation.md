# Update Script Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a safe `update.sh` command for existing `codex-config` clones that pulls the latest repository state and reapplies shared symlinks.

**Architecture:** `update.sh` lives beside `bootstrap.sh`, derives the repository root from its own location, refuses to run on a dirty working tree, then performs `git pull --ff-only` followed by `bootstrap.sh "$@"`. A shell-based regression test exercises dirty-tree refusal and a successful update path using temporary repositories.

**Tech Stack:** Bash, git, temporary directories

---

### Task 1: Document the update workflow

**Files:**
- Create: `docs/superpowers/specs/2026-04-10-update-script-design.md`

- [x] **Step 1: Write the design**

Capture purpose, dirty-tree behavior, pull strategy, bootstrap forwarding, and verification scope.

### Task 2: Add a failing regression test

**Files:**
- Create: `tests/update-script.sh`

- [ ] **Step 1: Write dirty-tree refusal coverage**

Create a shell test that prepares a temporary git origin and a local clone, introduces an uncommitted change, runs `scripts/update.sh`, and expects a non-zero exit plus an error message.

- [ ] **Step 2: Write successful update coverage**

Extend the same shell test to create a newer commit in origin, run `scripts/update.sh --home <path>` from a clean clone, and assert that the clone advances and bootstrap-created symlinks exist.

- [ ] **Step 3: Run the test to verify it fails**

Run: `bash tests/update-script.sh`
Expected: FAIL because `scripts/update.sh` does not exist yet.

### Task 3: Implement `update.sh`

**Files:**
- Create: `scripts/update.sh`

- [ ] **Step 1: Add repository and status helpers**

Derive `REPO_DIR`, inspect branch/commit state, and check for a dirty working tree.

- [ ] **Step 2: Add update execution flow**

Implement `git pull --ff-only`, capture before/after commits, and invoke `scripts/bootstrap.sh "$@"`.

- [ ] **Step 3: Add operator output**

Print concise status lines that show the repo root, branch, and commit transition.

### Task 4: Document usage

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Document the difference between bootstrap and update**

Explain that `bootstrap.sh` is for first setup or manual relinking, while `update.sh` is the standard command after `git pull` would normally be used.

- [ ] **Step 2: Document the dirty-tree stop rule**

State that `update.sh` aborts when the local repo has uncommitted changes.

### Task 5: Verify behavior

**Files:**
- Test: `tests/update-script.sh`
- Test: `scripts/update.sh`
- Test: `README.md`

- [ ] **Step 1: Run the shell regression test**

Run: `bash tests/update-script.sh`
Expected: PASS

- [ ] **Step 2: Run update help output**

Run: `bash scripts/update.sh --help`
Expected: usage text describing the dirty-tree check and bootstrap forwarding.

- [ ] **Step 3: Review repository status**

Run: `git status --short`
Expected: only the intended new script, docs, tests, and README edits appear.
