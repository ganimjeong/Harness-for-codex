# Workflow

## Starting Work

Run:

```sh
scripts/bootstrap
```

Then confirm the target deploy surface:

```sh
scripts/surface list
scripts/surface plan <id>
```

`plan` prints the three commands for that surface: verify, deploy, and the
`confirm` that proves the deploy landed.

Record the surface in the task brief before editing anything. When the
repository has no `surfaces.yml`, these commands are no-ops and the step is
skipped. See `docs/surfaces.md`.

Then inspect the repository and confirm the intended change.

For local hook installation, run:

```sh
scripts/hooks
```

## During Work

- Keep task notes in `tasks/` when context would otherwise be lost.
- Prefer small, reviewable commits.
- Update `docs/decisions.md` for decisions future agents should preserve.

## Finishing Work

Run:

```sh
scripts/eval
```

When the repository declares surfaces, verify containment too:

```sh
SURFACE=<id> scripts/check
```

Deploy through the surface, never by hand:

```sh
scripts/surface run <id>
```

It verifies, deploys, then confirms. Report a deploy as done only after the
confirm step passes; an exit code from the deploy command alone does not mean
anything shipped.

Use `scripts/check` for faster inner-loop verification and `scripts/eval` before
handoff. If either command cannot run, document why in the final handoff.

## Changing Agent Instructions

Editing `AGENTS.md` is editing behavior, so measure it:

```sh
AGENT_CMD='<your agent>' scripts/agent-eval
```

Add a case under `evals/cases/` for any rule meant to change what agents do,
and run the suite before and after. A rule that moves no check should not be
added. See [evals.md](evals.md).

## Changing Agent Instructions

Editing `AGENTS.md` is editing behavior, so measure it:

```sh
AGENT_CMD='<your agent>' scripts/agent-eval
```

Add a case under `evals/cases/` for any rule meant to change what agents do,
and run the suite before and after. A rule that moves no check should not be
added. See [evals.md](evals.md).

## Adding a New Stack

When adding a language or framework:

1. Add the dependency manifest normally.
2. Extend `scripts/bootstrap` for installation.
3. Extend `scripts/check` for lint, format, type, and test commands.
4. Extend `scripts/test` for the focused test command.
5. Update `harness.yml` if command names or expectations change.
   Add the new stack's paths to `surfaces.yml` when the repository declares
   deploy surfaces.
6. Add CI caching only when there is a concrete dependency manager and lockfile.
