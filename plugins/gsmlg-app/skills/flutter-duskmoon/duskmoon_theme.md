# duskmoon_theme

Codegen-driven theme package for Material 3 Flutter apps. Provides color schemes, text themes, and complete `ThemeData` factories from design tokens.

## Installation

```yaml
dependencies:
  duskmoon_theme: ^1.0.0
```

```dart
import 'package:duskmoon_theme/duskmoon_theme.dart';
```

## Core Classes

### DmThemeData — Complete ThemeData Factory

```dart
// Apply to MaterialApp
MaterialApp(
  theme: DmThemeData.sunshine(),      // Light theme
  darkTheme: DmThemeData.moonlight(), // Dark theme
  themeMode: ThemeMode.system,
);

// List all available theme entries (name + light + dark)
final themes = DmThemeData.themes;
// Returns: [DmThemeEntry(name: 'sunshine', light: ..., dark: ...)]
```

`DmThemeData` builds fully configured Material 3 `ThemeData` including:
- Color scheme from generated tokens
- Material 3 type scale via `DmTextTheme`
- `DmColorExtension` with 20 semantic tokens
- Component themes: AppBar, NavigationRail, NavigationBar, Card, Divider, Input, Chip

### DmThemeEntry — Named Theme Bundle

```dart
class DmThemeEntry {
  final String name;      // e.g. 'sunshine'
  final ThemeData light;  // Light variant
  final ThemeData dark;   // Dark variant
}

// Iterate themes for a theme picker:
for (final entry in DmThemeData.themes) {
  print('${entry.name}: light=${entry.light}, dark=${entry.dark}');
}
```

### DmColorScheme — ColorScheme Factory

```dart
// Get raw ColorScheme without component themes:
final lightColors = DmColorScheme.sunshine();  // Brightness.light
final darkColors = DmColorScheme.moonlight();  // Brightness.dark

// Use standard ColorScheme accessors:
lightColors.primary
lightColors.onPrimary
lightColors.surface
lightColors.error
// ... all Material 3 color roles
```

### DmColorExtension — 20 Semantic Color Tokens

Access via `Theme.of(context).extension<DmColorExtension>()`:

```dart
final dmColors = Theme.of(context).extension<DmColorExtension>()!;

// Focus variants
dmColors.primaryFocus
dmColors.secondaryFocus
dmColors.tertiaryFocus

// Accent
dmColors.accent
dmColors.accentFocus
dmColors.accentContent

// Neutral
dmColors.neutral
dmColors.neutralFocus
dmColors.neutralContent
dmColors.neutralVariant

// Semantic status
dmColors.info
dmColors.infoContent
dmColors.success
dmColors.successContent
dmColors.warning
dmColors.warningContent

// Base surfaces (elevation levels)
dmColors.base100  // First level
dmColors.base200  // Second level
dmColors.base300  // Third level
dmColors.baseContent
```

Create custom instances:
```dart
DmColorExtension.sunshine()   // Light tokens
DmColorExtension.moonlight()  // Dark tokens
```

### DmTextTheme — Material 3 Type Scale

```dart
final textTheme = DmTextTheme.textTheme();
// Returns TextTheme with all M3 styles:
// displayLarge (57sp), displayMedium (45sp), displaySmall (36sp)
// headlineLarge (32sp), headlineMedium (28sp), headlineSmall (24sp)
// titleLarge (22sp), titleMedium (16sp), titleSmall (14sp)
// bodyLarge (16sp), bodyMedium (14sp), bodySmall (12sp)
// labelLarge (14sp), labelMedium (12sp), labelSmall (11sp)
```

### ThemeModeExtension — ThemeMode Helpers

```dart
// Parse from string
final mode = ThemeModeExtension.fromString('dark');  // ThemeMode.dark
final mode2 = ThemeModeExtension.fromString(null);   // ThemeMode.system

// UI helpers
ThemeMode.dark.title        // 'Dark'
ThemeMode.light.icon        // Icon(Icons.light_mode)
ThemeMode.system.iconOutlined // Icon(Icons.brightness_auto_outlined)
```

### Generated Tokens (Direct Access)

```dart
import 'package:duskmoon_theme/duskmoon_theme.dart';

// All tokens are const Color values:
SunshineTokens.primary
SunshineTokens.primaryContent
SunshineTokens.info
SunshineTokens.success
// ... etc

MoonlightTokens.primary
MoonlightTokens.surface
// ... etc
```

## Complete Setup Example

```dart
import 'package:flutter/material.dart';
import 'package:duskmoon_theme/duskmoon_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final entry = DmThemeData.themes.first;

    return MaterialApp(
      theme: entry.light,
      darkTheme: entry.dark,
      themeMode: _themeMode,
      home: Builder(
        builder: (context) {
          // Access semantic colors anywhere:
          final dmColors = Theme.of(context).extension<DmColorExtension>()!;

          return Scaffold(
            body: Container(
              color: dmColors.base100,
              child: Text(
                'Hello',
                style: TextStyle(color: dmColors.baseContent),
              ),
            ),
          );
        },
      ),
    );
  }
}
```
