---
name: "cmd-check-phoenix-duskmoon-design"
description: "Run the /check-phoenix-duskmoon-design Claude command workflow in Codex."
---

# /check-phoenix-duskmoon-design

Agent skill wrapper for the Claude command `/check-phoenix-duskmoon-design`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions

Read `phoenix-duskmoon-design` skill first to understand all design rules, then audit this project for compliance. Report every violation with file path, line number, the offending code, and the correct fix.

## Checks

### 1. Hardcoded Colors (Critical)

Search `.ex`, `.exs`, `.heex`, `.css`, `.js` files for:
- Hex colors: `#[0-9a-fA-F]{3,8}`
- Color functions: `rgb(`, `rgba(`, `hsl(`, `hsla(` (skip if inside `var(--`)
- Named CSS colors in properties: `color: white`, `background: black`, etc.
- Tailwind palette classes: `bg-blue-500`, `text-red-600`, `border-gray-300`, etc.

Exclude: comments, test files, `.claude/` skill reference files, `mix.exs` version strings, SVG `fill`/`stroke` using `currentColor`.

### 2. Theme Setup

- CSS entry has `@plugin "@duskmoon-dev/core/plugin"` and `@import "phoenix_duskmoon/components"`
- Root layout has `data-theme=` on `<html>` element
- `<body>` has `bg-surface text-on-surface` or equivalent

### 3. Appbar Uses Primary

Find all `<.dm_appbar` and raw appbar HTML. Verify primary color convention:
- Phoenix component should render with `appbar-primary` class
- Raw HTML appbar should have `appbar appbar-primary appbar-sticky`

Flag if appbar uses default surface or any other color.

### 4. Sidebar & Drawer Use Secondary

Find all `<aside>`, `<.dm_left_menu>`, `<.dm_drawer>`, and sidebar containers. Verify they use secondary color:
- Should have `bg-secondary text-secondary-content`
- Flag if sidebar uses `bg-surface-container` or any surface token instead of secondary

### 5. Background-Text Pairing

Search for background color classes without their paired text color:
- `bg-primary` without `text-primary-content`
- `bg-secondary` without `text-secondary-content`
- `bg-tertiary` without `text-tertiary-content`
- `bg-error` without `text-error-content`
- `bg-inverse-surface` without `text-inverse-on-surface`
- `bg-primary-container` without `text-on-primary-container`

Flag as warnings (text may inherit from parent).

### 6. Surface Elevation Order

Check for nesting violations — higher-elevation surface containing lower:
- `surface-container-highest` wrapping `surface-container-low`
- `surface-container-high` wrapping plain `surface`

### 7. Semantic Color Misuse

Flag `variant="success"` or `variant="info"` on `dm_btn` — buttons use `primary`/`secondary`/`tertiary`/`error`/`ghost`/`outline`, not semantic state colors.

### 8. Multiple Primary Buttons Per View

In each `.heex` template, count `variant="primary"` on `dm_btn`. Flag if more than one appears outside conditional blocks.

### 9. Raw HTML Over Components

Flag `<button>`, `<input>`, `<select>`, `<table>` in `.heex` files where a `dm_*` equivalent exists. Exclude `lib/phoenix_duskmoon/` (component definitions) and `type="hidden"`.

### 10. Icon Color Override

Flag `dm_mdi` or `dm_bsi` with explicit `color=` set to anything other than `"currentcolor"`.

### 11. Tailwind Color Scale

Flag any Tailwind default color scale usage: `bg-blue-*`, `text-slate-*`, `border-zinc-*`, etc.

### 12. Typography

- Check if project defines custom font variables (`--font-display`, `--font-body`, `--font-mono`) in CSS
- Flag if `<body>` uses `font-family: system-ui` or `Inter` or `Roboto` without a project-specific override
- Check headings use a display font class or variable, not the same as body text

### 13. Layout Depth

- Check `<main>` or primary content area uses `bg-surface`
- Check sidebar/aside uses `bg-secondary text-secondary-content`
- Check drawer uses `bg-secondary text-secondary-content`
- Flag pages that are entirely flat (only one surface level used across the whole template)

### 14. Spacing Consistency

In each `.heex` template, check gap/padding classes. Flag if a single template mixes more than 2 gap scales (e.g., `gap-2`, `gap-4`, `gap-8` in the same view suggests inconsistency).

### 15. Reduced Motion

Check project CSS for `@media (prefers-reduced-motion: reduce)` rule. Flag as warning if absent and animations/transitions are used.

## Output

```
Phoenix DuskMoon Design Compliance
====================================
[✓|✗] Hardcoded colors:        N violations
[✓|✗] Theme setup:             OK | missing X
[✓|✗] Appbar color:            primary | wrong default
[✓|✗] Sidebar/drawer color:    secondary | wrong default
[✓|⚠] BG-text pairing:        N warnings
[✓|✗] Surface elevation:       OK | N violations
[✓|✗] Semantic color misuse:   N violations
[✓|⚠] Multiple primary btns:  N warnings
[✓|✗] Raw HTML over components: N instances
[✓|⚠] Icon color override:    N warnings
[✓|✗] Tailwind color scale:   N violations
[✓|⚠] Typography:             OK | N warnings
[✓|⚠] Layout depth:           OK | N warnings
[✓|⚠] Spacing consistency:    OK | N warnings
[✓|⚠] Reduced motion:         OK | missing

Total: N errors, N warnings
```

List each violation grouped by check with file:line, code snippet, and suggested fix.
