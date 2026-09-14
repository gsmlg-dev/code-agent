---
name: phoenix-duskmoon-design
description: Design conventions and visual quality guide for Phoenix projects using DuskMoon UI. Defines component color defaults, theme setup, surface elevation, color pairing rules, typography, layout composition, and motion patterns. Read this before writing any HEEX template, CSS, layout code, or creating new pages/views.
---

# Phoenix DuskMoon Design Conventions

## Design Thinking

Before building any page or view, commit to an intentional aesthetic direction within the DuskMoon design system:

- **Purpose**: What does this page do? Dashboard, form, marketing, admin, content?
- **Density**: Dense data UI vs generous editorial spacing — pick one per view
- **Emphasis**: Identify the single most important action or content block — that gets primary color; everything else recedes
- **Depth**: How many surface layers does this view need? Flat (1-2 levels) vs layered (3-4 levels)

DuskMoon provides the tokens — your job is to use them with intention, not uniformly.

---

## Theme Setup

### CSS Entry (Required)

```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
@import "phoenix_duskmoon/components";
```

### HTML Root (Required)

```heex
<html lang="en" data-theme="sunshine">
```

Themes: `sunshine` (light), `moonlight` (dark).

### Body Base

```heex
<body class="bg-surface text-on-surface">
```

Every page starts on `surface` with `on-surface` text. No exceptions.

### Theme Switcher

Always include `<.dm_theme_switcher />` in the appbar. Requires `ThemeSwitcher` hook.

---

## Component Default Colors

### Page Shell

| Component | Color | Class / Pattern |
|-----------|-------|-----------------|
| **Appbar** | **primary** | `appbar appbar-primary appbar-sticky` |
| Page background | surface | `bg-surface` on `<body>` |
| Sidebar | **secondary** | `bg-secondary text-secondary-content` |
| Footer | surface-container-high | `bg-surface-container-high` |
| Bottom nav | primary | `color="primary"` |
| Drawer | **secondary** | `bg-secondary text-secondary-content` |

The appbar is the brand anchor — always primary. The sidebar and drawer use secondary to create a strong navigation identity distinct from the content area. The page body is always surface. Footer uses higher surface elevation for subtle separation.

```heex
<.dm_appbar title={@page_title} sticky>
  <:logo>...</:logo>
  <:menu to={~p"/dashboard"} active={@active == :dashboard}>Dashboard</:menu>
  <:user_profile><.dm_theme_switcher /></:user_profile>
</.dm_appbar>

<div class="flex">
  <aside class="bg-secondary text-secondary-content w-64 min-h-screen p-4">
    <.dm_left_menu active={@current_path}>
      <:menu>...</:menu>
    </.dm_left_menu>
  </aside>
  <main class="flex-1 p-6">
    <%= @inner_content %>
  </main>
</div>

<.dm_page_footer label="© 2026 MyApp" />
```

### Actions

| Component | Default | When to Change |
|-----------|---------|----------------|
| Primary button | `variant="primary"` | Main page action — **one per view** |
| Secondary button | `variant="secondary"` | Alternative actions |
| Tertiary button | `variant="tertiary"` | Accent features, special highlights |
| Destructive button | `variant="error"` | Delete, remove, irreversible |
| Ghost button | `variant="ghost"` | Toolbar, low-emphasis, cancel |
| Link button | `variant="link"` | Inline text actions |
| Outline button | `variant="outline"` | Medium emphasis, toggleable |

```heex
<div class="flex gap-2">
  <.dm_btn variant="ghost">Cancel</.dm_btn>
  <.dm_btn variant="primary">Save Changes</.dm_btn>
</div>
```

### Content

| Component | Color | Notes |
|-----------|-------|-------|
| Card | surface-container | Default CSS — no class needed |
| Card (elevated) | surface-container-high | Add `shadow="md"` |
| Modal / Dialog | surface-container-highest | Highest elevation |
| Tooltip | primary | `color="primary"` default |
| Popover | surface-container-high | |
| Accordion | surface-container | |
| Bottom sheet | surface-container-high | |
| Snackbar | inverse-surface or type-based | Use `type` for semantic |

### Data Display

| Component | Color | Notes |
|-----------|-------|-------|
| Badge | `variant="primary"` | Use `secondary`/`tertiary` for category differentiation |
| Chip | `color="primary"` | Semantic colors for status: `success`, `error` |
| Progress | `color="primary"` | `success` for completion, `error` for limits |
| Avatar | `color="primary"` | Initials placeholder color |
| Stat | no color | `color="primary"` for key metrics only |
| Timeline | semantic per item | `completed` = green, `active` = primary |
| Table | no color | `zebra` + `hover` for readability |

### Forms

