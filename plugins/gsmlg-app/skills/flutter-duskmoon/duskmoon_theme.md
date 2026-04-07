# duskmoon_theme

Codegen-driven theme package for Material 3 Flutter apps. Provides color schemes, text themes, and complete `ThemeData` factories from design tokens.

## Installation

```yaml
dependencies:
  duskmoon_theme: ^1.2.3
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

// Build from a DmTheme token container:
final themeData = DmThemeData.fromDmTheme(DmTheme.sunshine);
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

### DmTheme — Platform-Agnostic Token Container

Holds color tokens without coupling to Flutter's `ThemeData`. Use for renderer-agnostic access or to build ThemeData via `DmThemeData.fromDmTheme()`.

```dart
// Access pre-built token sets:
final light = DmTheme.sunshine;
final dark = DmTheme.moonlight;

// Iterate all themes:
for (final theme in DmTheme.all) {
  print(theme.name);                    // 'sunshine' or 'moonlight'
  print(theme.colors.colorScheme.primary); // Color
  print(theme.colors.extension.accent);    // Color
}

// Build ThemeData from a DmTheme:
final themeData = DmThemeData.fromDmTheme(DmTheme.sunshine);
```

### DmColors — Color Token Bag

Bundles a `ColorScheme` and `DmColorExtension` into a single immutable container.

```dart
final colors = DmColors.sunshine();
colors.colorScheme.primary   // Standard Material 3 color
colors.extension.accent       // DuskMoon semantic token

// Or construct custom:
final custom = DmColors(
  colorScheme: myColorScheme,
  extension: myDmColorExtension,
);
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

Construct a fully custom extension:
```dart
const DmColorExtension(
  primaryFocus: Color(0xFF...),
  secondaryFocus: Color(0xFF...),
  tertiaryFocus: Color(0xFF...),
  accent: Color(0xFF...),
  accentFocus: Color(0xFF...),
  accentContent: Color(0xFF...),
  neutral: Color(0xFF...),
  neutralFocus: Color(0xFF...),
  neutralContent: Color(0xFF...),
  neutralVariant: Color(0xFF...),
  info: Color(0xFF...),
  infoContent: Color(0xFF...),
  success: Color(0xFF...),
  successContent: Color(0xFF...),
  warning: Color(0xFF...),
  warningContent: Color(0xFF...),
  base100: Color(0xFF...),
  base200: Color(0xFF...),
  base300: Color(0xFF...),
  baseContent: Color(0xFF...),
)
```

Standard `ThemeExtension` methods:
```dart
// Copy with overrides
final modified = dmColors.copyWith(accent: Colors.purple);

// Lerp for animations
final interpolated = dmColors.lerp(other, 0.5);
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
