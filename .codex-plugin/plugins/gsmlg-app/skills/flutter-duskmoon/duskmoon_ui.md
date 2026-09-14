# duskmoon_ui

Umbrella package for single-import access to the DuskMoon design system.

## Installation

```yaml
dependencies:
  duskmoon_ui: ^1.6.0
```

```dart
import 'package:duskmoon_ui/duskmoon_ui.dart';
```

## Direct Exports

`packages/duskmoon_ui/lib/duskmoon_ui.dart` exports:

```dart
export 'package:duskmoon_theme/duskmoon_theme.dart';
export 'package:duskmoon_theme_bloc/duskmoon_theme_bloc.dart';
export 'package:duskmoon_widgets/duskmoon_widgets.dart';
export 'package:duskmoon_settings/duskmoon_settings.dart';
export 'package:duskmoon_feedback/duskmoon_feedback.dart';
export 'package:duskmoon_visualization/duskmoon_visualization.dart';
export 'package:duskmoon_form/duskmoon_form.dart';
export 'package:duskmoon_code_engine/duskmoon_code_engine.dart'
    hide DmCodeEditor;
export 'src/code_engine_theme.dart' show DmEditorTheme;
```

`duskmoon_adaptive_scaffold` is not directly exported by `duskmoon_ui`.
Use `package:duskmoon_adaptive_scaffold/duskmoon_adaptive_scaffold.dart`
when you need low-level adaptive scaffold APIs.

## DmEditorTheme

Use `DmEditorTheme` when code editor theme derivation needs a `ThemeData`
instead of a `BuildContext`.

```dart
final editorTheme = DmEditorTheme.fromTheme(DmThemeData.sunshine());
final lightEditor = DmEditorTheme.sunshine();
final darkEditor = DmEditorTheme.moonlight();
```

API:

```dart
abstract final class DmEditorTheme {
  static EditorTheme fromTheme(ThemeData themeData);
  static EditorTheme sunshine();
  static EditorTheme moonlight();
}
```

Use `DmCodeEditorTheme.fromContext(context)` from `duskmoon_widgets` inside
widget build methods.

## Example

```dart
MaterialApp(
  theme: DmThemeData.sunshine(),
  darkTheme: DmThemeData.moonlight(),
  home: DmScaffold(
    destinations: const [
      NavigationDestination(icon: Icon(Icons.widgets), label: 'Widgets'),
      NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
    ],
    smallBody: (_) => const Center(child: Text('Ready')),
    body: (_) => const Center(child: Text('Ready')),
  ),
)
```
