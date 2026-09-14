# code-agent

A multi-platform plugin marketplace containing development agents, skills, workflow commands, GitHub automation, and framework-specific tools for Claude Code, Codex, and Cursor.

## Installation

### Install skills with `npx skills add` (Codex)

```bash
# list available skills
npx -y skills add gsmlg-dev/code-agent --list

# install one skill globally for Codex
npx -y skills add gsmlg-dev/code-agent -a codex -g --skill elixir

# install one command wrapper globally for Codex
npx -y skills add gsmlg-dev/code-agent -a codex -g --skill cmd-git-commit

# install all skills globally for Codex
npx -y skills add gsmlg-dev/code-agent -a codex -g --skill '*'
```

Claude source skills are exposed to Codex as `cmd-*` skills, for example `/git-commit` is available as `cmd-git-commit` and `/speckit.plan` as `cmd-speckit-plan`.

### Install native Codex plugins

Native Codex plugin bundles are generated into `.codex-plugin/plugins/` from
the Claude plugin sources:

```bash
node scripts/generate-codex-plugins
codex plugin marketplace add gsmlg-dev/code-agent
codex plugin add dev-workflow@gsmlg-dev-code-agent
```

### Cursor adapter

Cursor bundles are generated into `.cursor-plugin/plugins/` and registered
by `.cursor-plugin/marketplace.json`. This repository currently provides a
local adapter format (`officialCompatibility: false`), not an official Cursor
plugin manifest. Generate and validate it with:

```bash
node scripts/generate-cursor-plugins
node scripts/validate-cursor
```

Unsupported capabilities are retained under each bundle's `unsupported/`
directory with an explicit reason.

Existing Claude skills (including `cmd-*` workflow skills) are copied into
each Codex bundle, and Claude agents are wrapped as Codex skills.

### Add / Update the marketplace

```bash
claude plugin marketplace add gsmlg-dev/code-agent
# or update
claude plugin marketplace update gsmlg-dev-code-agent
```

### Install individual plugins

```bash
claude plugin install dev-agents@gsmlg-dev-code-agent
claude plugin install dev-workflow@gsmlg-dev-code-agent
claude plugin install github@gsmlg-dev-code-agent
claude plugin install phoenix-tools@gsmlg-dev-code-agent
claude plugin install chrome-devtools@gsmlg-dev-code-agent
claude plugin install elixir-dev@gsmlg-dev-code-agent
claude plugin install duskmoon-ui@gsmlg-dev-code-agent
claude plugin install speckit@gsmlg-dev-code-agent
claude plugin install flutter-skills@gsmlg-dev-code-agent
claude plugin install gsmlg-app@gsmlg-dev-code-agent
```

## Plugins

### dev-agents

8 specialized development agents for software engineering tasks.

| Agent | Purpose |
|-------|---------|
| architect | System design and architectural planning |
| debugger | Bug analysis and root cause identification |
| documenter | Documentation generation |
| implementer | Production code implementation |
| refactorer | Code quality improvement |
| researcher | Technology evaluation and recommendations |
| reviewer | Code review and quality assessment |
| tester | Test suite creation |

### dev-workflow

Git workflow commands (recommended with: dev-agents).

| Command | Description |
|---------|-------------|
| `/brainstorm` | Generate and evaluate solution options |
| `/git-commit` | Stage and commit with conventional messages |
| `/review` | Code review using the reviewer agent |
| `/suggest` | Analyze repository and suggest improvements |
| `/worktree-merge` | Merge worktrees into current branch |

### github

GitHub automation commands (recommended with: dev-agents).

| Command | Description |
|---------|-------------|
| `/fix-github-actions` | Fix GitHub Actions failures by analyzing recent workflow runs in a worktree |
| `/fix-pr-chechers` | Fix failing GitHub Actions in current PR |
| `/fix-pr-review` | Fix review comments on current PR |
| `/fix-internal-requests` | Fix all open GitHub issues labeled `internal request` in isolated worktrees, then open PRs |
| `/setup-workflows` | Create or update GitHub Actions workflows (ci, test, release, e2e) based on project type detection |

### phoenix-tools

Elixir/Phoenix framework tools.

| Command | Description |
|---------|-------------|
| `/phoenix-convert-gettext` | Convert hardcoded text to gettext |

### chrome-devtools

Browser automation, testing, and debugging skills.

| Skill | Description |
|-------|-------------|
| chrome-devtools-mcp | Browser automation with screenshots, console, network, and performance |
| chrome-devtools-cli | Chrome DevTools CLI usage and scripting |
| a11y-debugging | Accessibility auditing: semantic HTML, ARIA, focus, contrast |
| debug-optimize-lcp | Largest Contentful Paint debugging and optimization |
| troubleshooting | Chrome DevTools MCP connection diagnostics |

Sync: `cmd-update-chrome-devtools-plugin` from [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp)

### elixir-dev

Elixir/Phoenix development skills, hooks (auto-format, compile, credo), and LSP integration.

