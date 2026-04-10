#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file_contains() {
  local file_path="$1"
  local expected="$2"
  grep -Fq "${expected}" "${file_path}" || fail "Expected '${expected}' in ${file_path}"
}

assert_symlink_target() {
  local path="$1"
  local expected="$2"
  local actual
  actual="$(readlink "${path}")"
  [[ "${actual}" == "${expected}" ]] || fail "Expected ${path} -> ${expected}, got ${actual}"
}

create_seed_repo() {
  local seed_repo="$1"

  mkdir -p "${seed_repo}"
  tar --exclude=.git -cf - -C "${REPO_DIR}" . | tar -xf - -C "${seed_repo}"
  git -C "${seed_repo}" init >/dev/null
  git -C "${seed_repo}" config user.name "Codex Test"
  git -C "${seed_repo}" config user.email "codex-test@example.com"
  git -C "${seed_repo}" add .
  git -C "${seed_repo}" commit -m "seed" >/dev/null
  git -C "${seed_repo}" branch -M main >/dev/null
}

test_dirty_tree_aborts() {
  local origin_repo="${TMP_DIR}/dirty-origin.git"
  local writer_repo="${TMP_DIR}/dirty-writer"
  local clone_repo="${TMP_DIR}/dirty-clone"
  local output_file="${TMP_DIR}/dirty-output.txt"

  create_seed_repo "${writer_repo}"
  git clone --bare "${writer_repo}" "${origin_repo}" >/dev/null
  git clone "${origin_repo}" "${clone_repo}" >/dev/null

  printf '\nlocal change\n' >> "${clone_repo}/README.md"

  if (
    cd "${clone_repo}" &&
    HOME="${TMP_DIR}/dirty-home" bash ./scripts/update.sh
  ) >"${output_file}" 2>&1; then
    fail "update.sh should refuse a dirty working tree"
  fi

  assert_file_contains "${output_file}" "Working tree is not clean"
}

test_clean_repo_pulls_and_bootstraps() {
  local origin_repo="${TMP_DIR}/clean-origin.git"
  local writer_repo="${TMP_DIR}/clean-writer"
  local clone_repo="${TMP_DIR}/clean-clone"
  local home_dir="${TMP_DIR}/clean-home"
  local managed_home="${home_dir}/.codex-custom"
  local output_file="${TMP_DIR}/clean-output.txt"
  local expected_head

  create_seed_repo "${writer_repo}"
  git clone --bare "${writer_repo}" "${origin_repo}" >/dev/null
  git -C "${writer_repo}" remote add origin "${origin_repo}"
  git -C "${writer_repo}" push -u origin main >/dev/null
  git clone "${origin_repo}" "${clone_repo}" >/dev/null

  printf '\nUpdate marker.\n' >> "${writer_repo}/README.md"
  git -C "${writer_repo}" add README.md
  git -C "${writer_repo}" commit -m "update readme" >/dev/null
  git -C "${writer_repo}" push >/dev/null
  expected_head="$(git -C "${writer_repo}" rev-parse HEAD)"

  (
    cd "${clone_repo}" &&
    HOME="${home_dir}" bash ./scripts/update.sh --home "${managed_home}"
  ) >"${output_file}" 2>&1

  [[ "$(git -C "${clone_repo}" rev-parse HEAD)" == "${expected_head}" ]] || fail "Clone did not advance to the latest origin commit"
  assert_file_contains "${output_file}" "Update complete."
  assert_file_contains "${output_file}" "${expected_head}"
  assert_symlink_target "${home_dir}/.agents/config.toml" "${clone_repo}/agents/config.toml"
  assert_symlink_target "${managed_home}/AGENTS.md" "${clone_repo}/codex/AGENTS.md"
}

test_dirty_tree_aborts
test_clean_repo_pulls_and_bootstraps

echo "PASS: update.sh regression coverage"
