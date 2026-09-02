# jul-ia

[![CI](https://github.com/rlopc/jul-ia/actions/workflows/ci.yml/badge.svg)](https://github.com/rlopc/jul-ia/actions/workflows/ci.yml)

Agentic system that carries out user tasks across different domains.

> **Status:** early development. Project scaffolding, tooling and CI are in
> place; the agent itself is not implemented yet.

## Requirements

- [uv](https://docs.astral.sh/uv/) — installs Python 3.14 on its own

## Getting started

```bash
uv sync
cp .env.example .env  # then add your ANTHROPIC_API_KEY
```

## Development

```bash
uv run pytest              # test suite
uv run ruff check .        # lint
uv run ruff format .       # format
uv run mypy                # type check
uv run pre-commit install  # enable git hooks (once per clone)
```

## Contributing

`main` is protected. Changes land through a pull request with a green CI run:
lint, formatting, type checks and tests all have to pass before merging.

## License

Apache-2.0 — see [LICENSE](LICENSE).
