# duskmoon_theme

Codegen-driven theme package for Material 3 Flutter apps. Provides color schemes, text themes, and complete `ThemeData` factories from design tokens.

## Installation

```yaml
dependencies:
  duskmoon_theme: ^1.6.0
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
// Returns: [DmThemeEntry(name: 'duskmoon', ...), DmThemeEntry(name: 'ecotone', ...)]

// Build from a DmTheme token container:
final themeData = DmThemeData.fromDmTheme(DmTheme.sunshine);
```

`DmThemeData` builds fully configured Material 3 `ThemeData` including:
- Color scheme from generated tokens
- Material 3 type scale via `DmTextTheme`
- `DmColorExtension` with 28 semantic tokens
- Component themes: AppBar, NavigationRail, NavigationBar, Card, Divider, Input, Chip

### DmThemeEntry — Named Theme Bundle

```dart
class DmThemeEntry {
  final String name;      // 'duskmoon' or 'ecotone'
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
final light = DmTheme.sunshine;   // or DmTheme.forest
final dark = DmTheme.moonlight;   // or DmTheme.ocean

// Iterate all themes:
for (final theme in DmTheme.all) {
  print(theme.name);  // 'sunshine', 'moonlight', 'forest', or 'ocean'
  print(theme.colors.colorScheme.primary); // Color
  print(theme.colors.extension.accent);    // Color
}

// Build ThemeData from a DmTheme:
final themeData = DmThemeData.fromDmTheme(DmTheme.sunshine);
```

### DmColors — Color Token Bag

Bundles a `ColorScheme` and `DmColorExtension` into a single immutable container.

```dart
final colors = DmColors.sunshine();  // or .moonlight(), .forest(), .ocean()
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
final forestLight = DmColorScheme.forest();    // Brightness.light
final oceanDark = DmColorScheme.ocean();       // Brightness.dark

// Use standard ColorScheme accessors:
lightColors.primary
lightColors.onPrimary
lightColors.surface
lightColors.error
// ... all Material 3 color roles
```

### DmColorExtension — 28 Semantic Color Tokens

Access via `Theme.of(context).extension<DmColorExtension>()`:

```dart
final dm = Theme.of(context).extension<DmColorExtension>()!;

// Accent
dm.accent
dm.accentContent

// Neutral
dm.neutral
dm.neutralContent
dm.neutralVariant

// Surface
dm.surfaceVariant

// Semantic status — info
dm.info
dm.infoContent
dm.infoContainer
dm.onInfoContainer

// Semantic status — success
dm.success
dm.successContent
dm.successContainer
dm.onSuccessContainer

// Semantic status — warning
dm.warning
dm.warningContent
dm.warningContainer
dm.onWarningContainer

// Base surfaces (elevation levels)
dm.base100  // through dm.base900
dm.baseContent
```

Factory methods:
```dart
DmColorExtension.sunshine()   // Light tokens (duskmoon family)
DmColorExtension.moonlight()  // Dark tokens (duskmoon family)
DmColorExtension.forest()     // Light tokens (ecotone family)
DmColorExtension.ocean()      // Dark tokens (ecotone family)
```

Construct a fully custom extension (all 28 parameters required):
```dart
const DmColorExtension(
  accent: Color(0xFF...),
  accentContent: Color(0xFF...),
  neutral: Color(0xFF...),
  neutralContent: Color(0xFF...),
  neutralVariant: Color(0xFF...),
  surfaceVariant: Color(0xFF...),
  info: Color(0xFF...),
  infoContent: Color(0xFF...),
  infoContainer: Color(0xFF...),
  onInfoContainer: Color(0xFF...),
  success: Color(0xFF...),
  successContent: Color(0xFF...),
  successContainer: Color(0xFF...),
  onSuccessContainer: Color(0xFF...),
  warning: Color(0xFF...),
  warningContent: Color(0xFF...),
  warningContainer: Color(0xFF...),
  onWarningContainer: Color(0xFF...),
  base100: Color(0xFF...),
  base200: Color(0xFF...),
  base300: Color(0xFF...),
  base400: Color(0xFF...),
  base500: Color(0xFF...),
  base600: Color(0xFF...),
  base700: Color(0xFF...),
  base800: Color(0xFF...),
  base900: Color(0xFF...),
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
SunshineTokens.primary    // Duskmoon light
MoonlightTokens.primary   // Duskmoon dark
ForestTokens.primary      // Ecotone light
OceanTokens.primary       // Ecotone dark
```

## Adaptive Platform System

The theme package includes a platform resolution system that lets adaptive widgets choose between Material, Cupertino, and Fluent rendering styles. Resolution follows a four-level priority chain.

### DmPlatformStyle — Platform Enum

```dart
enum DmPlatformStyle {
  material,   // Google Material Design
  cupertino,  // Apple Cupertino
  fluent,     // Microsoft Fluent Design
}
```

### DuskmoonApp — App-Level Platform Provider

An `InheritedWidget` placed above `MaterialApp` to set a default platform style for the entire app.

```dart
DuskmoonApp(
  platformStyle: DmPlatformStyle.cupertino,
  child: MaterialApp(home: MyHome()),
);

// Query from descendants:
final style = DuskmoonApp.maybeStyleOf(context); // DmPlatformStyle? or null
```

### DmPlatformOverride — Subtree Override

An `InheritedWidget` that forces a specific platform style for its subtree, overriding `DuskmoonApp`.

```dart
DmPlatformOverride(
  style: DmPlatformStyle.material,
  child: MyWidgetSubtree(),
);

// Query from descendants:
final style = DmPlatformOverride.maybeOf(context); // DmPlatformStyle? or null
```

### AdaptiveWidget — Mixin for StatelessWidget

Add to a `StatelessWidget` to gain platform-adaptive rendering. Call `resolveStyle(context)` in `build()` to get the active `DmPlatformStyle`.

```dart
class MyButton extends StatelessWidget with AdaptiveWidget {
  const MyButton({super.key, this.platformOverride});

  @override
  final DmPlatformStyle? platformOverride; // Per-widget override (highest priority)

  @override
  Widget build(BuildContext context) {
    switch (resolveStyle(context)) {
      case DmPlatformStyle.material:
        return ElevatedButton(onPressed: () {}, child: Text('Material'));
      case DmPlatformStyle.cupertino:
        return CupertinoButton.filled(onPressed: () {}, child: Text('Cupertino'));
      case DmPlatformStyle.fluent:
        return ElevatedButton(onPressed: () {}, child: Text('Fluent'));
    }
  }
}
```

### resolvePlatformStyle — Resolution Function

Standalone function that implements the four-level priority chain:

1. `widgetOverride` parameter (per-widget)
2. Nearest `DmPlatformOverride` ancestor (subtree)
3. Nearest `DuskmoonApp` ancestor (app-level)
4. Platform default from `Theme.of(context).platform` (iOS/macOS -> cupertino, Windows -> fluent, others -> material)

```dart
final style = resolvePlatformStyle(context, widgetOverride: DmPlatformStyle.material);
```

### Resolution Priority Example

```dart
// App sets cupertino globally
DuskmoonApp(
  platformStyle: DmPlatformStyle.cupertino,
  child: MaterialApp(
    home: Column(children: [
      MyButton(),  // -> cupertino (from DuskmoonApp)

      DmPlatformOverride(
        style: DmPlatformStyle.material,
        child: MyButton(),  // -> material (from DmPlatformOverride)
      ),

      MyButton(platformOverride: DmPlatformStyle.fluent),  // -> fluent (per-widget)
    ]),
  ),
);
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
