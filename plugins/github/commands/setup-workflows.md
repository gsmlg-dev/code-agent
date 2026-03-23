---
description: Create or update GitHub Actions workflows (ci, test, release, e2e) based on project type detection
allowed-tools: Bash(git*), Bash(ls*), Bash(cat*), Bash(mkdir*), Bash(find*), Read, Write, Edit
argument-hint: "[e2e] — pass 'e2e' to include e2e.yml workflow"
---

## Task

Create or update GitHub Actions workflows in `.github/workflows/`.

## Detection Phase

First, detect the project ecosystem by inspecting the repo root:

1. **Language & package manager**: Check for `mix.exs`, `package.json`, `Cargo.toml`, `go.mod`, `pubspec.yaml`, `pyproject.toml`, `Makefile`, `flake.nix`, etc.
2. **Project type**: Determine if this is a **library/package** or an **application** — this affects whether `release.yml` publishes to a registry.
3. **Existing workflows**: Read any existing `.github/workflows/*.yml` to preserve custom jobs or secrets already configured.
4. **Test framework**: Detect test runner from config (ExUnit, Jest/Vitest, cargo test, go test, flutter_test, pytest, etc.)
5. **Build tool**: Detect build commands (mix compile, npm run build, cargo build, go build, flutter build, etc.)
6. **Linter/formatter**: Detect available checks (mix format --check-formatted, mix credo, eslint, clippy, go vet, dart analyze, ruff, etc.)

## Workflow Definitions

Generate **only** the workflows that apply. Use the detected ecosystem to fill in concrete commands — never use placeholder commands.

### 1. `ci.yml` — Static checks & build

- **Trigger**: `push` to any branch, `pull_request` to any branch
- **Jobs**: format check, lint, build (compile/typecheck) — can be parallel jobs or sequential steps, whichever fits the ecosystem
- **No tests** in this workflow
- **Cache**: dependencies (hex/deps, node_modules, target/, pkg cache, pub cache, etc.)

### 2. `test.yml` — Unit tests

- **Trigger**: `push` to `main` only, `pull_request` targeting `main`
- **Jobs**: run unit test suite
- **Services**: if tests need a database (Postgres, Redis, etc.), add service containers detected from config (e.g. `config/test.exs`, `docker-compose.yml`, `.env.test`)
- **Cache**: dependencies

### 3. `release.yml` — Manual release

- **Trigger**: `workflow_dispatch` with inputs:
  - `version` (string, required, description: "Release version (e.g. 1.2.3)")
  - `git_ref` (string, required, default: "main", description: "Git ref to release from")
- **Steps in order**:
  1. Checkout at `git_ref`
  2. Setup language toolchain
  3. Update version in the canonical version file (`mix.exs`, `package.json`, `Cargo.toml`, `pubspec.yaml`, `pyproject.toml`, etc.) to the input `version`
  4. Build the package/artifact
  5. **If library/package**: publish to registry (hex.pm, npm, crates.io, pub.dev, pypi, etc.) — use appropriate secrets (`HEX_API_KEY`, `NPM_TOKEN`, `CARGO_REGISTRY_TOKEN`, `PUB_CREDENTIALS`, `PYPI_TOKEN`, etc.)
  6. **If application**: skip publish, but upload build artifacts
  7. Commit the version bump: `git commit -am "chore(release): v${version}"`
  8. Create git tag: `v${version}`
  9. Push commit and tag
  10. Create GitHub Release via `gh release create` or `softprops/action-gh-release` — include release notes (auto-generate from commits since last tag), upload build artifacts
- **Permissions**: `contents: write`

### 4. `e2e.yml` — End-to-end tests (only if `$ARGUMENTS` contains "e2e")

- **Trigger**: `workflow_dispatch` with input:
  - `version` (string, required, description: "Release version to test")
- **Steps**:
  1. Fetch the release artifacts from GitHub Releases for the given version
  2. Setup test environment (install deps, start services)
  3. Run e2e test suite
- **Only generate this file when the user explicitly passes "e2e" as argument**

## Output Rules

- Use the latest stable action versions (e.g. `actions/checkout@v4`, `actions/setup-node@v4`, `erlef/setup-beam@v1`)
- Set `permissions` explicitly on each workflow — principle of least privilege
- Every workflow must set `concurrency` to cancel redundant runs:
  ```yaml
  concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true
  ```
- Use `fail-fast: false` in matrix strategies if applicable
- Prefer pinned action versions over `@latest`
- Name each workflow clearly with a `name:` field
- If existing workflow files are found, **update them in place** preserving any custom secrets, env vars, or extra jobs the user added — do not blindly overwrite

## Commit

After writing all workflow files, create a single commit:

```
ci(github): update github actions workflows
```

Do NOT push. Report what was created/updated.