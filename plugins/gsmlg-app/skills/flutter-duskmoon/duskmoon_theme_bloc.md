# duskmoon_theme_bloc

BLoC for persisting theme selection and mode via SharedPreferences. **Intentionally excluded from the umbrella `duskmoon_ui` package** — opt-in for BLoC users.

## Installation

```yaml
dependencies:
  duskmoon_theme_bloc: ^1.0.0
  duskmoon_theme: ^1.0.0
  flutter_bloc: ^9.0.0
  shared_preferences: ^2.3.0
```

```dart
import 'package:duskmoon_theme_bloc/duskmoon_theme_bloc.dart';
import 'package:duskmoon_theme/duskmoon_theme.dart';
```

## API

### DmThemeBloc

Manages theme name and `ThemeMode` with automatic SharedPreferences persistence.

**SharedPreferences keys:**
- `dm_theme_name` — stores the theme name string
- `dm_theme_mode` — stores the ThemeMode name string

```dart
// Create bloc (requires SharedPreferences instance)
final prefs = await SharedPreferences.getInstance();
final themeBloc = DmThemeBloc(prefs: prefs);
```

On construction, automatically restores persisted theme name and mode.

### Events

```dart
// Change theme by name
themeBloc.add(const DmSetTheme('sunshine'));

// Change theme mode
themeBloc.add(const DmSetThemeMode(ThemeMode.dark));
themeBloc.add(const DmSetThemeMode(ThemeMode.light));
themeBloc.add(const DmSetThemeMode(ThemeMode.system));
```

### DmThemeState

```dart
// Access current state
final state = themeBloc.state;
state.themeName    // String — e.g. 'sunshine'
state.themeMode    // ThemeMode — light/dark/system

// Get the DmThemeEntry for the current theme
state.entry        // DmThemeEntry (name, light ThemeData, dark ThemeData)

// Resolve to a single ThemeData based on platform brightness
final brightness = MediaQuery.platformBrightnessOf(context);
final themeData = state.resolveTheme(brightness);
```

## Complete Setup

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duskmoon_theme/duskmoon_theme.dart';
import 'package:duskmoon_theme_bloc/duskmoon_theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DmThemeBloc(prefs: prefs),
      child: BlocBuilder<DmThemeBloc, DmThemeState>(
        builder: (context, state) {
          final entry = state.entry;
          return MaterialApp(
            theme: entry.light,
            darkTheme: entry.dark,
            themeMode: state.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Toggle theme mode
            for (final mode in ThemeMode.values)
              ElevatedButton(
                onPressed: () => context.read<DmThemeBloc>().add(
                      DmSetThemeMode(mode),
                    ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    mode.icon,
                    const SizedBox(width: 8),
                    Text(mode.title),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Theme Picker Pattern

```dart
class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DmThemeBloc, DmThemeState>(
      builder: (context, state) {
        return Column(
          children: [
            // Theme selection
            for (final theme in DmThemeData.themes)
              RadioListTile<String>(
                title: Text(theme.name),
                value: theme.name,
                groupValue: state.themeName,
                onChanged: (name) {
                  if (name != null) {
                    context.read<DmThemeBloc>().add(DmSetTheme(name));
                  }
                },
              ),

            const Divider(),

            // Mode selection
            SegmentedButton<ThemeMode>(
              segments: [
                for (final mode in ThemeMode.values)
                  ButtonSegment(
                    value: mode,
                    label: Text(mode.title),
                    icon: mode.iconOutlined,
                  ),
              ],
              selected: {state.themeMode},
              onSelectionChanged: (modes) {
                context.read<DmThemeBloc>().add(
                      DmSetThemeMode(modes.first),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}
```