| Component | Color | Notes |
|-----------|-------|-------|
| Input | no color | Uses outline border. Set `color` only for emphasis |
| Checkbox | `color="primary"` | |
| Radio | `color="primary"` | |
| Switch | `color="primary"` | |
| Select | no color | |
| Slider | `color="primary"` | |
| Rating | `color="primary"` | `warning` for star ratings |

### Feedback

| Component | Color | Notes |
|-----------|-------|-------|
| Alert | type-based | `variant="info"`, `"success"`, `"warning"`, `"error"` |
| Flash | kind-based | `:info`, `:error` |
| Toast | type-based | Always set `type` |
| Loading spinner | `variant="primary"` | |

### Navigation

| Component | Color | Notes |
|-----------|-------|-------|
| Appbar | **primary** | Always |
| Navbar | surface-container-high | `navbar-surface-container-high` |
| Tabs | no color | Active = primary underline |
| Breadcrumb | on-surface-variant | Muted text |
| Steps | `color="primary"` | Completed = filled, upcoming = outline |
| Left menu | **secondary** | Active item = primary-content highlight |

---

## Color Rules

### Rule 1: No Hardcoded Colors

Never use hex, rgb, hsl, named colors, or Tailwind palette classes (`bg-blue-500`, `text-slate-600`). All colors from design tokens only.

```heex
<%# FORBIDDEN %>
<div style="background: #3b82f6;">
<div class="bg-blue-500 text-white">

<%# CORRECT %>
<div class="bg-primary text-primary-content">
```

### Rule 2: Pair Background + Text

Every background token has a text counterpart. Always use them together.

| Background | Text |
|------------|------|
| `bg-primary` | `text-primary-content` |
| `bg-secondary` | `text-secondary-content` |
| `bg-tertiary` | `text-tertiary-content` |
| `bg-surface` | `text-on-surface` |
| `bg-surface-container-*` | `text-on-surface` |
| `bg-primary-container` | `text-on-primary-container` |
| `bg-error` | `text-error-content` |
| `bg-error-container` | `text-on-error-container` |
| `bg-inverse-surface` | `text-inverse-on-surface` |

### Rule 3: Surface Elevation — Low to High

Nest surfaces from low to high. Never place lower elevation inside higher.

```
surface (page)
  ├─ secondary (sidebar, drawer)
  └─ surface-container (card)
       └─ surface-container-high (navbar, popover, elevated card)
            └─ surface-container-highest (dialog, tooltip)
```

### Rule 4: Semantic Colors for States Only

`success`, `warning`, `error`, `info` communicate state — never for decoration or branding.

```heex
<%# CORRECT %>
<.dm_alert variant="error">Validation failed</.dm_alert>
<.dm_badge variant="success">Active</.dm_badge>

<%# WRONG %>
<.dm_btn variant="success">Submit</.dm_btn>   <%# Use primary %>
```

### Rule 5: Primary = Brand, Secondary = Support, Tertiary = Accent

| Role | Purpose | Examples |
|------|---------|----------|
| Primary | Brand identity, main actions, key focus | Appbar, main CTA, active nav |
| Secondary | Supporting actions, alternative emphasis | Secondary CTA, toggles |
| Tertiary | Special highlights, decorative accents | Feature badges, accent cards |

### Rule 6: One Primary Action Per View

One `variant="primary"` button per visible section. Supporting actions use `secondary`, `ghost`, or `outline`.

### Rule 7: Icons Inherit Color

`dm_mdi` and `dm_bsi` default to `currentcolor`. Do not set explicit `color=` unless the icon must differ from surrounding text.

### Rule 8: Container Colors for Soft Emphasis

Use `primary-container` / `on-primary-container` for tinted backgrounds with lower contrast. Good for featured sections, highlight cards, selected states.

```heex
<div class="bg-primary-container text-on-primary-container p-4 rounded-lg">
  Featured content with softer emphasis
</div>
```

---

## Typography

### Font Strategy

DuskMoon does not prescribe a typeface — projects choose their own. Rules:

- **Pick a distinctive display font** for headings — avoid Inter, Roboto, Arial, system-ui. Load from Google Fonts or self-host.
- **Pair with a clean body font** that complements the display choice.
- **Use a monospace font** for code blocks — JetBrains Mono, Fira Code, or similar.
- Define fonts as CSS variables, not inline.

```css
/* Project CSS — after DuskMoon imports */
:root {
  --font-display: 'Instrument Serif', serif;
  --font-body: 'DM Sans', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}

body { font-family: var(--font-body); }
h1, h2, h3 { font-family: var(--font-display); }
code, pre { font-family: var(--font-mono); }
```

### Type Scale

| Element | Class | Usage |
|---------|-------|-------|
| Page title | `text-3xl font-bold` | One per page |
| Section heading | `text-2xl font-semibold` | |
| Card title | `text-lg font-semibold` | |
| Body text | `text-base` | Default |
| Secondary text | `text-sm text-on-surface-variant` | Muted supporting info |
| Caption | `text-xs text-on-surface-variant` | Timestamps, metadata |

