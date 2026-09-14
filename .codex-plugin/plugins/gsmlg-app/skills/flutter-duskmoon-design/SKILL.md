---
name: flutter-duskmoon-design
description: Use when writing Flutter code that uses flutter_duskmoon_ui packages, when creating or modifying widgets that consume DmTheme or DmDesignTokens, when setting up theming in a DuskMoon app, when building adaptive widgets, or when reviewing code for DuskMoon design compliance. Also trigger when the user mentions duskmoon_theme, duskmoon_widgets, DuskmoonApp, DmTheme, DmAdaptiveWidget, DmDesignTokens, DmPlatformStyle, or any Dm* widget prefix. This skill defines the rules and patterns that ALL code touching the DuskMoon Flutter ecosystem must follow.
---

# Flutter DuskMoon UI — Design Principles & Usage Rules

## Architecture Overview

### Package Dependency Graph (import direction →)

```
duskmoon-dev/design (YAML → codegen)
  → duskmoon_theme
      ├ DmDesignTokens (generated const data)
      ├ DmTheme (InheritedWidget)
      ├ DmPlatformStyle { material, cupertino, fluent }
      └ toMaterial() / toCupertino() / toFluent()

duskmoon_theme
  → duskmoon_widgets
      ├ DuskmoonApp (root shell)
      ├ DmAdaptiveWidget (base class)
      └ Dm* widgets (Button, TextField, Switch, etc.)

duskmoon_widgets
  → duskmoon_settings
  → duskmoon_feedback
  → duskmoon_ui (umbrella re-export)
```

**Rule: Never import downstream.** `duskmoon_theme` must never import from `duskmoon_widgets`. `duskmoon_widgets` must never import from `duskmoon_settings`.

### Widget Tree (Runtime)

```
DuskmoonApp(tokens: .sunshine, darkTokens: .moonlight, platformStyle: .cupertino)
  └→ DmTheme (InheritedWidget — .of(context) available everywhere below)
       └→ CupertinoApp(theme: tokens.toCupertino())
            └→ user's widget tree
                 └→ DmButton(label: "Save")  // dispatches to CupertinoButton
```

---

## Rule 1: Theme Setup

### Correct App Root

```dart
// ✅ ALWAYS — use DuskmoonApp as the root widget
void main() {
  runApp(
    DuskmoonApp(
      tokens: DmDesignTokens.sunshine,
      darkTokens: DmDesignTokens.moonlight,
      themeMode: ThemeMode.system,
      platformStyle: DmPlatformStyle.material,
      home: const MyHomePage(),
    ),
  );
}
```

### ❌ NEVER — bypass DuskmoonApp

```dart
// ❌ NEVER wrap MaterialApp/CupertinoApp directly
void main() {
  runApp(MaterialApp(
    theme: DmDesignTokens.sunshine.toMaterial(), // wrong — skips DmTheme
    home: MyHomePage(),
  ));
}
```

**Why:** `DuskmoonApp` injects `DmTheme` above the platform app. Without it, `DmTheme.of(context)` returns null and all Dm* widgets fail to resolve tokens.

---

## Rule 2: Accessing Design Tokens

### Always use `DmTheme.of(context)`

```dart
// ✅ Read tokens from the widget tree
Widget build(BuildContext context) {
  final tokens = DmTheme.of(context).tokens;
  return Container(
    color: tokens.primaryContainer,
    child: Text('Hello', style: TextStyle(color: tokens.onPrimaryContainer)),
  );
}
```

### ❌ NEVER reference generated constants directly in widget builds

```dart
// ❌ This ignores dark mode, theme overrides, and subtree overrides
Widget build(BuildContext context) {
  return Container(color: DmDesignTokens.sunshine.primaryContainer);
}
```

**Why:** The resolved tokens depend on `ThemeMode`, platform brightness, and possible `DmThemeOverride` ancestors. Only `DmTheme.of(context)` returns the correct resolved set.

### Exception — static adapter methods

`DuskmoonApp` itself must convert tokens to platform `ThemeData` before `DmTheme` exists in the tree. For this case only, use the static adapters:

```dart
// Inside DuskmoonApp.build() — acceptable
MaterialApp(theme: DmTheme.staticToMaterial(resolvedTokens));
```

---

## Rule 3: Color System

### Token Structure (61 color tokens per theme)

| Group | Tokens | Usage |
|---|---|---|
| Primary | `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer` | Main brand actions, primary CTAs |
| Secondary | `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer` | Supporting actions, alternative CTAs |
| Tertiary | `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer` | Accent highlights, badges, special UI |
| Error | `error`, `onError`, `errorContainer`, `onErrorContainer` | Error states, destructive actions |
| Surface | `surface`, `onSurface`, `surfaceDim`, `surfaceBright`, `surfaceContainerLowest`→`Highest`, `surfaceVariant`, `onSurfaceVariant` | Backgrounds, cards, elevation |
| Outline | `outline`, `outlineVariant` | Borders, dividers |
| Inverse | `inverseSurface`, `inverseOnSurface`, `inversePrimary` | Snackbars, contrast overlays |
| Scrim/Shadow | `scrim` (with alpha), `shadow` | Modal overlays, elevation shadows |
| Semantic | `info`, `success`, `warning` (+ content variants) | Status indicators |

### Color Format: OKLCH

All colors are defined in OKLCH in the source CSS. The Dart codegen converts to `Color` objects via inline OKLCH→sRGB math (zero external deps).

### ❌ NEVER hardcode color values

```dart
// ❌ Hardcoded hex
Container(color: Color(0xFF60A5FA))

// ❌ Hardcoded Material color
Container(color: Colors.blue)

// ✅ Use design tokens
Container(color: DmTheme.of(context).tokens.primary)
```

### Semantic color pairing rule

**Every background token has a corresponding foreground token.** Always pair them:

```dart
// ✅ Correct pairing
Container(
  color: tokens.primaryContainer,
  child: Text('Label', style: TextStyle(color: tokens.onPrimaryContainer)),
)

// ❌ Mismatched — onSurface on primaryContainer may fail contrast
Container(
  color: tokens.primaryContainer,
  child: Text('Label', style: TextStyle(color: tokens.onSurface)),
)
```

| Background | Foreground |
|---|---|
| `primary` | `onPrimary` |
| `primaryContainer` | `onPrimaryContainer` |
| `secondary` | `onSecondary` |
| `secondaryContainer` | `onSecondaryContainer` |
| `tertiary` | `onTertiary` |
| `tertiaryContainer` | `onTertiaryContainer` |
| `surface` | `onSurface` |
| `surfaceVariant` | `onSurfaceVariant` |
| `error` | `onError` |
| `errorContainer` | `onErrorContainer` |
| `inverseSurface` | `inverseOnSurface` |

### Surface elevation hierarchy

Use surface container tokens for visual depth, not opacity or shadows alone:

```
surfaceContainerLowest  →  bottom layer (behind everything)
surfaceContainerLow     →  low-elevation cards
surfaceContainer        →  standard cards/containers
surfaceContainerHigh    →  elevated cards, menus
surfaceContainerHighest →  dialogs, tooltips, top layer
```

---

## Rule 4: Available Themes

5 themes defined in `duskmoon-dev/design`, codegen'd to Dart:

| Theme | Mode | Primary Character |
|---|---|---|
| `sunshine` | light | Warm amber/gold |
| `moonlight` | dark | Cool blue/lavender |
| `ocean` | dark | Deep blue/teal |
| `forest` | light | Natural green/earth |
| `sunset` | light | Warm orange/rose |

Access via `DmDesignTokens.sunshine`, `DmDesignTokens.moonlight`, etc.

---

## Rule 5: Platform Adaptive Widgets

### Resolution Stack (highest priority first)

```
L1: Per-widget `platformOverride` parameter
L2: Nearest DmPlatformOverride ancestor (subtree override)
L3: DmTheme.of(context).platformStyle (from DuskmoonApp)
L4: defaultTargetPlatform (auto-detect)
```

### Writing an adaptive widget

All adaptive widgets extend `DmAdaptiveWidget`:

```dart
class DmButton extends DmAdaptiveWidget {
  const DmButton({super.key, required this.label, super.platformOverride});
  final String label;

  @override
  Widget buildMaterial(BuildContext context, DmDesignTokens tokens) {
    return FilledButton(onPressed: () {}, child: Text(label));
  }

  @override
  Widget buildCupertino(BuildContext context, DmDesignTokens tokens) {
    return CupertinoButton.filled(onPressed: () {}, child: Text(label));
  }

  // buildFluent defaults to buildMaterial unless overridden
}
```

### ❌ NEVER check platform manually

```dart
// ❌ Manual platform switching
if (Platform.isIOS) {
  return CupertinoButton(...);
} else {
  return ElevatedButton(...);
}

// ✅ Use DmAdaptiveWidget dispatch or DmPlatformStyle resolution
class MyWidget extends DmAdaptiveWidget { ... }
```

### File structure for adaptive widgets

```
dm_button/
├── dm_button.dart            # Public API, extends DmAdaptiveWidget
├── dm_button_material.dart   # buildMaterial implementation
├── dm_button_cupertino.dart  # buildCupertino implementation
└── dm_button_fluent.dart     # buildFluent (optional, falls through to material)
```

---

## Rule 6: Shared Design Enums

All Dm* widgets share these semantic enums. Use them consistently — never invent ad-hoc parameters.

```dart
enum DmColorRole { primary, secondary, tertiary, error, neutral }
enum DmSize { xs, sm, md, lg, xl }
enum DmButtonVariant { filled, outlined, ghost, tonal }
enum DmInputVariant { outlined, filled, underlined }
```

### Color resolution from DmColorRole

Every widget that takes `DmColorRole` resolves tokens identically:

| DmColorRole | Background | Foreground | Container | On Container |
|---|---|---|---|---|
| `primary` | `tokens.primary` | `tokens.onPrimary` | `tokens.primaryContainer` | `tokens.onPrimaryContainer` |
| `secondary` | `tokens.secondary` | `tokens.onSecondary` | `tokens.secondaryContainer` | `tokens.onSecondaryContainer` |
| `tertiary` | `tokens.tertiary` | `tokens.onTertiary` | `tokens.tertiaryContainer` | `tokens.onTertiaryContainer` |
| `error` | `tokens.error` | `tokens.onError` | `tokens.errorContainer` | `tokens.onErrorContainer` |
| `neutral` | `tokens.surface` | `tokens.onSurface` | `tokens.surfaceContainerHigh` | `tokens.onSurface` |

### Size scale

| DmSize | Horizontal padding | Vertical padding | Font scale |
|---|---|---|---|
| `xs` | 8 | 4 | 0.75rem (12) |
| `sm` | 12 | 6 | 0.875rem (14) |
| `md` | 16 | 8 | 0.875rem (14) |
| `lg` | 24 | 12 | 1rem (16) |
| `xl` | 32 | 16 | 1.125rem (18) |

---

## Rule 7: Component Design — Actions

### DmButton

**Default**: `variant: filled`, `color: primary`, `size: md`

| Variant | Background | Foreground | Border | Use case |
|---|---|---|---|---|
| `filled` | role color | onRole | none | Primary CTAs, main actions |
| `outlined` | transparent | role color | role color | Secondary actions, cancel |
| `ghost` | transparent | role color | none | Tertiary/inline actions, links |
| `tonal` | roleContainer | onRoleContainer | none | Soft emphasis, toggles |

**Color role assignment convention:**

| Action type | Color role | Example |
|---|---|---|
| Main CTA, save, submit, confirm | `primary` | "Save Changes" |
| Alternative action, secondary flow | `secondary` | "Export", "Share" |
| Accent action, special highlight | `tertiary` | "Watch Demo", "Premium" |
| Destructive, delete, remove | `error` | "Delete Account" |
| Neutral, dismiss, low emphasis | `neutral` | "Cancel", "Skip" |

```dart
// ✅ Typical action group
Row(children: [
  DmButton(variant: .ghost, color: .neutral, child: Text('Cancel')),
  DmButton(variant: .outlined, color: .secondary, child: Text('Save Draft')),
  DmButton(variant: .filled, color: .primary, child: Text('Publish')),
])
```

### DmIconButton

Same color/size system as DmButton. **Must always have `semanticLabel`.**

```dart
DmIconButton(
  icon: Icons.delete,
  color: DmColorRole.error,
  semanticLabel: 'Delete item',
  onPressed: () {},
)
```

### DmFab (Floating Action Button)

- **Default color**: `primary` — the single most important action on the screen
- **Surface**: `primaryContainer` background, `onPrimaryContainer` icon
- **Rule**: Maximum one FAB per screen. If you need multiple actions, use `DmActionList`.

```dart
DmFab(
  onPressed: () {},
  icon: Icons.add,
  // FAB always uses primaryContainer/onPrimaryContainer — no color param
)
```

### DmActionList

Adapts rendering to available space:

| Breakpoint | Rendering |
|---|---|
| Small (< 600) | Popup menu (overflow) |
| Medium (600–1200) | Icon buttons in row |
| Large (> 1200) | Text buttons with icons |

```dart
DmActionList(
  actions: [
    DmAction(icon: Icons.edit, label: 'Edit', onPressed: ...),
    DmAction(icon: Icons.share, label: 'Share', onPressed: ...),
    DmAction(icon: Icons.delete, label: 'Delete', color: DmColorRole.error, onPressed: ...),
  ],
)
```

---

## Rule 8: Component Design — Navigation

### DmAppBar

**Default token mapping:**

| Element | Token | Rationale |
|---|---|---|
| Background | `primary` | Brand presence, top-level identity |
| Title text | `onPrimary` | Contrast on primary |
| Icon buttons | `onPrimary` | Consistent with primary surface |
| Bottom border | none (primary fills) | Clean branded bar |

**Scrolled/elevated state:** Background transitions to `primaryContainer`, text to `onPrimaryContainer`.

```dart
DmAppBar(
  title: Text('Settings'),
  leading: DmIconButton(icon: Icons.arrow_back, semanticLabel: 'Back'),
  actions: [
    DmIconButton(icon: Icons.search, semanticLabel: 'Search'),
    DmIconButton(icon: Icons.more_vert, semanticLabel: 'More options'),
  ],
)
```

**Neutral variant:** For screens where the app bar should not compete with content (e.g., content-heavy reading views), pass `color: DmColorRole.neutral` to fall back to `surface`/`onSurface`.

### DmBottomNav

| Element | Token |
|---|---|
| Background | `primary` |
| Selected icon/label | `onPrimary` |
| Unselected icon/label | `onPrimary` at 70% opacity |
| Selected indicator | `primaryContainer` (pill behind icon) |
| Top border | none (primary fills) |

**Rule**: 3–5 destinations maximum. Labels always visible (not icon-only).

### DmTabBar

| Element | Token |
|---|---|
| Background | `surface` |
| Selected tab | `primary` (indicator + text) |
| Unselected tab | `onSurfaceVariant` |
| Indicator | `primary` (bottom line in Material, pill in Cupertino) |

### DmDrawer

| Element | Token |
|---|---|
| Background | `secondary` |
| Header area | `secondaryContainer` |
| Selected item bg | `onSecondary` at 15% opacity |
| Selected item text | `onSecondary` |
| Unselected text | `onSecondary` at 70% opacity |
| Dividers | `onSecondary` at 20% opacity |
| Scrim (overlay behind drawer) | `scrim` with alpha |

Side menus and drawers use the **secondary** color family to visually distinguish navigation chrome from the primary-branded top bar.

### DmBreadcrumbs

| Element | Token |
|---|---|
| Active (current) | `onSurface` (no link) |
| Ancestors (links) | `primary` |
| Separator | `onSurfaceVariant` |

---

## Rule 9: Component Design — Layout & Cards

### DmCard

**Elevation hierarchy via surface tokens:**

| Card style | Background token | Use case |
|---|---|---|
| Flat | `surface` | Inline content, no separation |
| Outlined | `surface` + `outlineVariant` border | List items, settings rows |
| Elevated | `surfaceContainerLow` | Standard cards |
| Filled | `surfaceContainerHigh` | Emphasized/grouped content |

**Interior layout convention:**

```
┌─────────────────────────────────┐
│ [optional media/image]          │
├─────────────────────────────────┤
│ Title         (onSurface)       │
│ Subtitle      (onSurfaceVariant)│
│                                 │
│ Body text     (onSurface)       │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Actions: ghost/outlined btns│ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

```dart
DmCard(
  style: DmCardStyle.elevated,
  child: Column(children: [
    Image(...),
    Padding(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Text('Title', style: TextStyle(color: tokens.onSurface)),
        Text('Subtitle', style: TextStyle(color: tokens.onSurfaceVariant)),
        Row(children: [
          DmButton(variant: .ghost, child: Text('Cancel')),
          DmButton(variant: .filled, child: Text('Confirm')),
        ]),
      ]),
    ),
  ]),
)
```

**❌ NEVER** put a `filled` primary card background with `onPrimary` text for regular content cards. Primary/secondary/tertiary containers are for **interactive highlights** (selected state, feature callout), not default card backgrounds.

### DmDivider

| Variant | Token | Use case |
|---|---|---|
| Default | `outlineVariant` | Section separation |
| Strong | `outline` | Major section breaks |

### DmScaffold

Responsive layout dispatch:

| Breakpoint | Navigation style |
|---|---|
| Compact (< 600) | `DmBottomNav` |
| Medium (600–1200) | `NavigationRail` (collapsed) |
| Expanded (> 1200) | `NavigationRail` (expanded with labels) |

Page body background: `surface`. Rail/side nav background: `secondary`.

---

## Rule 10: Component Design — Data Display (Bricks)

### DmBadge

Small status/count indicator. Takes `DmColorRole`.

| Variant | Background | Foreground | Use case |
|---|---|---|---|
| Filled | role color | onRole | Notification count, status dot |
| Tonal | roleContainer | onRoleContainer | Soft label, category tag |

**Default**: `color: error` (notification convention), `size: sm`

```dart
DmBadge(count: 3)                                  // red notification dot
DmBadge(label: 'New', color: .tertiary, variant: .tonal)  // soft accent tag
DmBadge(label: 'Draft', color: .neutral, variant: .tonal) // muted status
```

### DmChip

Selectable/filterable labels. Takes `DmColorRole`.

| State | Background | Foreground | Border |
|---|---|---|---|
| Unselected | `surface` | `onSurfaceVariant` | `outline` |
| Selected | `secondaryContainer` | `onSecondaryContainer` | none |
| Disabled | `surface` at 38% opacity | `onSurface` at 38% | `outline` at 12% |

**Default selection color**: `secondary` — secondary containers are for selection states.

### DmAvatar

| Variant | Background | Foreground |
|---|---|---|
| With image | — | — |
| Initials (default) | `primaryContainer` | `onPrimaryContainer` |
| Initials (group variety) | Cycle through `primary`/`secondary`/`tertiary` containers | Matching `onContainer` |

Sizes follow `DmSize` enum. Default: `md` (40dp diameter).

### DmStat (Data Brick)

Statistics display block:

```
┌───────────────┐
│ 1,234         │  ← value: onSurface, large/bold
│ Active Users  │  ← label: onSurfaceVariant, small
│ ▲ 12.5%       │  ← trend: success or error token
└───────────────┘
```

| Element | Token |
|---|---|
| Value | `onSurface` |
| Label | `onSurfaceVariant` |
| Positive trend | `success` (or `tokens.success`) |
| Negative trend | `error` |
| Card background | `surfaceContainerLow` (when in card) |

### DmTable / Data Grid

| Element | Token |
|---|---|
| Header row bg | `surfaceContainerHigh` |
| Header text | `onSurface` (bold) |
| Body row bg (even) | `surface` |
| Body row bg (odd) | `surfaceContainerLowest` |
| Body text | `onSurface` |
| Row hover | `surfaceContainerLow` |
| Selected row | `secondaryContainer` |
| Border/grid lines | `outlineVariant` |
| Sort indicator | `primary` |

---

## Rule 11: Component Design — Feedback

### DmAlert

| Semantic | Background | Foreground | Icon color |
|---|---|---|---|
| Info | `infoContainer` (or `surfaceContainerHigh` + info icon) | `onSurface` | `info` |
| Success | `successContainer` | `onSurface` | `success` |
| Warning | `warningContainer` | `onSurface` | `warning` |
| Error | `errorContainer` | `onErrorContainer` | `error` |

**Convention**: Alerts use semantic container tokens with full-width layout. For inline indicators, use `DmBadge`.

### DmDialog

| Element | Token |
|---|---|
| Scrim (backdrop) | `scrim` with alpha |
| Dialog surface | `surfaceContainerHighest` |
| Title | `onSurface` |
| Body | `onSurfaceVariant` |
| Confirm button | `DmButton(variant: .filled, color: .primary)` |
| Cancel button | `DmButton(variant: .ghost, color: .neutral)` |
| Destructive confirm | `DmButton(variant: .filled, color: .error)` |

### DmSnackbar

Uses **inverse** tokens for contrast against current theme:

| Element | Token |
|---|---|
| Background | `inverseSurface` |
| Text | `inverseOnSurface` |
| Action button | `inversePrimary` |

### DmProgress

Linear and circular variants. Default color: `primary`.

| Variant | Track | Indicator |
|---|---|---|
| Default | `surfaceContainerHighest` | `primary` |
| With color role | `roleContainer` (at low opacity) | role color |

### DmSkeleton

Loading placeholder. Uses `surfaceContainerHigh` with shimmer animation toward `surfaceContainerLow`.

---

## Rule 12: Component Design — Inputs

### DmTextField

| Variant | Idle | Focused | Error |
|---|---|---|---|
| `outlined` | `outlineVariant` border | `primary` border (2px) | `error` border |
| `filled` | `surfaceContainerHighest` bg | `primary` bottom indicator | `error` indicator |
| `underlined` | `outlineVariant` bottom line | `primary` bottom line (2px) | `error` line |

| Element | Token |
|---|---|
| Input text | `onSurface` |
| Placeholder/hint | `onSurfaceVariant` |
| Label (floating) | `onSurfaceVariant` → `primary` when focused |
| Helper text | `onSurfaceVariant` |
| Error text | `error` |
| Prefix/suffix icon | `onSurfaceVariant` |

**Default variant**: `outlined`

### DmCheckbox / DmSwitch / DmSlider

| State | Token |
|---|---|
| Unchecked/off | `onSurfaceVariant` (border), `surface` (fill) |
| Checked/on | `primary` (fill), `onPrimary` (checkmark) |
| Track (switch off) | `surfaceContainerHighest` |
| Track (switch on) | `primary` at 50% → `primaryContainer` |
| Thumb | `outline` (off) → `onPrimary` (on, over primary track) |
| Slider active track | `primary` |
| Slider inactive track | `surfaceContainerHighest` |
| Slider thumb | `primary` |
| Disabled | All at 38% opacity |

---

## Rule 13: Visual Design Principles

### Hierarchy through token roles, not through ad-hoc colors

```
Primary   → THE action (one per screen section)
Secondary → supporting actions, selection states
Tertiary  → accents, highlights, special callouts
Surface   → everything else (backgrounds, text, structure)
```

**If you need emphasis, promote the token role — don't invent a color.**

### Density and spacing

DuskMoon follows MD3 density: default padding 16dp, compact 12dp, comfortable 24dp. Widget padding follows the `DmSize` scale.

### Elevation = surface tokens, not shadows

Use `surfaceContainerLowest` → `surfaceContainerHighest` for visual hierarchy. Shadows (`shadow` token) are supplementary, not the primary depth cue.

```dart
// ✅ Surface-token elevation
Container(color: tokens.surfaceContainerHigh)  // elevated
Container(color: tokens.surface)                // base level

// ❌ Shadow-only elevation
Container(
  decoration: BoxDecoration(
    color: tokens.surface,
    boxShadow: [BoxShadow(blurRadius: 8)],  // shadow without surface distinction
  ),
)
```

### Dark mode is not "invert everything"

Each theme has its own curated token set. The codegen produces distinct values per theme. **Never** compute dark colors by inverting or dimming light colors at runtime.

```dart
// ❌ Never compute dark variants
final darkBg = Color.lerp(tokens.surface, Colors.black, 0.3);

// ✅ Use the dark theme's own tokens
DuskmoonApp(tokens: .sunshine, darkTokens: .moonlight)  // moonlight has its own curated values
```

---

## Rule 14: Package Boundaries

> (Architecture rules — same as above, renumbered for continuity)

### What goes where

| Package | Contains | Does NOT contain |
|---|---|---|
| `duskmoon_theme` | `DmDesignTokens`, `DmTheme`, `DmPlatformStyle`, `toMaterial()` / `toCupertino()` / `toFluent()` adapters | Any widgets, any `BuildContext`-dependent rendering |
| `duskmoon_widgets` | `DuskmoonApp`, `DmAdaptiveWidget`, all `Dm*` widgets | Token definitions, theme adapters |
| `duskmoon_theme_bloc` | `DmThemeBloc`, `DmThemeCubit` for runtime theme switching | Widget implementations |
| `duskmoon_settings` | Settings UI widgets built on adaptive dispatch | Theme internals |
| `duskmoon_feedback` | Feedback/bug-report widgets | Theme internals |
| `duskmoon_ui` | Umbrella — re-exports all above | No unique code |

### ❌ NEVER add duskmoon_widgets as dependency of duskmoon_theme

This creates a circular dependency. If `duskmoon_theme` needs to reference a widget concept, use an abstract interface or callback, not a concrete widget import.

---

## Rule 15: Code Engine Integration

`duskmoon_code_engine` has **zero dependency** on `duskmoon_theme`. The theme adapter lives as an extension method in `duskmoon_theme`:

```dart
// In duskmoon_theme — NOT in duskmoon_code_engine
extension DmCodeEngineTheme on DmDesignTokens {
  CodeEditorTheme toCodeEditorTheme() => CodeEditorTheme(
    background: surface,
    foreground: onSurface,
    // ...
  );
}
```

---

## Rule 16: Codegen Pipeline

```
duskmoon-dev/design YAML
  → Bun/TypeScript emitter
    → CSS (duskmoonui consumption)
    → TypeScript (duskmoonui/duskmoon-elements)
    → Dart (flutter_duskmoon_ui — committed, CI never needs Bun)
    → JSON (documentation/tooling)
