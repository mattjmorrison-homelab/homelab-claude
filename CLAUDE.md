# Homelab

This is a NixOS homelab running k3s. Everything is managed as code — no manual kubectl commands, no one-off shell commands. If something needs to be run, it goes in a Makefile. If something needs to be deployed, it goes through ArgoCD.

## Repos

- `~/dotfiles` — main NixOS host configuration
- `~/Projects/homelab` — homelab-specific NixOS configuration
- `~/Projects/homelab-apps` — ArgoCD App of Apps; one Application manifest per service pointing at its repo
- `~/Projects/homelab-<service>` — one repo per deployed service; contains all Kubernetes manifests for that service

## Approach

- ArgoCD handles all deployments; nothing is applied manually to the cluster after bootstrap
- Each service lives in its own repo (`homelab-<service>`) with its own manifests
- To add a new service: create a `homelab-<service>` repo, then add an Application manifest in `homelab-apps` pointing at it
- All runnable operations go in a Makefile — never suggest one-off commands
- Everything is in source control
- All `homelab-*` repos are public on GitHub. Never put sensitive values — tokens, passwords, webhook URLs, API keys — in any manifest or ConfigMap committed to git. Sensitive values must come from Kubernetes Secrets created out-of-band (e.g. via a Makefile target), never stored in source control.
