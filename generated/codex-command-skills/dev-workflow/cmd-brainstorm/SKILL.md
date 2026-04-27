---
name: "cmd-brainstorm"
description: "Generate and evaluate solution options"
---

# /brainstorm

Agent skill wrapper for the Claude command `/brainstorm`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions

Spawn 3 parallel agents to independently generate 5+ diverse approaches for: {{INPUT}}

For each approach:
- List pros/cons
- Assess feasibility and trade-offs

Synthesize results:
1. Identify consensus options (2+ agents recommend)
2. Select best solution based on constraint satisfaction
3. Justify with comparative analysis

Present as: Options table → Recommended solution → Rationale
