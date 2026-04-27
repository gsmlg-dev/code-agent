# code-agent

A Claude Code plugin marketplace containing development agents, skills, workflow commands, GitHub automation, and framework-specific tools.

## Installation

### Install skills with `npx skills add`

```bash
# list available skills
npx -y skills add gsmlg-dev/code-agent --list

# install one skill globally for Codex
npx -y skills add gsmlg-dev/code-agent -a codex -g --skill elixir-thinking

# install all skills globally for Codex
npx -y skills add gsmlg-dev/code-agent -a codex -g --skill '*'
```

This installs the repository's Agent Skills. Claude plugin commands and agents are still installed through Claude Code's plugin marketplace commands below.

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

Sync: `/update-chrome-devtools-plugin` from [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp)

### elixir-dev

Elixir/Phoenix development skills, hooks (auto-format, compile, credo), and LSP integration.

| Skill | Description |
|-------|-------------|
| elixir-architect | OTP supervision trees, domain models, Ash Framework architecture |
| elixir-phoenix | Phoenix project setup with Bun, Tailwind v4, devenv, PostgreSQL |
| ecto-release-migrations | Release migrations without Mix for production deployment |
| elixir-thinking | Core Elixir paradigms and patterns |
| phoenix-thinking | Phoenix LiveView mental models and lifecycle |
| ecto-thinking | Ecto data layer design patterns and bounded contexts |
| otp-thinking | OTP concurrent systems design (GenServer, supervisors, Broadway) |
| oban-thinking | Background job processing with Oban |
| using-elixir-skills | Skill routing and invocation protocol |

Sync: `/update-elixir-dev-plugin` from [georgeguimaraes/claude-code-elixir](https://github.com/georgeguimaraes/claude-code-elixir)

### duskmoon-ui

Duskmoon design system skills.

| Skill | Description |
|-------|-------------|
| duskmoon-dev-core | CSS component library with Material Design 3 theming |
| duskmoon-dev-css-art | Pure CSS decorative art components |
| duskmoon-elements | Web Components custom element library (`<el-dm-*>`) |
| phoenix-duskmoon-ui | Phoenix LiveView components (`dm_*` prefix) |
| phoenix-duskmoon-design | Phoenix DuskMoon UI design system rules, theming, and adaptive patterns |

Sync: `/update-duskmoon-plugin` from upstream [duskmoon-dev](https://github.com/duskmoon-dev) repos

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

Sync: `/update-speckit-plugin` from [github/spec-kit](https://github.com/github/spec-kit)

### flutter-skills

Flutter development skills covering animations, architecture, state management, navigation, testing, and more.

| Skill | Description |
|-------|-------------|
| flutter-adding-home-screen-widgets | Add home screen widgets on iOS and Android |
| flutter-animating-apps | Animations: implicit, explicit, transitions |
| flutter-architecting-apps | App architecture patterns and best practices |
| flutter-building-forms | Form widgets, validation, and user input |
| flutter-building-layouts | Layout widgets: Row, Column, Stack, Flex |
| flutter-building-plugins | Create platform plugins and federated plugins |
| flutter-caching-data | Data caching strategies and implementation |
| flutter-embedding-native-views | Embed native Android/iOS views with PlatformView |
| flutter-handling-concurrency | Isolates, async/await, and concurrent patterns |
| flutter-handling-http-and-json | HTTP requests, REST APIs, JSON serialization |
| flutter-implementing-navigation-and-routing | Navigator 2.0, go_router, deep linking |
| flutter-improving-accessibility | Semantics, screen readers, a11y best practices |
| flutter-interoperating-with-native-apis | Platform channels and FFI for native API access |
| flutter-localizing-apps | l10n, ARB files, multi-language support |
| flutter-managing-state | State management: Provider, Riverpod, Bloc, etc. |
| flutter-reducing-app-size | Tree-shaking, deferred loading, asset optimization |
| flutter-setting-up-on-linux | Flutter SDK installation and setup on Linux |
| flutter-setting-up-on-macos | Flutter SDK installation and setup on macOS |
| flutter-setting-up-on-windows | Flutter SDK installation and setup on Windows |
| flutter-testing-apps | Unit, widget, and integration testing |
| flutter-theming-apps | Material 3 theming, dark mode, custom themes |
| flutter-working-with-databases | SQLite, Drift, Isar, and other local databases |

Sync: `/update-flutter-skills-plugin` from [flutter/skills](https://github.com/flutter/skills)

### gsmlg-app

GSMLG app development skills.

| Skill | Description |
|-------|-------------|
| flutter-duskmoon | Flutter DuskMoon UI design system — theme, adaptive widgets, settings, feedback, and BLoC theme persistence |
| flutter-duskmoon-design | Flutter DuskMoon UI design system rules, theming, and adaptive patterns |

Sync: `/update-gsmlg-app-plugin` from [duskmoon-dev/flutter-duskmoon-ui](https://github.com/duskmoon-dev/flutter-duskmoon-ui)

## Version

0.5.8

## Author

Jonathan
