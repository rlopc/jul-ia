# Local shortcuts for the checks CI runs. Every target goes through `uv run`:
# a bare python/pytest may resolve a different interpreter than uv.lock pins.

.DEFAULT_GOAL := help
.PHONY: help install fix lint types test check clean

# The descriptions live next to the targets so they cannot drift apart: this
# reads them back out of the file itself.
help:
	@grep -E '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk -F':.*?## ' '{printf "%-9s %s\n", $$1, $$2}'

install: ## Sync the environment and install the git hooks
	uv sync
	uv run pre-commit install

# Everything that rewrites files, in the order the hooks apply it: the
# formatter first, then the lint fixes.
fix: ## Format and apply lint fixes in place
	uv run ruff format .
	uv run ruff check --fix .

lint: ## Lint without modifying anything
	uv run ruff check .

types: ## Type-check src and tests
	uv run mypy

test: ## Run the test suite
	uv run pytest

# The two CI steps, in the same order, preceded by the same --locked install:
# it fails when uv.lock no longer matches pyproject.toml, which a plain
# `uv sync` would resolve silently and only surface on the pull request. The
# hooks are the definition of lint, formatting and types, so this calls them
# instead of restating the tools.
check: ## What CI runs: every hook plus the tests
	uv sync --locked
	uv run pre-commit run --all-files
	uv run pytest

# Only caches and build output, never .venv: rebuilding the environment is a
# `uv sync`, but it is not what a stale cache calls for. __pycache__ is searched
# under the source trees alone so the walk never descends into .venv.
clean: ## Remove tool caches and build artifacts
	rm -rf .mypy_cache .pytest_cache .ruff_cache dist
	find src tests -type d -name __pycache__ -prune -exec rm -rf {} +