| Skill | Description |
|-------|-------------|
| denox | Deno + Elixir integration patterns |
| ecto | Ecto data layer design patterns and bounded contexts |
| elixir | Core Elixir paradigms and patterns |
| oban | Background job processing with Oban |
| otp | OTP concurrent systems design (GenServer, supervisors, Broadway) |
| phoenix | Phoenix LiveView mental models and lifecycle |
| phoenix-app-clip | Embed React app clips inside Phoenix LiveView |

Sync: `cmd-update-elixir-dev-plugin` from [georgeguimaraes/claude-code-elixir](https://github.com/georgeguimaraes/claude-code-elixir)

### duskmoon-ui

Duskmoon design system skills.

| Skill | Description |
|-------|-------------|
| duskmoon-dev-core | CSS component library with Material Design 3 theming |
| duskmoon-dev-css-art | Pure CSS decorative art components |
| duskmoon-elements | Web Components custom element library (`<el-dm-*>`) |
| phoenix-duskmoon-ui | Phoenix LiveView components (`dm_*` prefix) |
| phoenix-duskmoon-design | Phoenix DuskMoon UI design system rules, theming, and adaptive patterns |

Sync: `cmd-update-duskmoon-plugin` from upstream [duskmoon-dev](https://github.com/duskmoon-dev) repos

### speckit

Specification-Driven Development toolkit.

| Command | Description |
|---------|-------------|
| `/speckit.init` | Initialize `.specify/` directory structure |
| `/speckit.init.update` | Update `.specify/` scripts and templates from upstream |
| `/speckit.specify` | Transform a feature description into a structured spec.md |
| `/speckit.clarify` | Resolve ambiguities in spec.md through targeted Q&A |
| `/speckit.plan` | Generate technical plan, data model, and interface contracts from spec.md |
| `/speckit.tasks` | Generate a phase-based task breakdown in tasks.md |
| `/speckit.implement` | Execute implementation phase-by-phase following tasks.md |
| `/speckit.analyze` | Validate cross-artifact consistency across spec.md, plan.md, and tasks.md |
| `/speckit.checklist` | Create domain-specific quality checklists |
| `/speckit.constitution` | Define or update project governing principles |
| `/speckit.taskstoissues` | Convert tasks.md into GitHub issues |

Sync: `cmd-update-speckit-plugin` from [github/spec-kit](https://github.com/github/spec-kit)

### flutter-skills

Flutter development skills covering animations, architecture, state management, navigation, testing, and more.

| Skill | Description |
|-------|-------------|
| dart-add-unit-test | Add Dart unit tests |
| dart-build-cli-app | Build Dart CLI applications |
| dart-collect-coverage | Collect Dart test coverage |
| dart-fix-runtime-errors | Diagnose Dart runtime errors |
| dart-generate-test-mocks | Generate Dart test mocks |
| dart-migrate-to-checks-package | Migrate to the Dart checks package |
| dart-resolve-package-conflicts | Resolve Dart package conflicts |
| dart-run-static-analysis | Run Dart static analysis |
| dart-setup-ffi-assets | Configure Dart FFI assets |
| dart-use-doc-examples | Use Dart documentation examples |
| dart-use-ffigen | Generate bindings with ffigen |
| dart-use-pattern-matching | Use Dart pattern matching |
| dart-use-primary-constructors | Use Dart primary constructors |
| dart-write-documentation | Write Dart documentation |
| flutter-add-integration-test | Add Flutter integration tests |
| flutter-add-widget-preview | Add Flutter widget previews |
| flutter-add-widget-test | Add Flutter widget tests |
| flutter-apply-architecture-best-practices | Apply Flutter architecture best practices |
| flutter-build-responsive-layout | Build responsive Flutter layouts |
| flutter-fix-layout-issues | Fix Flutter layout issues |
| flutter-implement-json-serialization | Implement JSON serialization |
| flutter-setup-declarative-routing | Set up declarative routing |
| flutter-setup-localization | Set up Flutter localization |
| flutter-use-http-package | Use the Flutter HTTP package |

Sync: `cmd-update-flutter-skills-plugin` from [flutter/skills](https://github.com/flutter/skills)

### gsmlg-app

GSMLG app development skills.

| Skill | Description |
|-------|-------------|
| flutter-duskmoon | Flutter DuskMoon UI design system — theme, adaptive widgets, settings, feedback, and BLoC theme persistence |
| flutter-duskmoon-design | Flutter DuskMoon UI design system rules, theming, and adaptive patterns |

Sync: `cmd-update-gsmlg-app-plugin` from [duskmoon-dev/flutter-duskmoon-ui](https://github.com/duskmoon-dev/flutter-duskmoon-ui)

## Maintenance

Regenerate platform bundles after adding or changing files under `plugins/*/{agents,skills}/`:

```bash
node scripts/generate-codex-plugins
node scripts/generate-cursor-plugins
node scripts/validate
node scripts/validate-cursor
```

## Version

0.6.2

## Author

Jonathan
