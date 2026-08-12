# Codex Harness Instructions

This repository is a baseline workspace for Codex-driven implementation.

## Commands

Run these from the repository root:

```sh
scripts/bootstrap
scripts/check
scripts/test
scripts/eval
scripts/doctor
scripts/hooks
scripts/surface
scripts/agent-eval
```

- `scripts/bootstrap`: prepare dependencies when a known stack is present.
- `scripts/check`: run lint, type checks, formatting checks, and tests when available.
- `scripts/test`: run only the test suite when available.
- `scripts/eval`: run the complete handoff verification sequence.
- `scripts/doctor`: report repository, tool, and environment readiness.
- `scripts/hooks`: install local Git hooks through `pre-commit` when available.
- `scripts/surface`: resolve, enforce, and confirm the deploy target of a task.
- `scripts/agent-eval`: measure whether these instructions change agent behavior.

## Repository Layout

- `AGENTS.md`: Codex instructions for this repo.
- `CLAUDE.md`: Claude Code bridge that imports `AGENTS.md`.
- `README.md`: Human-facing overview and workflow.
- `harness.yml`: Machine-readable harness metadata and command registry.
- `.devcontainer/`: Optional reproducible development container.
- `.pre-commit-config.yaml`: Optional local hook definitions.
- `docs/`: Project notes and decisions.
- `scripts/`: Stable automation entrypoints.
- `tasks/`: Task briefs and working notes.
- `evals/`: Task cases and graders that measure these instructions.
- `surfaces.yml`: Optional deploy-surface declarations. See `docs/surfaces.md`.

## Operating Principles

- Read the repository before editing. Prefer existing conventions over new ones.
- Keep changes scoped to the requested task.
- Do not revert user changes unless explicitly asked.
- Use `rg` for searching when available.
- Use the standard scripts instead of one-off local commands when they cover the task.
- Add or update tests when behavior changes.
- Document decisions that affect future work in `docs/decisions.md`.
- Add nested `AGENTS.md` files in subdirectories only when that area needs different instructions.
- Keep root-level agent instructions short and durable. Move long procedures into docs or scripts.

## Task Loop

1. Target: resolve the deploy surface and record it in the task brief.
2. Inspect: read relevant files and recent decisions.
3. Plan: identify the narrow change and verification path.
4. Implement: make focused edits.
5. Verify: run `scripts/check` or `scripts/eval`, and `scripts/surface check`.
6. Handoff: summarize changed files, surface, verification, and residual risks.

## Surface Targeting

This applies when `surfaces.yml` exists. Skip it when it does not.

A repository can ship to several targets — an app store build, a website, an
admin console — through commands that look alike. The surface a task targets is
a fact about the task, so it belongs in a file, not in context that will be
compacted away.

- Resolve the surface before editing. Run `scripts/surface list` and state the
  chosen id in the task brief's `Surface` field.
- When the request does not identify a surface unambiguously, stop and ask.
  Do not infer one from the file you happened to open first.
- Run `scripts/surface check <id>` before handoff, or `SURFACE=<id>
  scripts/check`. If it fails, do not "fix" it by widening `surfaces.yml`:
  either the diff is wrong or the declared target is.
- Deploy with `scripts/surface run <id>`, which verifies, deploys, and then
  confirms. In a repository wired per `docs/enforcement.md`, deploys happen in
  CI and no other path holds credentials. Do not assemble the deploy command yourself, do not run another
  surface's deploy command, and do not substitute one that looks equivalent.
- A deploy command exiting 0 is not evidence that anything shipped. Never
  report a deploy as done on the strength of an exit code alone; report it as
  done only after `scripts/surface confirm <id>` passes. If a surface declares
  no `confirm`, say so explicitly in the handoff instead of implying success.
- State the surface, the deploy command, and the confirmation result in the
  handoff, so the next agent inherits the target instead of re-deriving it.

## Cross-Agent Compatibility

- Codex and Cursor can read `AGENTS.md`.
- Claude Code reads `CLAUDE.md`, which imports `AGENTS.md`.
- Keep shared instructions in `AGENTS.md` unless a tool-specific note is required.

## Adopting This Harness

After creating a repository from this template or fork:

1. Replace the `LICENSE` copyright line with the new project owner's name.
2. Rewrite `README.md` for the new project; the default README describes the harness itself.
3. Update repository metadata such as description, topics, and social preview.
4. Remove or adjust `.github/ISSUE_TEMPLATE` entries that do not fit the project.
5. Keep the standard scripts unless the new project has a better documented entrypoint.

## Changing These Instructions

`AGENTS.md` is the product of this repository, so editing it is editing
behavior, and behavior is measurable.

- Before adding a rule, check whether an existing one already covers it. Rules
  nobody enforces make the ones that matter harder to find.
- When you add a rule meant to change what agents do, add a case under
  `evals/cases/` that fails without it.
- Run `scripts/agent-eval` before and after. A rule that moves no check is
  either already followed or not followed at all; neither is worth adding text
  for.
- `scripts/eval` verifies this repository. `scripts/agent-eval` verifies these
  instructions. They are different layers — never report one as the other.

## Script Policy

These scripts are intentionally stack-aware and conservative. If a language stack
is added later, extend the scripts rather than bypassing them.

## Completion Criteria

Before finishing a task:

1. Confirm the requested change is implemented.
2. Run the narrowest useful verification command, usually `scripts/check`.
3. Report changed files and any verification that could not be run.
