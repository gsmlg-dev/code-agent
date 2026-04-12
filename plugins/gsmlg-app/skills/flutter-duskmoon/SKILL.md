---
name: flutter-duskmoon
description: Flutter DuskMoon UI design system — theme, adaptive widgets, settings, feedback, forms, data visualization, code editor engine, and BLoC theme persistence. Use when building Flutter apps with duskmoon_ui, duskmoon_theme, duskmoon_widgets, duskmoon_settings, duskmoon_feedback, duskmoon_form, duskmoon_visualization, duskmoon_code_engine, or duskmoon_theme_bloc packages.
---

# Flutter DuskMoon UI Design System

Complete component library for Flutter apps with codegen-driven theming, adaptive (Material/Cupertino) widgets, platform-aware settings UI, feedback helpers, and data visualization.

## Quick Start

### Umbrella package (recommended)

Add `duskmoon_ui` to get theme + widgets + settings + feedback + forms in one import:

```yaml
# pubspec.yaml
dependencies:
  duskmoon_ui: ^1.4.0
```

```dart
import 'package:duskmoon_ui/duskmoon_ui.dart';
```

### Individual packages

```yaml
dependencies:
  duskmoon_theme: ^1.4.0           # Theme only
  duskmoon_widgets: ^1.4.0         # Adaptive widgets
  duskmoon_settings: ^1.4.0        # Settings UI
  duskmoon_feedback: ^1.4.0        # Dialogs, toasts, snackbars
  duskmoon_form: ^1.4.0            # BLoC-based form management
  duskmoon_visualization: ^1.4.0   # Data visualization charts
  duskmoon_theme_bloc: ^1.4.0      # BLoC persistence
  duskmoon_adaptive_scaffold: ^1.4.0  # Responsive scaffold
  duskmoon_code_engine: ^1.4.0     # Code editor engine
```

## Skill Modules

Detailed documentation is split by package:

- [duskmoon_theme.md](duskmoon_theme.md) — Theme system, color schemes, text themes, extensions
- [duskmoon_widgets.md](duskmoon_widgets.md) — 19 adaptive widgets (Material/Cupertino) plus markdown rendering, markdown input, and code editor
- [duskmoon_settings.md](duskmoon_settings.md) — Platform-aware settings UI (Material/Cupertino/Fluent)
- [duskmoon_feedback.md](duskmoon_feedback.md) — Dialogs, snackbars, toasts, bottom sheets
- [duskmoon_form.md](duskmoon_form.md) — BLoC-based form state management with 13 widget builders and 9 field BLoCs
- [duskmoon_visualization.md](duskmoon_visualization.md) — Data visualization: line, bar, scatter, heatmap, network graph, map chart
- [duskmoon_theme_bloc.md](duskmoon_theme_bloc.md) — BLoC for persisting theme via SharedPreferences
- [duskmoon_adaptive_scaffold.md](duskmoon_adaptive_scaffold.md) — Responsive scaffold with M3 adaptive layout, breakpoints, and slot-based composition
- [duskmoon_code_engine.md](duskmoon_code_engine.md) — Pure Dart code editor engine with 19 language grammars, incremental parsing, and syntax highlighting

## Minimal App Example

```dart
import 'package:flutter/material.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DmThemeData.sunshine(),
      darkTheme: DmThemeData.moonlight(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DmAppBar(title: const Text('DuskMoon App')),
      body: Center(
        child: DmButton(
          onPressed: () => showDmSuccessToast(
            context: context,
            message: 'Hello from DuskMoon!',
          ),
          child: const Text('Tap me'),
        ),
      ),
    );
  }
}
```

## Architecture Overview

```
duskmoon_theme              <- Pure theme, zero external deps
    +-- duskmoon_theme_bloc <- BLoC for theme persistence
    +-- duskmoon_widgets    <- 19 adaptive widgets + markdown + code editor
    |       +-- duskmoon_code_engine (for DmCodeEditor)
    +-- duskmoon_settings   <- Settings UI (Material/Cupertino/Fluent)
    +-- duskmoon_feedback   <- Dialogs, snackbars, toasts, bottom sheets
    +-- duskmoon_form       <- BLoC-based form management (depends on theme + widgets)
    +-- duskmoon_visualization <- Data visualization charts (depends on theme)
    +-- duskmoon_code_engine <- Pure Dart code editor (re-exported by umbrella)
            |
        duskmoon_ui         <- Umbrella: re-exports all packages
                               Provides DmEditorTheme (fromTheme, sunshine, moonlight)

duskmoon_code_engine        <- Pure Dart code editor (standalone)
duskmoon_adaptive_scaffold  <- Responsive scaffold (forked, independently versioned)
```

## Conventions

- All public classes use `Dm` prefix
- Factory classes are `abstract final` with static methods
- Generated token files use `.g.dart` suffix in `src/generated/`
- BLoC classes (user-subclassable) keep original names (e.g., `FormBloc`, `TextFieldBloc`); only UI widgets get `Dm` prefix
- Platform resolution is 4-tier: widget `platformOverride` -> `DmPlatformOverride` InheritedWidget -> `DuskmoonApp` -> `Theme.of(context).platform`
- `DmPlatformStyle` has 3 values: `material`, `cupertino`, `fluent`
