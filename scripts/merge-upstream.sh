#!/usr/bin/env bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: run this from inside a git repository" >&2
  exit 1
}

cd "$repo_root"

current_branch="$(git branch --show-current)"

if [[ -z "$current_branch" ]]; then
  echo "error: detached HEAD is not supported" >&2
  exit 1
fi

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "error: missing 'upstream' remote" >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "error: missing 'origin' remote" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree is not clean" >&2
  echo "commit or stash your changes before merging upstream" >&2
  exit 1
fi

echo "Fetching upstream/$current_branch..."
git fetch upstream "$current_branch"

if ! git show-ref --verify --quiet "refs/remotes/upstream/$current_branch"; then
  echo "error: upstream/$current_branch does not exist" >&2
  exit 1
fi

echo "Merging upstream/$current_branch into $current_branch..."
git merge --no-edit "upstream/$current_branch"

echo "Pushing $current_branch to origin..."
git push origin "$current_branch"

echo "Done."
