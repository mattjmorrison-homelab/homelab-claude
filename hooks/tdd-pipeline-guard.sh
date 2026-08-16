#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"(.*)"/\1/')

if [[ -z "$file_path" ]]; then
  echo '{}'
  exit 0
fi

# Scope: only ~/Projects/** and ~/dotfiles/**
case "$file_path" in
  "$HOME"/Projects/*|"$HOME"/dotfiles/*) ;;
  *)
    echo '{}'
    exit 0
    ;;
esac

# Always-allowed: test files and dependency/doc metadata, regardless of tech
case "$file_path" in
  */tests/*|*.bats|*/test_*.py|*_test.py|*/conftest.py|*.md|*/pyproject.toml|*/uv.lock|*/package.json|*/package-lock.json|*/flake.lock|*/Makefile)
    echo '{}'
    exit 0
    ;;
esac

# Blocked: source/config that defines real behavior, across any tech
case "$file_path" in
  */src/*|*/modules/*.nix|*.nix|*/manifests/*|*/Dockerfile|*/hosts/*)
    ;;
  *)
    echo '{}'
    exit 0
    ;;
esac

reason="Direct edits to source/config in ~/Projects or ~/dotfiles are gated. Use the orchestrator agent's TDD pipeline (tester -> implementer -> verifier -> refactorer) instead, whatever the tech stack."
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}' "$reason"