### Text Color Hierarchy

| Priority | Token | Usage |
|----------|-------|-------|
| Primary text | `text-on-surface` | Headings, body text, labels |
| Secondary text | `text-on-surface-variant` | Descriptions, hints, timestamps |
| Disabled text | `text-on-surface-variant` with `opacity-50` | Disabled states |
| Link text | `text-primary` | Clickable inline text |

---

## Layout Composition

### Spatial Principles

- **Content pages**: Generous whitespace — `p-6` or `p-8` on main, `gap-6` between cards
- **Data views**: Dense spacing — `p-4` on main, `gap-3` between items
- **Consistent gaps**: Pick one scale per view (`gap-4` or `gap-6`, not mixed)
- **Max width**: Content areas should constrain width — `max-w-7xl mx-auto` for wide, `max-w-3xl` for text-heavy

### Card Grid

```heex
<div class="grid grid-cols-auto-fit-80 gap-6">
  <.dm_card :for={item <- @items}>
    <:title><%= item.name %></:title>
    <%= item.description %>
  </.dm_card>
</div>
```

### Sidebar + Content

```heex
<div class="flex min-h-screen">
  <aside class="bg-secondary text-secondary-content w-64 border-r border-outline-variant p-4 shrink-0">
    <.dm_left_menu active={@current_path} />
  </aside>
  <main class="flex-1 bg-surface p-6 overflow-auto">
    <%= @inner_content %>
  </main>
</div>
```

### Stacked Sections with Depth

```heex
<section class="bg-surface-container-low p-8 rounded-2xl">
  <h2 class="text-2xl font-semibold mb-6">Featured</h2>
  <div class="grid grid-cols-3 gap-4">
    <.dm_card shadow="md">...</.dm_card>
    <.dm_card shadow="md">...</.dm_card>
    <.dm_card shadow="md">...</.dm_card>
  </div>
</section>
```

---

## Backgrounds & Depth

### Surface Layering

Don't use flat pages. Build depth with surface tokens:

```heex
<body class="bg-surface text-on-surface">
  <header class="bg-primary text-primary-content">...</header>
  <div class="bg-surface-container-low -mt-8 pt-12 pb-8 rounded-t-3xl">
    <div class="max-w-6xl mx-auto px-6">
      <.dm_card shadow="lg" class="bg-surface-container">
        ...
      </.dm_card>
    </div>
  </div>
</body>
```

### Hero Sections

Use container color gradients for hero areas:

```css
.hero {
  background: linear-gradient(
    135deg,
    var(--color-primary-container) 0%,
    var(--color-tertiary-container) 100%
  );
}
```

### Scrim & Overlays

```css
.overlay {
  background-color: hsl(var(--color-scrim) / 0.5);
  backdrop-filter: blur(4px);
}
```

### Borders & Dividers

- `outline-variant` → subtle dividers, decorative borders
- `outline` → interactive borders (inputs, focused states)

```heex
<hr class="border-outline-variant" />
<div class="border border-outline rounded-lg">Interactive element</div>
```

---

## Motion & Transitions

### Theme Transition

```css
* {
  transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease;
}
```

### Card Hover

```css
.interactive-card {
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}
.interactive-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}
```

### Reduced Motion

Always respect user preference:

```css
@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; animation: none !important; }
}
```

### Motion Principles

- One transition property per interaction — don't animate everything
- Page-level animations on route change (LiveView transitions)
- Subtle hover states on cards and buttons — `translateY(-2px)` max
- Loading states use `dm_loading_spinner` or skeleton components — no custom spinners

---

## Anti-Patterns

1. **Tailwind color scale** — No `bg-blue-500`, `text-gray-600`. Breaks theme switching.
2. **Hardcoded colors** — No hex, rgb, hsl, or named colors.
3. **Opacity faking surfaces** — No `bg-white/80`. Use `surface-container-*` tokens.
4. **Inline color styles** — No `style="color: ..."`.
5. **Raw HTML over components** — Use `dm_*` components when available.
6. **Uniform primary everywhere** — One primary action per view. Supporting actions recede.
7. **Semantic colors as decoration** — `success`/`error`/`warning`/`info` are for states only.
8. **Generic fonts** — No Inter, Roboto, Arial as conscious choices. Pick distinctive typefaces.
9. **Missing text pairing** — Every `bg-*` needs its `text-*-content` or `text-on-*`.
10. **Flat layouts** — Use surface elevation for depth. Pages should never feel like a single flat plane.
11. **Timid color usage** — A dominant primary with sharp accents outperforms evenly-distributed, wishy-washy palettes. Commit to the hierarchy.
12. **Cookie-cutter pages** — Each view type (dashboard, form, content, marketing) should have a distinct spatial composition. Don't copy-paste the same layout everywhere.