# Changelog

All notable changes to this project are recorded here.

## Unreleased

- Add `docs/enforcement.md` and `.github/workflows/deploy.yml.example`, which
  separate the enforced parts of the surface contract from the advisory ones
  and show the CI wiring that makes a wrong-place deploy impossible rather than
  discouraged.

- Add `scripts/agent-eval`, `evals/cases/`, and a scripted stand-in agent, so a
  change to `AGENTS.md` can be measured instead of guessed at. Reports pass@k,
  pass^k, and a backlog of failed checks by frequency.

- Add deploy-surface targeting: `surfaces.yml`, `scripts/surface`, an optional
  pre-commit containment guard, and a `Surface` field in the task template, so
  agents cannot silently change the wrong target.
- Add ship confirmation: each surface declares a `confirm` command, and
  `scripts/surface run` verifies, deploys, then confirms, so a deploy that
  exits 0 without shipping is caught instead of reported as success.
- Support surfaces that live in a subdirectory or a separate checkout through
  a `root` field.
- Add `scripts/selftest` and run it in CI.

- Clarify the README introduction, use cases, compatible agents, and provided automation entrypoints.
- Add contribution guidance for future harness changes.
- Add issue and pull request templates for public collaboration.

## 0.1.0

- Establish a language-agnostic Codex harness.
- Add `AGENTS.md`, `CLAUDE.md`, standard automation scripts, task template, workflow docs, and GitHub Actions verification.
