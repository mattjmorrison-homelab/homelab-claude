# Homelab

## HARD RULE: ASK FIRST, ALWAYS

Never do anything — any action that changes state on any system, local or remote — unless the user has explicitly asked for that specific thing, or has explicitly said yes after being asked. This is not case-by-case judgment; it applies even when the action seems small, safe, reversible, or obviously implied by the task. Diagnosis, reading, and investigation to answer a question are fine; anything that writes, edits, commits, pushes, patches, restarts, deletes, or otherwise changes something is not, until asked or approved. If a fix requires action, stop and say exactly what you'd do, then wait.

The two rules below are specific instances of this — kept here as worked examples, not as the only cases it covers.

## NEVER COMMIT OR PUSH

Never run `git commit` or `git push` in any homelab repo, for any reason, under any circumstances — not after finishing a task, not after a plan is approved, not because the user said "looks good" or "that's done" or similar. The user runs every commit and every push themselves, always, with no exceptions. If asked to do work, stop once the files are edited and report what's ready — do not commit it.

## NEVER MUTATE THE LIVE CLUSTER

Never run a `kubectl` command that changes cluster state — no `apply`, `restart`, `rollout restart`, `delete`, `scale`, `edit`, `patch`, etc. — even to fix something you just diagnosed, even if it seems like an obviously safe fix (e.g. restarting a stuck pod). Read-only `kubectl` (`get`, `describe`, `logs`) for diagnosis is fine. If a live-cluster change is needed, explain what you'd run and why, and let the user run it themselves or explicitly tell you the exact action to take.

This is a NixOS homelab running k3s. Everything is managed as code — no manual kubectl commands, no one-off shell commands. If something needs to be run, it goes in a Makefile. If something needs to be deployed, it goes through ArgoCD.

## Repos

- `~/dotfiles` — main NixOS host configuration
- `~/Projects/homelab` — homelab-specific NixOS configuration. Changes here (e.g. `modules/*.nix`) must go through the `orchestrator` agent's TDD pipeline (`tester` → `implementer` → `verifier` → `refactorer`), never a direct edit — this repo has that pipeline set up specifically for this.
- `~/Projects/homelab-apps` — ArgoCD App of Apps; one Application manifest per service pointing at its repo
- `~/Projects/homelab-<service>` — one repo per deployed service; contains all Kubernetes manifests for that service
- Any repo with its own test suite and coverage enforcement (e.g. `homelab-hdmi-switch`'s pytest setup) gets the same treatment as `~/Projects/homelab`: hand the whole task to the `orchestrator` agent and let it run tester → implementer → verifier → refactorer end to end. Never manually invoke `tester`/`implementer`/etc. one at a time, and never pause mid-pipeline to ask whether to proceed to the next stage — only surface a genuine blocker or the final result.

## Approach

- ArgoCD handles all deployments; nothing is applied manually to the cluster after bootstrap
- Each service lives in its own repo (`homelab-<service>`) with its own manifests
- To add a new service: create a `homelab-<service>` repo, then add an Application manifest in `homelab-apps` pointing at it
- All runnable operations go in a Makefile — never suggest one-off commands
- Everything is in source control
- All `homelab-*` repos are public on GitHub. Never put sensitive values — tokens, passwords, webhook URLs, API keys — in any manifest or ConfigMap committed to git. Sensitive values must come from Kubernetes Secrets created out-of-band (e.g. via a Makefile target), never stored in source control.
