#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="${HOME}/.agents"
CANONICAL_CODEX_HOME="${HOME}/.codex"
TARGET_HOMES=(
  "${HOME}/.codex"
  "${HOME}/.codex-163"
  "${HOME}/.codex-yyl"
)

link_path() {
  local source_path="$1"
  local target_path="$2"
  rm -rf "${target_path}"
  ln -s "${source_path}" "${target_path}"
}

mkdir -p "${AGENTS_DIR}/skills"
mkdir -p "${CANONICAL_CODEX_HOME}"

link_path "${REPO_DIR}/agents/config.toml" "${AGENTS_DIR}/config.toml"
link_path "${REPO_DIR}/agents/rules" "${AGENTS_DIR}/rules"

for skill_path in "${REPO_DIR}"/agents/skills/*; do
  skill_name="$(basename "${skill_path}")"
  ln -sfn "${skill_path}" "${AGENTS_DIR}/skills/${skill_name}"
done

link_path "${REPO_DIR}/codex/AGENTS.md" "${CANONICAL_CODEX_HOME}/AGENTS.md"

for home in "${TARGET_HOMES[@]}"; do
  mkdir -p "${home}/skills"
  link_path "${REPO_DIR}/agents/config.toml" "${home}/config.toml"
  link_path "${REPO_DIR}/codex/AGENTS.md" "${home}/AGENTS.md"
  link_path "${REPO_DIR}/agents/rules" "${home}/rules"
done

echo "Bootstrap complete."
echo "Shared skills: ${AGENTS_DIR}/skills"
echo "Shared config: ${AGENTS_DIR}/config.toml"
echo "Shared rules: ${AGENTS_DIR}/rules"
echo "Canonical AGENTS: ${CANONICAL_CODEX_HOME}/AGENTS.md"
