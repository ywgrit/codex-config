#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") [bootstrap-args...]

Update an existing codex-config clone by:
  1. refusing to continue when the repository is dirty
  2. running git pull --ff-only
  3. rerunning scripts/bootstrap.sh with any provided arguments

Examples:
  ./scripts/update.sh
  ./scripts/update.sh --home "\$HOME/.codex" --home "\$HOME/.codex-163"
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_status="$(git -C "${REPO_DIR}" status --porcelain)"
if [[ -n "${repo_status}" ]]; then
  echo "Working tree is not clean. Commit, stash, or discard changes before running update.sh." >&2
  exit 1
fi

branch_name="$(git -C "${REPO_DIR}" rev-parse --abbrev-ref HEAD)"
before_commit="$(git -C "${REPO_DIR}" rev-parse HEAD)"

echo "Repository: ${REPO_DIR}"
echo "Branch: ${branch_name}"
echo "Starting commit: ${before_commit}"
echo "Pulling latest changes..."

git -C "${REPO_DIR}" pull --ff-only

after_commit="$(git -C "${REPO_DIR}" rev-parse HEAD)"
if [[ "${after_commit}" == "${before_commit}" ]]; then
  echo "Repository was already up to date."
else
  echo "Updated commit: ${after_commit}"
fi

echo "Re-running bootstrap..."
"${REPO_DIR}/scripts/bootstrap.sh" "$@"

echo "Update complete."
