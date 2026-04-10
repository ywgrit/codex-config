# Shared Codex Config Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `codex-config` the canonical source for shared Codex configuration, remove hardcoded local paths from onboarding docs, and add flexible bootstrap behavior for multiple accounts.

**Architecture:** Shared configuration stays in the tracked repository, while `~/.agents` and `~/.codex*` remain symlinked working copies. The bootstrap script derives the repo root from its own location, auto-discovers local homes by default, and accepts manual overrides when needed.

**Tech Stack:** Bash, Markdown, git, symlinks

---

### Task 1: Document the shared-config design

**Files:**
- Create: `docs/superpowers/specs/2026-04-10-shared-codex-config-design.md`

- [x] **Step 1: Write the design summary**

Document the repository-first model, shared-vs-local boundary, bootstrap behavior, and push-confirmation rule.

- [x] **Step 2: Save the design doc**

Write the approved design to the tracked repository so future machines and agents can follow the same structure.

### Task 2: Update README onboarding and maintenance workflow

**Files:**
- Modify: `README.md`

- [x] **Step 1: Remove hardcoded clone paths**

Replace fixed local directories with placeholders so the user can choose any clone location.

- [x] **Step 2: Document bootstrap modes**

Explain default auto-discovery and manual `--home` override behavior.

- [x] **Step 3: Document the maintenance workflow**

Describe that all shared configuration changes must be made in this repo, then committed here, and only pushed after explicit confirmation.

### Task 3: Improve bootstrap behavior

**Files:**
- Modify: `scripts/bootstrap.sh`

- [ ] **Step 1: Add argument parsing**

Support `--help` and repeated `--home <path>` arguments.

- [ ] **Step 2: Implement target-home discovery**

Auto-discover existing `~/.codex*` homes when no overrides are passed, while always including canonical `~/.codex`.

- [ ] **Step 3: Print managed homes**

Emit the exact list of configured homes so operators can confirm the scope.

### Task 4: Encode the workflow rule in AGENTS

**Files:**
- Modify: `codex/AGENTS.md`

- [ ] **Step 1: Add canonical-edit rule**

State that shared changes must modify files inside `codex-config`, not only the symlinked live copies.

- [ ] **Step 2: Add git workflow rule**

State that agents must check repository status after shared configuration changes, may commit locally, and must ask before pushing.

### Task 5: Verify behavior with isolated homes

**Files:**
- Test: `scripts/bootstrap.sh`
- Test: `README.md`
- Test: `codex/AGENTS.md`

- [ ] **Step 1: Run bootstrap help**

Run: `bash scripts/bootstrap.sh --help`
Expected: usage text describing default auto-discovery and repeated `--home`

- [ ] **Step 2: Verify auto-discovery in a temporary HOME**

Run the script with a temporary `HOME` containing several fake `~/.codex*` directories.
Expected: all existing fake homes plus canonical `~/.codex` are linked correctly.

- [ ] **Step 3: Verify manual override mode**

Run the script with repeated `--home` arguments in a second temporary `HOME`.
Expected: only canonical `~/.codex` and the explicitly listed homes are managed.

- [ ] **Step 4: Review repository status**

Run: `git status --short`
Expected: only the intended tracked docs and config files appear as changes.
