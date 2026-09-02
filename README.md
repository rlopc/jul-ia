# jul-ia

[![CI](https://github.com/rlopc/jul-ia/actions/workflows/ci.yml/badge.svg)](https://github.com/rlopc/jul-ia/actions/workflows/ci.yml)

Agentic system that carries out user tasks across different domains.

> **Status:** early development. Project scaffolding, tooling and CI are in
> place; the agent itself is not implemented yet.

## Requirements

- [uv](https://docs.astral.sh/uv/) — installs Python 3.14 on its own
- `make` — only to run the targets below; each one is a couple of `uv run`
  commands you can also type yourself

## Getting started

```bash
make install   # sync the environment and install the git hooks
```

`.env.example` lists the variables the agent will need. No code reads them yet,
so there is nothing to copy until the agent lands.

## Development

```bash
make check     # every pre-commit hook plus the test suite
make help      # the remaining targets
```

Every target goes through `uv run`, so none of them can pick an interpreter
other than the one `uv.lock` pins. Reach for the tools directly when you need
something narrower than a target, such as a single test.

## Contributing

`main` is protected. Changes land through a pull request with a green CI run —
lint, formatting, type checks and tests all have to pass — and **commits have to
be signed**; the ruleset rejects unsigned ones. `make check` runs the same
checks CI does, so run it before pushing.

Interaction is currently limited to collaborators, so third parties cannot open
pull requests or comment. Security reports still get through: see
[SECURITY.md](SECURITY.md).

## License

Apache-2.0 — see [LICENSE](LICENSE).
