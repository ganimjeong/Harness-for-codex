# Enforcement

Declaring surfaces in `surfaces.yml` does not, by itself, make a wrong deploy
impossible. It is worth being precise about which parts are enforced and which
are asked for, because the difference decides how much the contract can be
trusted.

## What is enforced

A wrong action fails, loudly, without anyone having to remember anything.

| Rule | What stops the mistake |
| --- | --- |
| `paths` and `deny` | `scripts/surface check <id>` exits non-zero and names the offending files. Wired through `SURFACE=<id> scripts/check` or the `harness-surface` pre-commit hook, a wrong-surface diff cannot be committed. |
| `confirm` | `scripts/surface run <id>` fails when the deployed version does not match what was built. A manual publish step nobody clicked, an upload from the wrong directory, or a stale alias is caught here. |

## What is only instructed

Nothing physically blocks these. They are sentences in `AGENTS.md`, and
sentences are followed at a rate, not absolutely.

| Rule | The gap |
| --- | --- |
| "Deploy only through `scripts/surface run`" | An agent can still type the deploy CLI directly. `run` makes the correct path convenient; it does not make the incorrect one unavailable. |
| "Stop and ask when the target is ambiguous" | Also a sentence. The `ambiguous-target` eval case exists to measure whether it holds, and `pass^k` is the number to look at — an instruction followed most of the time is not a control. |

An instruction is a probability. A missing credential is a guarantee. Design
accordingly: use instructions to make the right thing easy, and use the
credential boundary to make the wrong thing impossible.

## Closing the gap

The wrong-command case cannot be fixed by writing a firmer instruction. It is
fixed by moving the credentials.

1. **Deploy only from CI.** No deploy tokens on a laptop, in a shell profile,
   or in an agent session. A local deploy should fail on authentication.
2. **One deploy invocation.** The workflow's only deploy step is
   `scripts/surface run <id>`, so the command that ships is the command
   `surfaces.yml` declares.
3. **Scope secrets per surface.** Put each surface's tokens in a GitHub
   Environment named after the surface and set `environment: <surface>` on the
   deploy job. The job dispatched for `web` cannot read `admin`'s secrets even
   if every other guard fails.
4. **Gate the deploy on containment.** A `guard` job runs
   `scripts/surface check <id> --base origin/main` before the deploy job is
   allowed to start, so a diff that escaped its surface never reaches a step
   that holds credentials.

`.github/workflows/deploy.yml.example` implements all four. Copy it to
`deploy.yml` and edit the surface list.

With that wiring, a wrong-place deploy stops being possible rather than
discouraged. Without it, `surfaces.yml` still lowers the failure rate and makes
failure visible — `confirm` catches a bad deploy after the fact — but the
prevention is advisory.

## Optional additions

- **Required checks.** Make the containment check a required status check on
  protected branches, so it cannot be skipped by merging.
- **Required reviewers.** GitHub Environments support them. A surface where a
  bad deploy is expensive can require a human to approve the job.
- **Deploy from a tag, not a branch.** Removes "which commit shipped?" from the
  set of questions `confirm` has to answer.

## What none of this covers

- A `confirm` command that cannot distinguish the new version from the old one.
  It will pass on a failed deploy, and the whole chain trusts it.
- Surfaces nobody declared. A new target that never made it into
  `surfaces.yml` is invisible to every check here.
- Anything deployed by a human clicking a dashboard button. Declare that as the
  surface's `deploy` command so it is at least visible, and let `confirm`
  decide whether it happened.
