#!/usr/bin/env bash

set -uo pipefail

if [[ "${1-}" == "--" ]]; then
  shift
fi

if (( $# == 0 )); then
  echo "usage: with-preserved-git-config.sh [--] command [args ...]" >&2
  exit 2
fi

git_config_guard_path="$(git rev-parse --git-path config)" || exit 2
if [[ "$git_config_guard_path" != /* ]]; then
  git_config_guard_path="$(pwd)/$git_config_guard_path"
fi

if [[ ! -f "$git_config_guard_path" || -L "$git_config_guard_path" ]]; then
  echo "error: repository Git config is not a regular file: $git_config_guard_path" >&2
  exit 2
fi

git_config_guard_dir="$(mktemp -d)" || exit 2
git_config_guard_backup="$git_config_guard_dir/config"
git_config_guard_lock="$git_config_guard_path.lock"
git_config_guard_lock_token="$git_config_guard_dir/owner"
git_config_guard_signature=''
git_config_guard_restore_temp=''

if ! (
  set -o noclobber
  printf '%s\n' "$git_config_guard_lock_token" >"$git_config_guard_lock"
) 2>/dev/null; then
  echo "error: repository Git config is already locked: $git_config_guard_lock" >&2
  rmdir -- "$git_config_guard_dir" 2>/dev/null || true
  exit 2
fi

if ! git_config_guard_signature="$(stat -c '%f:%u:%g' -- "$git_config_guard_path")"; then
  rm -f -- "$git_config_guard_lock"
  rmdir -- "$git_config_guard_dir" 2>/dev/null || true
  exit 2
fi

if ! cp -p -- "$git_config_guard_path" "$git_config_guard_backup"; then
  rm -f -- "$git_config_guard_lock"
  rmdir -- "$git_config_guard_dir" 2>/dev/null || true
  exit 2
fi

config_matches_snapshot() {
  [[ -f "$git_config_guard_path" && ! -L "$git_config_guard_path" ]] || return 1
  cmp -s -- "$git_config_guard_backup" "$git_config_guard_path" || return 1
  [[ "$(stat -c '%f:%u:%g' -- "$git_config_guard_path" 2>/dev/null)" == "$git_config_guard_signature" ]]
}

release_config_lock() {
  [[ -f "$git_config_guard_lock" && ! -L "$git_config_guard_lock" ]] || return 1
  [[ "$(<"$git_config_guard_lock")" == "$git_config_guard_lock_token" ]] || return 1
  rm -f -- "$git_config_guard_lock"
}

restore_git_config() {
  git_config_guard_status=$?
  git_config_guard_safe=1
  trap '' HUP INT TERM
  trap - EXIT

  if ! config_matches_snapshot; then
    git_config_guard_restore_temp="$(mktemp "${git_config_guard_path}.restore.XXXXXX")" ||
      git_config_guard_safe=0

    if (( git_config_guard_safe )) &&
      cp -p -- "$git_config_guard_backup" "$git_config_guard_restore_temp" &&
      mv -fT -- "$git_config_guard_restore_temp" "$git_config_guard_path" &&
      config_matches_snapshot; then
      git_config_guard_restore_temp=''
      echo "Restored repository Git config after the guarded command changed it." >&2
    else
      echo "error: could not restore repository Git config: $git_config_guard_path" >&2
      echo "The original config backup remains at: $git_config_guard_backup" >&2
      git_config_guard_status=1
      git_config_guard_safe=0
    fi
  fi

  if (( git_config_guard_safe )) && ! release_config_lock; then
    echo "error: could not safely release repository Git config lock: $git_config_guard_lock" >&2
    echo "The original config backup remains at: $git_config_guard_backup" >&2
    git_config_guard_status=1
    git_config_guard_safe=0
  fi

  if [[ -n "$git_config_guard_restore_temp" ]]; then
    rm -f -- "$git_config_guard_restore_temp"
  fi

  if (( git_config_guard_safe )); then
    rm -f -- "$git_config_guard_backup"
    rmdir -- "$git_config_guard_dir" 2>/dev/null || true
  fi
  exit "$git_config_guard_status"
}

trap restore_git_config EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

"$@"
git_config_guard_command_status=$?
exit "$git_config_guard_command_status"
