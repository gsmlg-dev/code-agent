# duskmoon_widgets

18 adaptive widgets that automatically render Material or Cupertino variants based on platform.

## Installation

```yaml
dependencies:
  duskmoon_widgets: ^1.0.0
```

```dart
import 'package:duskmoon_widgets/duskmoon_widgets.dart';
```

## Platform Resolution (3-tier priority)

1. **Widget `platformOverride`** — per-widget override (highest priority)
2. **`DmPlatformOverride` InheritedWidget** — subtree override
3. **`Theme.of(context).platform`** — theme platform (default)

```dart
// Force all children to render Cupertino:
DmPlatformOverride(
  style: DmPlatformStyle.cupertino,
  child: MyWidgetTree(),
)

// Force a single widget to Material:
DmButton(
  platformOverride: DmPlatformStyle.material,
  onPressed: () {},
  child: const Text('Always Material'),
)
```

### DmPlatformStyle enum
- `DmPlatformStyle.material` — Google Material Design
- `DmPlatformStyle.cupertino` — Apple Cupertino

## Widget Catalog

### Buttons

#### DmButton
```dart
DmButton(
  onPressed: () {},          // null to disable
  child: const Text('Click'),
  variant: DmButtonVariant.filled, // filled | outlined | text | tonal
  platformOverride: null,    // optional
)
```
- Material: renders `FilledButton`, `OutlinedButton`, `TextButton`, or `FilledButton.tonal`
- Cupertino: renders `CupertinoButton`

#### DmFab (Floating Action Button)
```dart
// Simple FAB
DmFab(
  onPressed: () {},
  child: const Icon(Icons.add),
)

// Extended FAB (icon + label)
DmFab(
  onPressed: () {},
  icon: const Icon(Icons.add),
  label: const Text('Create'),
)
```
- Material: `FloatingActionButton` (or `.extended` when both `icon` and `label` are set)
- Cupertino: `CupertinoButton.filled` with rounded border

#### DmIconButton
```dart
DmIconButton(
  onPressed: () {},
  icon: const Icon(Icons.settings),
  tooltip: 'Settings',  // Material only
)
```

### Inputs

#### DmTextField
```dart
DmTextField(
  controller: myController,
  placeholder: 'Enter text...',
  obscureText: false,
  onChanged: (value) {},
  onSubmitted: (value) {},
  enabled: true,
  keyboardType: TextInputType.text,
  maxLines: 1,
  decoration: null,   // Material-only InputDecoration override
  prefix: null,
  suffix: null,
)
```
- Material: `TextField`
- Cupertino: `CupertinoTextField`

#### DmSwitch
```dart
DmSwitch(
  value: true,
  onChanged: (bool val) {},  // null to disable
)
```
- Material: `Switch`
- Cupertino: `CupertinoSwitch`

#### DmCheckbox
```dart
DmCheckbox(
  value: true,
  onChanged: (bool? val) {},
)
```
- Material: `Checkbox`
- Cupertino: `CupertinoCheckbox`

