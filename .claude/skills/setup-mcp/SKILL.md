---
name: setup-mcp
description: Use when adding or configuring an MCP (Model Context Protocol) server in a Claude Code plugin. Triggers on "add mcp", "setup mcp", "configure mcp server", "add mcp.json to plugin", or any request to wire up an external MCP tool server to a plugin in this repository.
metadata:
  internal: true
---

# Setting up MCP in a Plugin

MCP servers are configured via a `.mcp.json` file (dotfile) at the plugin root — **not** inside `.claude-plugin/`, and **not** `mcp.json` without the dot.

## File location

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json        ← here
├── commands/
└── ...
```

## Schema

```json
{
  "<server-name>": {
    "type": "http",
    "url": "https://<endpoint>/mcp/",
    "headers": {
      "Authorization": "Bearer ${ENV_VAR}"
    }
  }
}
```

- Top-level keys are the server names (used as identifiers in Claude Code)
- `type`: transport type — use `"http"` for HTTP/SSE endpoints
- `url`: the MCP server endpoint URL
- `headers`: optional; use `${VAR}` syntax for environment variable interpolation (e.g., `${GITHUB_TOKEN}`)

## Example (github plugin)

```json
{
  "github": {
    "type": "http",
    "url": "https://githubcopilot-api.gsmlg.dev/mcp/",
    "headers": {
      "Authorization": "Bearer ${GITHUB_TOKEN}"
    }
  }
}
```

## Notes

- Multiple servers can be registered in the same `.mcp.json` by adding more top-level keys
- `headers` is only needed for authenticated endpoints
- `plugin.json` does **not** carry MCP config — keep them separate
- `lspServers` in `plugin.json` is for LSP (code intelligence), not MCP
