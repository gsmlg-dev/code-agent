# gsmlg-dev-code-agent

A Claude Code plugin marketplace containing development agents, skills, workflow commands, CI/CD automation, and framework-specific tools.

## Installation

### Add the marketplace

```
claude plugin marketplace add gsmlg-dev/code-agent
```

### Install plugins

```bash
claude plugin install dev-agents@gsmlg-dev-code-agent
claude plugin install git-workflow@gsmlg-dev-code-agent
claude plugin install ci-cd@gsmlg-dev-code-agent
claude plugin install phoenix-tools@gsmlg-dev-code-agent
claude plugin install chrome-devtools@gsmlg-dev-code-agent
claude plugin install elixir-dev@gsmlg-dev-code-agent
claude plugin install duskmoon-ui@gsmlg-dev-code-agent
```

## Available Plugins

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

### git-workflow

Git workflow commands (recommended with: dev-agents).

- `/brainstorm` - Generate and evaluate solution options
- `/git-commit` - Stage and commit with conventional messages
- `/review` - Code review using the reviewer agent
- `/suggest` - Analyze repository and suggest improvements
- `/worktree-merge` - Merge worktrees into current branch

### ci-cd

CI/CD automation commands (recommended with: dev-agents).

- `/fix-github-actions` - Fix failing GitHub Actions iteratively
- `/fix-pr-issues` - Fix PR issues with automated debugging

### phoenix-tools

Elixir/Phoenix framework tools.

- `/phoenix-convert-gettext` - Convert hardcoded text to gettext

### chrome-devtools

Browser automation, testing, and debugging skills.

- **chrome-devtools-mcp** - Browser automation with screenshots, console, network, and performance
- **a11y-debugging** - Accessibility auditing: semantic HTML, ARIA, focus, contrast
- **debug-optimize-lcp** - Largest Contentful Paint debugging and optimization
- **troubleshooting** - Chrome DevTools MCP connection diagnostics

### elixir-dev

Elixir/Phoenix development skills and thinking guides.

Skills:
- **elixir-architect** - OTP supervision trees, domain models, Ash Framework architecture
- **elixir-phoenix** - Phoenix project setup with Bun, Tailwind v4, devenv, PostgreSQL
- **ecto-release-migrations** - Release migrations without Mix for production deployment
- **elixir-thinking** - Core Elixir paradigms and patterns (from [claude-code-elixir](https://github.com/georgeguimaraes/claude-code-elixir))
- **phoenix-thinking** - Phoenix LiveView mental models and lifecycle
- **ecto-thinking** - Ecto data layer design patterns and bounded contexts
- **otp-thinking** - OTP concurrent systems design (GenServer, supervisors, Broadway)
- **oban-thinking** - Background job processing with Oban
- **using-elixir-skills** - Skill routing and invocation protocol

Commands:
- `/update-elixir-dev` - Sync thinking skills from upstream claude-code-elixir

### duskmoon-ui

Duskmoon design system skills.

- **duskmoon-dev-core** - CSS component library with Material Design 3 theming
- **duskmoon-dev-css-art** - Pure CSS decorative art components
- **duskmoon-elements** - Web Components custom element library (`<el-dm-*>`)
- **phoenix-duskmoon-ui** - Phoenix LiveView components (`dm_*` prefix)

## Version

0.3.0

## Author

Jonathan
