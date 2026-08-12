# Task: <title>

## Target

- Surface: `<id from scripts/surface list, or "none" when the repository declares no surfaces>`
- Deploy command: `<the deploy line printed by scripts/surface plan <id>>`
- Confirmation: `<the confirm line, and how it proved the change is live>`

State the surface before doing any work. If the request does not identify one
unambiguously, stop and ask rather than inferring it.

## Goal

Describe the requested outcome.

## Context

Add links, constraints, prior decisions, or relevant files.

## Plan

- [ ] Confirm the target surface
- [ ] Inspect current behavior
- [ ] Implement change
- [ ] Verify
- [ ] Confirm surface containment
- [ ] Document handoff

## Verification

Record commands and results, including `scripts/surface check <id>`.

## Handoff

- Surface: `<id>`
- Changed files:
- Verification run:
- Deployed: `<yes/no>` — confirmed by: `<confirm command and its result>`
- Residual risks:
