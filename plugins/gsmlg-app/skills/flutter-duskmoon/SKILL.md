---
name: flutter-duskmoon
description: Flutter DuskMoon UI design system — theme, adaptive widgets, settings, feedback, and BLoC theme persistence. Use when building Flutter apps with duskmoon_ui, duskmoon_theme, duskmoon_widgets, duskmoon_settings, duskmoon_feedback, or duskmoon_theme_bloc packages.
---

# Flutter DuskMoon UI Design System

Complete component library for Flutter apps with codegen-driven theming, adaptive (Material/Cupertino) widgets, platform-aware settings UI, and feedback helpers.

## Quick Start

### Umbrella package (recommended)

Add `duskmoon_ui` to get theme + widgets + settings + feedback in one import:

```yaml
# pubspec.yaml
dependencies:
  duskmoon_ui: ^1.0.0
```

```dart
import 'package:duskmoon_ui/duskmoon_ui.dart';
```

### Individual packages

```yaml
dependencies:
  duskmoon_theme: ^1.0.0      # Theme only
  duskmoon_widgets: ^1.0.0    # Adaptive widgets
  duskmoon_settings: ^1.0.0   # Settings UI
  duskmoon_feedback: ^1.0.0   # Dialogs, toasts, snackbars
  duskmoon_theme_bloc: ^1.0.0 # Opt-in BLoC persistence (NOT in umbrella)
```

## Skill Modules

Detailed documentation is split by package:

- [duskmoon_theme.md](duskmoon_theme.md) — Theme system, color schemes, text themes, extensions
- [duskmoon_widgets.md](duskmoon_widgets.md) — 18 adaptive widgets with Material/Cupertino rendering
- [duskmoon_settings.md](duskmoon_settings.md) — Platform-aware settings UI (Material/Cupertino/Fluent)
- [duskmoon_feedback.md](duskmoon_feedback.md) — Dialogs, snackbars, toasts, bottom sheets
- [duskmoon_theme_bloc.md](duskmoon_theme_bloc.md) — BLoC for persisting theme via SharedPreferences

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
    +-- duskmoon_theme_bloc <- Opt-in BLoC for theme persistence (NOT in umbrella)
    +-- duskmoon_widgets    <- 18 adaptive widgets (Material/Cupertino)
    +-- duskmoon_settings   <- Settings UI (Material/Cupertino/Fluent)
    +-- duskmoon_feedback   <- Dialogs, snackbars, toasts, bottom sheets
            |
        duskmoon_ui         <- Umbrella: re-exports theme + widgets + settings + feedback
```

## Conventions

- All public classes use `Dm` prefix
- Factory classes are `abstract final` with static methods
- Generated token files use `.g.dart` suffix in `src/generated/`
- `duskmoon_theme_bloc` is intentionally excluded from umbrella re-export
