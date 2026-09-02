# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

**Language:** everything published in this repository is written in English —
code, comments, docstrings, documentation, commit messages, and pull request
titles and bodies. This file included.

## Commands

Everything goes through `uv run`. A bare `python`/`pytest` may pick a different
interpreter.

```bash
uv sync                        # install (uv installs Python 3.14)
uv run pytest                  # full suite
uv run ruff check .            # lint
uv run ruff format .           # format (CI uses --check)
uv run mypy                    # types; paths come from pyproject.toml
uv run pre-commit install      # git hooks, once per clone
uv run pre-commit run --all-files
```

CI runs `pre-commit run --all-files` rather than the individual tools, so the
hooks are the single definition of what lint, formatting and type checks have to
pass. Tests run as their own step: `uv run pytest`. Reproduce a CI failure with
whichever of the two matches the failing step.

The `Makefile` wraps those commands — `make install`, `make check`, `make help`
for the rest. They are shortcuts, not a second definition: anything narrower
than a whole target, such as one test or one path, goes through `uv run`
directly. `make check` differs from the CI step in one detail, `SKIP` (see the
gitleaks and `no-commit-to-branch` entries below); on a branch with a clean
index neither hook has anything to say, so the two agree in practice.

## Workflow

**`main` is protected by a ruleset: direct pushes are rejected.** Every change
goes through a branch and a pull request with CI green. There are no exceptions
and no bypass, not even for the owner.

```bash
git switch -c <prefix>/<description>
# ... changes ...
git add -A && git commit -m "<type>: message in the imperative"
git push -u origin <branch>
gh pr create            # without --fill, so the template in .github/ is used
gh pr checks <n> --watch && gh pr merge <n> --squash --delete-branch
```

Branch and commit prefixes in use: `feat/`, `fix/`, `chore/`, `ci/`, `docs/`.

Rules active on `main`: pull request required, the `check` job green, the branch
up to date before merging, **every review thread resolved**, **signed commits**,
**squash as the only merge method**, and no force-push or deletion. Approvals
are set to 0 because there is a single maintainer today; raise it to 1 as soon
as a second person joins. Thread resolution blocks a merge regardless of that
count, so an unresolved comment of your own is enough to hold a pull request.

Squash-only keeps history linear and one commit per pull request, which is what
makes the title conventions above meaningful: the pull request title *is* the
commit message. Merge commits and rebase merges are disabled at the repository
level too, so the buttons do not appear at all.

The ruleset is versioned in `.github/rulesets/main.json`, but GitHub **does not
read it from there**: it is auditable documentation. Editing it changes nothing
on its own — it has to be applied through the API, which needs admin permissions
on the repository. Editing the file without applying it leaves the repository
out of step with what it documents, which is worse than not having it.

## Known pitfalls

Things that cost time to rediscover:

- **`src/jul_ia/py.typed` is not optional.** Without that PEP 561 marker the
  package ships as untyped, and mypy ignores its annotations from any code that
  imports it, including the tests. It would report "Success" having checked
  nothing.
- **The mypy hook sets `pass_filenames: false` deliberately.** mypy needs the
  whole project to resolve imports; passing only the changed files produces both
  invented errors and missed ones. The paths come from `files` in
  `pyproject.toml`.
- **`astral-sh/setup-uv` publishes no moving major tags.** `@v10` returns 404, so
  an exact version is required. `actions/checkout` does publish them.
- **Actions are pinned by SHA** with the readable version in a trailing comment.
  Dependabot reads that comment to update them; do not remove it.
- **The gitleaks hook only sees the staged diff.** Its entry is
  `gitleaks git --pre-commit --staged`, so on a clean checkout it scans zero
  bytes and reports success. It is worthless outside an actual commit, which is
  why CI skips it instead of pretending to cover secrets there. `entry` cannot
  be overridden from `.pre-commit-config.yaml`, so the command itself is not
  adjustable.
- **`no-commit-to-branch` has to be skipped in CI as well.** `actions/checkout`
  leaves a detached HEAD on a pull request but creates the local branch on a
  push, so on `push: main` the hook finds itself on `main` and fails every merge
  run. Both skips travel together in `SKIP=gitleaks,no-commit-to-branch`; the
  hook guards the developer's commit, which is a local concern.
- **`pre-commit autoupdate` can propose downgrades.** `gitleaks v8.30.1` is
  tagged off the project's side branch, so autoupdate resolves `v8.30.0`, which
  is older. Check that every proposed revision is newer before merging.
- **Pull requests opened by the autoupdate workflow do not trigger CI**, because
  `GITHUB_TOKEN` opens them and GitHub prevents workflow loops that way. Close
  and reopen them to start the checks.
- **`.vscode/` is shared selectively.** The `.gitignore` versions only
  `settings.json` and `extensions.json`. If your global gitignore excludes
  `.vscode/` entirely, git cannot re-include them and you will need
  `git add -f`.

## Security

Three layers against credential leaks, in order: `.gitignore` keeps `.env` out of
the index, **gitleaks** stops the commit locally, and GitHub **push protection**
blocks at the server. All three were verified by making them fire, not just by
configuring them.

The middle layer is local only. CI cannot repeat it — see the gitleaks entry
under known pitfalls — so push protection is what covers a contributor who never
installed the hooks.

`secret_scanning_non_provider_patterns` and `secret_scanning_validity_checks`
**cannot be enabled**: they require a paid plan. The API answers 200 and ignores
them silently, so do not retry assuming it was a syntax error.

Vulnerability reports arrive through GitHub private reporting; issues are
disabled on purpose.

## Conventions

- Dependencies: minimum versions in `pyproject.toml`, exact versions in
  `uv.lock`, no upper bounds. The exception is `uv_build`, capped because uv's
  own documentation recommends it. CI installs with `uv sync --locked`.
- Comments explain *why* a decision was made, not what the line does.
- Never mention Claude, Claude Code or any other AI agent in commit messages,
  pull request descriptions or sign-offs.
