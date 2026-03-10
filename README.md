# gsmlg-dev-code-agent

A Claude Code plugin marketplace containing development agents, workflow commands, CI/CD automation, and framework-specific tools.

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

## Version

0.2.0

## Author

Jonathan