#### DmSlider
```dart
DmSlider(
  value: 0.5,
  onChanged: (double val) {},
  min: 0.0,
  max: 1.0,
  divisions: 10,
)
```
- Material: `Slider`
- Cupertino: `CupertinoSlider`
```

### Navigation

#### DmAppBar
```dart
DmAppBar(
  title: const Text('Page Title'),
  leading: const BackButton(),
  actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
  automaticallyImplyLeading: true,
)
```
- Material: `AppBar`
- Cupertino: `CupertinoNavigationBar`
- Implements `PreferredSizeWidget` so it works with `Scaffold(appBar:)`

#### DmTabBar
```dart
DmTabBar(
  tabs: [
    DmTab(label: 'Tab 1', icon: Icon(Icons.home)),
    DmTab(label: 'Tab 2', icon: Icon(Icons.settings)),
  ],
  selectedIndex: 0,
  onChanged: (index) {},
)
```
- Material: `TabBar` inside `DefaultTabController`
- Cupertino: `CupertinoSlidingSegmentedControl`

#### DmBottomNav
```dart
DmBottomNav(
  selectedIndex: 0,
  onDestinationSelected: (index) {},
  destinations: [
    DmNavDestination(icon: Icon(Icons.home), label: 'Home'),
    DmNavDestination(
      icon: Icon(Icons.settings),
      label: 'Settings',
      selectedIcon: Icon(Icons.settings, color: Colors.blue), // optional
    ),
  ],
)
```
- Material: `NavigationBar`
- Cupertino: `CupertinoTabBar`

#### DmDrawer
```dart
DmDrawer(
  width: 304,  // optional fixed width
  child: ListView(children: [
    DrawerHeader(child: Text('Menu')),
    ListTile(title: Text('Item 1')),
  ]),
)
```

### Layout

#### DmCard
```dart
DmCard(
  elevation: 2,
  margin: const EdgeInsets.all(8),
  padding: const EdgeInsets.all(16),
  child: Text('Card content'),
)
```
- Material: `Card`
- Cupertino: `Container` with rounded corners and box shadow

#### DmDivider
```dart
DmDivider(
  height: 16,
  thickness: 1,
  indent: 16,
  endIndent: 16,
  color: Colors.grey,
)
```

### Data Display

#### DmAvatar
```dart
DmAvatar(
  radius: 24,
  backgroundColor: Colors.blue,
  backgroundImage: NetworkImage('https://example.com/photo.jpg'),
  child: const Text('AB'),  // Fallback initials
)
```

#### DmBadge
```dart
DmBadge(
  label: '3',
  backgroundColor: Colors.red,
  textColor: Colors.white,
  child: Icon(Icons.notifications),
)
```

#### DmChip
```dart
// Deletable chip
DmChip(
  label: const Text('Flutter'),
  avatar: const Icon(Icons.code, size: 16),
  onDeleted: () {},
)

// Selectable filter chip
DmChip(
  label: const Text('Flutter'),
  selected: true,
  onSelected: (bool selected) {},
)
```

### Scaffold

#### DmScaffold — Responsive Adaptive Scaffold

Wraps `AdaptiveScaffold` from `flutter_adaptive_scaffold` with convenient defaults.

```dart
DmScaffold(
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ],
  selectedIndex: _selectedIndex,
  onSelectedIndexChange: (index) => setState(() => _selectedIndex = index),
  // Body builders per breakpoint:
  smallBody: (_) => const MobileView(),
  body: (_) => const TabletView(),
  largeBody: (_) => const DesktopView(),
  // Optional secondary body (split view):
  secondaryBody: (_) => const DetailPanel(),
  bodyRatio: 0.5,
)
```

Breakpoint constants:
```dart
DmScaffold.smallBreakpoint       // Breakpoints.small
DmScaffold.mediumBreakpoint      // Breakpoints.medium
DmScaffold.mediumLargeBreakpoint // Breakpoints.mediumLarge
DmScaffold.largeBreakpoint       // Breakpoints.large
DmScaffold.extraLargeBreakpoint  // Breakpoints.extraLarge
DmScaffold.drawerBreakpoint      // Breakpoints.smallDesktop
```

#### DmActionList — Responsive Action Buttons

```dart
DmActionList(
  size: DmActionSize.medium,  // small | medium | large
  actions: [
    DmAction(
      title: 'Edit',
      icon: Icons.edit,
      onPressed: () {},
      disabled: false,
    ),
    DmAction(
      title: 'Delete',
      icon: Icons.delete,
      onPressed: () {},
    ),
  ],
  hideDisabled: true,    // Hide disabled actions (default)
  direction: Axis.horizontal,
)
```
- `DmActionSize.small` — `PopupMenuButton` overflow menu
- `DmActionSize.medium` — icon-only `IconButton`s
- `DmActionSize.large` — `TextButton.icon` with labels

## Creating Custom Adaptive Widgets

Use the `AdaptiveWidget` mixin:

```dart
class MyWidget extends StatelessWidget with AdaptiveWidget {
  const MyWidget({super.key, this.platformOverride});

  @override
  final DmPlatformStyle? platformOverride;

  @override
  Widget build(BuildContext context) {
    return switch (resolveStyle(context)) {
      DmPlatformStyle.material => const Text('Material'),
      DmPlatformStyle.cupertino => const Text('Cupertino'),
    };
  }
}
```
