#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="${HOME}/.agents"
CANONICAL_CODEX_HOME="${HOME}/.codex"
MANUAL_HOMES=()

usage() {
  cat <<EOF
Usage: $(basename "$0") [--home PATH]...

Without --home, the script auto-discovers every existing ~/.codex* directory
under the current HOME and always configures canonical ~/.codex.

Options:
  --home PATH   Manage a specific Codex home. Repeat to manage multiple homes.
  -h, --help    Show this help text.
EOF
}

normalize_path() {
  local input_path="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath -m "${input_path}"
  else
    printf '%s\n' "${input_path}"
  fi
}

dedupe_paths() {
  local -n input_ref="$1"
  local -A seen=()
  local deduped=()
  local item

  for item in "${input_ref[@]}"; do
    [[ -n "${item}" ]] || continue
    if [[ -z "${seen[${item}]+x}" ]]; then
      seen["${item}"]=1
      deduped+=("${item}")
    fi
  done

  input_ref=("${deduped[@]}")
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --home)
        if [[ $# -lt 2 ]]; then
          echo "Missing value for --home" >&2
          usage >&2
          exit 1
        fi
        MANUAL_HOMES+=("$(normalize_path "$2")")
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done
}

build_target_homes() {
  local -n output_ref="$1"
  local discovered=()
  local path
  local normalized_path

  if [[ ${#MANUAL_HOMES[@]} -gt 0 ]]; then
    output_ref=("${MANUAL_HOMES[@]}")
  else
    for path in "${HOME}"/.codex*; do
      [[ -d "${path}" ]] || continue
      normalized_path="$(normalize_path "${path}")"
      [[ "${normalized_path}" == "${REPO_DIR}" ]] && continue
      discovered+=("${path}")
    done
    output_ref=("${discovered[@]}")
  fi

  output_ref+=("${CANONICAL_CODEX_HOME}")
  dedupe_paths output_ref
}

link_path() {
  local source_path="$1"
  local target_path="$2"
  rm -rf "${target_path}"
  ln -s "${source_path}" "${target_path}"
}

parse_args "$@"

TARGET_HOMES=()
build_target_homes TARGET_HOMES

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
echo "Managed homes:"
for home in "${TARGET_HOMES[@]}"; do
  echo "  - ${home}"
done
echo "Shared skills: ${AGENTS_DIR}/skills"
echo "Shared config: ${AGENTS_DIR}/config.toml"
echo "Shared rules: ${AGENTS_DIR}/rules"
echo "Canonical AGENTS: ${CANONICAL_CODEX_HOME}/AGENTS.md"
