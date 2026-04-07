# duskmoon_settings

Platform-aware settings UI with 3 design system renderers: Material, Cupertino, and Fluent.

## Installation

```yaml
dependencies:
  duskmoon_settings: ^1.0.0
```

```dart
import 'package:duskmoon_settings/duskmoon_settings.dart';
```

## Core Widgets

### SettingsList

Top-level scrollable container. Auto-detects platform and routes to Material/Cupertino/Fluent renderer.

```dart
SettingsList(
  sections: [
    SettingsSection(
      title: const Text('General'),
      tiles: [
        SettingsTile.navigation(
          title: const Text('Language'),
          value: const Text('English'),
          leading: const Icon(Icons.language),
          onPressed: (context) {},
        ),
      ],
    ),
  ],
  platform: DevicePlatform.android, // Optional override
  shrinkWrap: false,
  physics: null,
  contentPadding: null,
)
```

### SettingsSection

Groups tiles under an optional title.

```dart
SettingsSection(
  title: const Text('Account'),
  tiles: [...],
  margin: null,
)
```

### SettingsTile (10 named constructors)

#### Simple tile
```dart
SettingsTile(
  title: const Text('About'),
  leading: const Icon(Icons.info),
  description: const Text('App version 1.0'),
  value: const Text('v1.0.0'),
  onPressed: (context) {},
  enabled: true,
)
```

#### Navigation tile (trailing chevron)
```dart
SettingsTile.navigation(
  title: const Text('Privacy Policy'),
  leading: const Icon(Icons.privacy_tip),
  onPressed: (context) => Navigator.push(...),
)
```

#### Switch tile
```dart
SettingsTile.switchTile(
  title: const Text('Dark Mode'),
  leading: const Icon(Icons.dark_mode),
  initialValue: isDarkMode,
  onToggle: (value) => setState(() => isDarkMode = value),
  activeSwitchColor: Colors.green,
)
```

#### Check tile (checkmark indicator)
```dart
SettingsTile.checkTile(
  title: const Text('Option A'),
  checked: isSelected,
  onPressed: (context) => setState(() => isSelected = !isSelected),
)
```

#### Input tile (single-line text)
```dart
SettingsTile.input(
  title: const Text('Username'),
  inputValue: username,
  onInputChanged: (value) => setState(() => username = value),
  inputHint: 'Enter username',
  inputKeyboardType: TextInputType.text,
  inputMaxLength: 30,
)
```

#### Slider tile
```dart
SettingsTile.slider(
  title: const Text('Volume'),
  sliderValue: volume,
  onSliderChanged: (value) => setState(() => volume = value),
  sliderMin: 0,
  sliderMax: 100,
  sliderDivisions: 10,
)
```

#### Select tile (dropdown/picker)
```dart
SettingsTile.select(
  title: const Text('Theme'),
  options: [
    SettingsOption(value: 'light', label: 'Light'),
    SettingsOption(value: 'dark', label: 'Dark'),
    SettingsOption(value: 'system', label: 'System', icon: Icon(Icons.auto_mode)),
  ],
  selectValue: selectedTheme,
  onSelectChanged: (value) => setState(() => selectedTheme = value),
)
```

#### Textarea tile (multi-line text)
```dart
SettingsTile.textarea(
  title: const Text('Bio'),
  textareaValue: bio,
  onTextareaChanged: (value) => setState(() => bio = value),
  textareaHint: 'Tell us about yourself',
  textareaMaxLines: 5,
  textareaMaxLength: 500,
)
```

#### Radio group tile
```dart
SettingsTile.radioGroup(
  title: const Text('Color'),
  options: [
    SettingsOption(value: 'red', label: 'Red'),
    SettingsOption(value: 'blue', label: 'Blue'),
    SettingsOption(value: 'green', label: 'Green'),
  ],
  radioValue: selectedColor,
  onRadioChanged: (value) => setState(() => selectedColor = value),
)
```

