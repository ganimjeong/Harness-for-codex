# Deploy Surfaces

A **surface** is one deployable target of a project: a mobile build, a
marketing website, an admin console, a docs site. Most projects have several,
and they are deployed by different commands that look alike.

The harness verifies that code is healthy. It did not verify two other things
that decide whether a task actually succeeded:

1. **Which target the change was for.** Nothing recorded it, so it lived only
   in the conversation and was the first thing lost to compaction.
2. **Whether the deploy actually shipped.** A deploy command exiting 0 means
   the command ran, not that the new version is live. A push to a host whose
   publish step is manual, a build uploaded from the wrong directory, a deploy
   to a stale project alias — all exit 0.

Together these produce the quietest possible failure: a plausible file is
edited, a command succeeds, the handoff says done, and nothing changed on the
target anyone cared about.

Surface targeting makes the target a fact in the repository and makes shipping
an assertion rather than an assumption.

## Enabling It

```sh
cp surfaces.example.yml surfaces.yml
```

Then edit it. Without `surfaces.yml`, every surface command is a documented
no-op and the rest of the harness behaves exactly as before.

## Configuration

```yaml
version: 1

shared:
  - "docs/"

surfaces:
  - id: web
    name: Marketing website
    root: sites/web
    paths:
      - "sites/web/"
    deny:
      - "sites/admin/"
    verify: "npm run build"
    deploy: "npm run deploy"
    confirm: 'test "$(curl -fsS https://example.com/build.txt)" = "$(git rev-parse --short HEAD)"'
```

- `root`: the directory whose changes belong to this surface. Defaults to the
  harness root. Point it at a subdirectory in a monorepo, or at a **sibling
  checkout** when each surface has its own repository — the containment check
  works across separate git trees, not just within one.
- `paths`: globs the surface owns, relative to the harness root. `**` matches
  across directories; a trailing `/` means everything beneath it.
- `deny`: paths this surface must never touch, even if a `paths` glob would
  allow them. Use it for the neighbours that are easy to confuse.
- `verify` / `deploy` / `confirm`: the commands for this surface, run from its
  `root`. `deploy` is the only deploy command allowed for a task on this
  surface. `confirm` must exit 0 only when the new version is actually live.
- Wrap a command in single quotes when it contains double quotes.

### Writing a good `confirm`

`confirm` is the part that earns its keep. It should read the deployed thing
from outside, not re-read local state:

```yaml
# compare a build id served by the deployment to the local commit
confirm: 'test "$(curl -fsS https://example.com/build.txt)" = "$(git rev-parse --short HEAD)"'

# assert the newest build finished
confirm: "eas build:list --limit 1 --json --non-interactive | grep -q FINISHED"
```

A `confirm` that always passes is worse than none, because it converts an open
question into a false answer.

Surfaces with a **manual publish step** belong here too. Declare the manual
step as the `deploy` command so the agent has to surface it rather than
assuming a push was enough, and let `confirm` decide whether it happened.

## Commands

```sh
scripts/surface list              # declared surfaces
scripts/surface show web          # one surface in detail
scripts/surface detect            # which surface owns each changed file
scripts/surface check web         # fail if changes escape the surface
scripts/surface plan web          # the three commands for this surface
scripts/surface confirm web       # is it actually live?
scripts/surface run web           # verify, deploy, confirm
```

`detect` and `check` read uncommitted changes by default, including untracked
files. Pass `--base <ref>` to inspect a branch or commit range instead:

```sh
scripts/surface check web --base origin/main
```

## Where It Runs

- `SURFACE=web scripts/check` runs the containment check as part of normal
  verification. Plain `scripts/check` is unchanged.
- The optional `harness-surface` pre-commit hook runs the same check before a
  commit, and skips itself when `SURFACE` is unset.
- `scripts/doctor` reports the declared surfaces and the current `SURFACE`.

## Failure Output

```
Surface check failed for 'web'.
  sites/admin/panel.tsx (denied by surface 'web')

These changes do not belong to the declared surface. Either correct the
target in the task brief or move the change to its own task.
Run 'scripts/surface detect' to see which surface owns each file.
```

The check names files, not intentions. If the diff is right and the declared
surface is wrong, fix the task brief; if the brief is right, the diff is the
bug. Do not resolve a failure by widening `paths`.

## Making It Enforcement Rather Than Advice

Containment and `confirm` are enforced: a wrong diff fails a check, and a
deploy that ships nothing fails `run`. "Deploy only through `scripts/surface
run`" is not enforced — it is a sentence in `AGENTS.md`, and nothing stops an
agent typing the deploy CLI directly.

That gap closes by moving credentials, not by writing a firmer instruction:
deploy only from CI, make `scripts/surface run <id>` the workflow's only deploy
step, and scope each surface's tokens to a GitHub Environment named after it.
A wrong command then fails on authentication rather than on discipline.

`.github/workflows/deploy.yml.example` is a working version of that wiring. See
[enforcement.md](enforcement.md).

## Limits

- Containment is path-based. Two surfaces that legitimately share a tree — an
  iOS and an Android build over the same app directory — cannot be separated by
  paths alone. Use `deny` for the directories they must never cross, and rely on
  distinct `deploy` and `confirm` commands to keep them apart.
- `confirm` is only as good as the signal it reads. If a deployment exposes no
  version marker, add one; a confirm that cannot distinguish old from new is
  not a confirm.
- Surfaces are declared, not discovered. A new target that nobody adds to
  `surfaces.yml` is invisible to every check here.
