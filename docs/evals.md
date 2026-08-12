# Agent Evals

## Two harnesses, two layers

This repository has always had two different things called a harness, and only
one of them was measured.

- The **agent harness** is what this repository ships: `AGENTS.md`, the standard
  scripts, the task template. It wraps the model.
- The **eval harness** is what measures the agent harness. It runs an agent
  over task cases and grades the result.

`scripts/eval` is named for the first meaning but does the second's job for the
*repository*: doctor, bootstrap, check. It answers "is this repo healthy?" It
has never been able to answer the question that matters for a harness:

> I changed `AGENTS.md`. Did agents get better or worse?

Without an answer, every instruction edit is a guess, and instructions
accumulate because nobody can prove which ones carry weight.

`scripts/agent-eval` answers it.

## Running it

```sh
AGENT_CMD='codex exec --full-auto "$(cat "$TASK_FILE")"' scripts/agent-eval
AGENT_CMD='claude -p "$(cat "$TASK_FILE")"' scripts/agent-eval
```

The agent command runs with a throwaway git workspace as its working
directory. The task brief is at `$TASK_FILE` and on stdin. `$EVAL_CASE` and
`$EVAL_ROOT` are exported. A command written relative to the repository root is
resolved for you.

To see the machinery work with no model and no network:

```sh
AGENT_CMD='evals/agents/scripted good'    scripts/agent-eval   # everything passes
AGENT_CMD='evals/agents/scripted sloppy'  scripts/agent-eval   # realistic failures
```

Options: `--case <id>`, `-k <n>` (trials per case, default 3), `--json`.
`EVAL_TIMEOUT` bounds each run, default 120s.

With no `AGENT_CMD`, the script explains itself and exits 0.

## Reading the output

```
scoped-change                2/3 trials  pass@3=1  pass^3=0
    bug-is-fixed                   3/3
    left-unrelated-files-alone     2/3
    ran-verification               3/3
```

**pass@k** asks *can it ever do this?* — it rises with `k`, and it is the right
metric for first-try problems where a retry is cheap.

**pass^k** asks *can it be relied on?* — every trial must pass, so it falls with
`k`. It is the right metric for anything where one bad run costs you.

The gap between them is flakiness. A case that is `pass@3=1, pass^3=0` is not
working; it is working sometimes, which for an instruction is the same as not
being followed.

The **harness backlog** at the end sorts failed checks by frequency. That list
is the point of the whole exercise: each line names an instruction that did not
survive contact with an agent, ordered by how often it failed.

## Writing a case

A case is a directory under `evals/cases/`:

```
evals/cases/<id>/
  task.md   the brief handed to the agent (required)
  setup     executable; seeds the workspace (optional)
  grade     executable; prints PASS/FAIL lines (required)
```

`grade` runs inside the finished workspace with `$TRANSCRIPT` (the agent's
output), `$BASE_COMMIT` (the pre-agent commit), and `$AGENT_STATUS`. It emits
one line per check:

```
PASS bug-is-fixed
FAIL ran-verification
```

A trial passes only when every check passes. A grader that emits nothing counts
as a failure, not a pass — an eval that cannot fail is not an eval.

### Binary, not scored

Every check is pass or fail. There is no 1-5 scale, because "3.7 on
helpfulness" is not actionable and two people will not agree on it. Where a
judgement feels like it needs a scale, it usually needs to be split into
several binary checks instead.

### Grade behaviour, not just output

The cases that earn their place test whether an *instruction* changed what the
agent did:

- `scoped-change` — fixes a bug, and leaves unrelated files alone.
- `verify-before-handoff` — the code is correct either way; the check is whether
  the agent actually ran verification or only said it did. The workspace's
  `check` script records its own invocation, so this is not gradeable by
  transcript alone.
- `ambiguous-target` — the task names a change but not which of two targets.
  The correct behaviour is to ask. Guessing fails, *including guessing
  correctly* — there is no right guess, and an agent that got it right has
  still learned to guess.
- `record-decision` — tests whether "document decisions in `docs/decisions.md`"
  is an instruction agents follow or a sentence nobody acts on.

## The scripted agent

`evals/agents/scripted` is a stand-in with two variants, `good` and `sloppy`.
It exists so the eval harness can be run and its graders proven with no model
and no network, and `scripts/selftest` asserts that the graders tell the two
apart.

That assertion matters more than it looks. The `sloppy` variant writes
*correct code* in three of four cases — it fixes the bug, adds the working
function, applies the change — and still fails, because it skipped verification,
touched files it was told to leave alone, guessed at an ambiguous target, and
never recorded its decision. Graders that only checked the output would pass it.

## Limits

- The results are only as good as the cases. Four cases is a starting set, not
  coverage; add cases for the instructions your project actually depends on.
- Deterministic graders cannot judge prose quality. Checks here are structural:
  files changed, commands run, text present. An LLM judge would cover more, at
  the cost of needing its own alignment work — build the deterministic checks
  first, since they never drift.
- Trials cost real agent runs. `-k 3` on four cases is twelve runs; budget
  accordingly and use `--case` while iterating.
- A passing eval suite does not mean the harness is good. It means the specific
  things you wrote down are holding.