```

**Generated Dart files are committed to git.** CI must never require Bun or Node to build the Flutter packages.

### ❌ NEVER hand-edit generated files

Files in `packages/duskmoon_theme/lib/src/generated/` are produced by codegen. Edit the YAML source in `duskmoon-dev/design` and re-run the pipeline.

---

## Rule 17: Accessibility

- All color pairings must meet WCAG 2.1 AA contrast (4.5:1 normal text, 3:1 large text)
- Every interactive Dm* widget must support keyboard navigation
- Semantic labels required on all icon-only buttons
- Focus indicators must be visible on all themes

---

## Rule 18: Testing Patterns

### Widget tests must verify all three platforms

```dart
for (final style in DmPlatformStyle.values) {
  testWidgets('DmButton renders on $style', (tester) async {
    await tester.pumpWidget(
      DuskmoonApp(
        tokens: DmDesignTokens.sunshine,
        platformStyle: style,
        home: const DmButton(label: 'Test'),
      ),
    );
    expect(find.text('Test'), findsOneWidget);
  });
}
```

### Theme tests must verify token resolution

```dart
testWidgets('DmTheme.of resolves correct tokens', (tester) async {
  late DmDesignTokens resolved;
  await tester.pumpWidget(
    DuskmoonApp(
      tokens: DmDesignTokens.sunshine,
      home: Builder(builder: (context) {
        resolved = DmTheme.of(context).tokens;
        return const SizedBox();
      }),
    ),
  );
  expect(resolved.primary, equals(DmDesignTokens.sunshine.primary));
});
```

---

## Quick Reference: Anti-Patterns

| ❌ Don't | ✅ Do |
|---|---|
| `MaterialApp(theme: tokens.toMaterial())` as root | `DuskmoonApp(tokens: ...)` as root |
| `DmDesignTokens.sunshine.primary` in widget build | `DmTheme.of(context).tokens.primary` |
| `Color(0xFF...)` or `Colors.blue` | `tokens.primary` / `tokens.secondary` |
| `Platform.isIOS` for widget dispatch | Extend `DmAdaptiveWidget` |
| Hand-edit `generated/` Dart files | Edit YAML source, re-run codegen |
| Import `duskmoon_widgets` from `duskmoon_theme` | Keep dependency direction strict |
| Put theme adapter in `duskmoon_code_engine` | Extension method in `duskmoon_theme` |
| `primaryContainer` bg + `onSurface` text | Pair `primaryContainer` + `onPrimaryContainer` |
| AppBar background = `surface` | AppBar background = `primary` (DuskMoon convention) |
| Drawer/side menu bg = `primary` | Drawer/side menu bg = `secondary` (navigation chrome distinction) |
| Card default bg = `primaryContainer` | Card bg = `surfaceContainerLow` / `surface` + outline |
| Shadows as primary depth cue | Surface container tokens for elevation hierarchy |
| `Color.lerp(x, Colors.black, 0.3)` for dark mode | Use the dark theme's own curated tokens |
| Multiple FABs on one screen | One FAB max; use `DmActionList` for multiple |
| Icon button without `semanticLabel` | Always provide `semanticLabel` on `DmIconButton` |
| Selection highlight with `primary` | Selection states use `secondaryContainer` |
| Inventing colors outside the token system | Promote token role (primary→secondary→tertiary) |

---

## Checklist for Code Review

When reviewing Flutter code that uses DuskMoon UI, verify:

**Architecture:**
- [ ] App root is `DuskmoonApp`, not `MaterialApp`/`CupertinoApp` directly
- [ ] Package imports flow downstream only (theme → widgets → settings)
- [ ] No generated files were hand-edited
- [ ] No `duskmoon_theme` dependency in `duskmoon_code_engine`
- [ ] Adaptive widgets extend `DmAdaptiveWidget`, not manual platform checks

**Color & Tokens:**
- [ ] All color values come from `DmTheme.of(context).tokens`, not hardcoded
- [ ] Background/foreground token pairs match (primary↔onPrimary, etc.)
- [ ] No `Colors.*` or `Color(0x...)` literals
- [ ] Dark mode uses separate theme tokens, no runtime color computation

**Component Design:**
- [ ] Buttons use `DmColorRole` convention (primary=main CTA, error=destructive, etc.)
- [ ] AppBar and BottomNav use `primary`/`onPrimary` defaults
- [ ] Drawer and side menu use `secondary`/`onSecondary` defaults
- [ ] Cards use surface container tokens, not primary/secondary containers for default bg
- [ ] Selection states use `secondaryContainer` tokens
- [ ] Surface elevation via container tokens, not shadow-only
- [ ] Maximum one FAB per screen section
- [ ] `DmActionList` for multiple actions, not ad-hoc button rows
- [ ] Snackbar uses inverse tokens
- [ ] Dialog scrim uses `scrim` token with alpha

**Accessibility:**
- [ ] Semantic labels on all icon-only buttons
- [ ] Focus indicators visible on all themes
- [ ] Widget tests cover all three `DmPlatformStyle` values
- [ ] WCAG AA contrast on all bg/fg pairings