#### Checkbox group tile
```dart
SettingsTile.checkboxGroup(
  title: const Text('Notifications'),
  options: [
    SettingsOption(value: 'email', label: 'Email'),
    SettingsOption(value: 'push', label: 'Push'),
    SettingsOption(value: 'sms', label: 'SMS'),
  ],
  checkboxValues: selectedNotifications,  // Set<String>
  onCheckboxChanged: (values) => setState(() => selectedNotifications = values),
)
```

### CustomSettingsTile

For fully custom tile content:

```dart
CustomSettingsTile(
  child: MyCustomWidget(),
)
```

### SettingsTileType

The underlying enum for the tile variant — exposed publicly but rarely needed directly (prefer named constructors):

```dart
enum SettingsTileType {
  simpleTile, switchTile, navigationTile, checkTile,
  inputTile, sliderTile, selectTile, textareaTile,
  radioGroupTile, checkboxGroupTile,
}
```

## SettingsOption

Used by `select`, `radioGroup`, and `checkboxGroup` tiles:

```dart
SettingsOption(
  value: 'opt1',       // Unique identifier (passed to callbacks)
  label: 'Option One', // Display text
  icon: Icon(Icons.star), // Optional leading icon
)
```

## Platform Detection

```dart
// Auto-detect from context
final platform = DevicePlatform.fromContext(context);

// Force a specific platform
SettingsList(
  platform: DevicePlatform.iOS,  // Forces Cupertino rendering
  sections: [...],
)
```

Available platforms: `android`, `iOS`, `macOS`, `windows`, `linux`, `web`, `fuchsia`, `custom`

## Theming

`SettingsThemeData` auto-derives colors from the app's `ColorScheme` and optional `DmColorExtension`:

```dart
// Automatic (uses Theme.of(context)):
final themeData = SettingsThemeData.withContext(context, platform);

// From ColorScheme directly:
final themeData = SettingsThemeData.withColorScheme(colorScheme, platform);

// Customizable properties:
SettingsThemeData(
  settingsListBackground: Colors.white,
  settingsSectionBackground: Colors.grey[50],
  titleTextColor: Colors.blue,
  settingsTileTextColor: Colors.black,
  tileDescriptionTextColor: Colors.grey,
  tileHighlightColor: Colors.blue.withOpacity(0.1),
  leadingIconsColor: Colors.grey,
  dividerColor: Colors.grey[300],
  trailingTextColor: Colors.grey,
  inactiveTitleColor: Colors.grey[400],
  inactiveSubtitleColor: Colors.grey[300],
)
```

## Complete Example

```dart
class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  double _fontSize = 14;
  String _language = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Appearance'),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Dark Mode'),
                leading: const Icon(Icons.dark_mode),
                initialValue: _darkMode,
                onToggle: (val) => setState(() => _darkMode = val),
              ),
              SettingsTile.slider(
                title: const Text('Font Size'),
                leading: const Icon(Icons.text_fields),
                sliderValue: _fontSize,
                onSliderChanged: (val) => setState(() => _fontSize = val),
                sliderMin: 10,
                sliderMax: 24,
                sliderDivisions: 14,
              ),
            ],
          ),
          SettingsSection(
            title: const Text('General'),
            tiles: [
              SettingsTile.select(
                title: const Text('Language'),
                leading: const Icon(Icons.language),
                options: [
                  SettingsOption(value: 'en', label: 'English'),
                  SettingsOption(value: 'zh', label: 'Chinese'),
                  SettingsOption(value: 'ja', label: 'Japanese'),
                ],
                selectValue: _language,
                onSelectChanged: (val) => setState(() => _language = val ?? 'en'),
              ),
              SettingsTile.switchTile(
                title: const Text('Notifications'),
                leading: const Icon(Icons.notifications),
                initialValue: _notifications,
                onToggle: (val) => setState(() => _notifications = val),
              ),
              SettingsTile.navigation(
                title: const Text('About'),
                leading: const Icon(Icons.info),
                onPressed: (context) => Navigator.pushNamed(context, '/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```
