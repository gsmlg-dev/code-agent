# duskmoon_adaptive_scaffold

Responsive scaffold implementing Material Design 3 adaptive layout. Forked from `flutter_adaptive_scaffold`, versioned in sync with other DuskMoon packages.

## Installation

```yaml
dependencies:
  duskmoon_adaptive_scaffold: ^1.2.3
```

```dart
import 'package:duskmoon_adaptive_scaffold/duskmoon_adaptive_scaffold.dart';
```

## Core Classes

### AdaptiveScaffold — High-Level Adaptive Layout

Handles navigation switching automatically: `BottomNavigationBar` on small screens, `NavigationRail` on medium, extended `NavigationRail` on large, and optional `Drawer` on small desktop.

```dart
AdaptiveScaffold(
  destinations: const [
    NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
    NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
    NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
    NavigationDestination(icon: Icon(Icons.video_call), label: 'Video'),
  ],
  selectedIndex: _selectedIndex,
  onSelectedIndexChange: (index) => setState(() => _selectedIndex = index),
  smallBody: (_) => ListView.builder(
    itemCount: children.length,
    itemBuilder: (_, idx) => children[idx],
  ),
  body: (_) => GridView.count(crossAxisCount: 2, children: children),
)
```

Key constructor parameters:

```dart
const AdaptiveScaffold({
  required List<NavigationDestination> destinations, // Min 2
  int? selectedIndex,
  void Function(int)? onSelectedIndexChange,

  // Body builders per breakpoint (null = use default body)
  WidgetBuilder? smallBody,
  WidgetBuilder? body,              // Default body for medium+
  WidgetBuilder? mediumLargeBody,
  WidgetBuilder? largeBody,
  WidgetBuilder? extraLargeBody,

  // Secondary body (detail pane) per breakpoint
  WidgetBuilder? smallSecondaryBody,
  WidgetBuilder? secondaryBody,
  WidgetBuilder? mediumLargeSecondaryBody,
  WidgetBuilder? largeSecondaryBody,
  WidgetBuilder? extraLargeSecondaryBody,

  double? bodyRatio,                // e.g. 0.3 = body takes 30%
  Axis bodyOrientation,             // horizontal (default) or vertical

  // Breakpoint overrides
  Breakpoint smallBreakpoint,       // default: Breakpoints.small
  Breakpoint mediumBreakpoint,      // default: Breakpoints.medium
  Breakpoint mediumLargeBreakpoint, // default: Breakpoints.mediumLarge
  Breakpoint largeBreakpoint,       // default: Breakpoints.large
  Breakpoint extraLargeBreakpoint,  // default: Breakpoints.extraLarge

  // Navigation rail customization
  Widget? leadingUnextendedNavRail,
  Widget? leadingExtendedNavRail,
  Widget? trailingNavRail,
  double navigationRailWidth,              // default: 72
  double extendedNavigationRailWidth,      // default: 192
  double? groupAlignment,
  NavigationRailDestinationBuilder? navigationRailDestinationBuilder,

  // Collapse/expand toggle
  bool? isExtendedOverride,         // null = auto, true = always extended
  void Function(bool)? onExtendedChange,
  bool showCollapseToggle,          // default: false
  IconData collapseIcon,            // default: Icons.menu_open
  IconData expandIcon,              // default: Icons.menu

  // Drawer
  bool useDrawer,                   // default: true
  Breakpoint drawerBreakpoint,      // default: Breakpoints.smallDesktop
  PreferredSizeWidget? appBar,
  Breakpoint? appBarBreakpoint,

  // Animation
  bool internalAnimations,          // default: true
  Duration transitionDuration,      // default: Duration(seconds: 1)
})
```

### Static Helper Methods

```dart
// Convert NavigationDestination to NavigationRailDestination
AdaptiveScaffold.toRailDestination(destination)

// Build a standard NavigationRail widget
AdaptiveScaffold.standardNavigationRail(
  destinations: railDestinations,
  selectedIndex: 0,
  extended: true,
  width: 192,
  onDestinationSelected: (i) {},
)

// Build a standard BottomNavigationBar widget
AdaptiveScaffold.standardBottomNavigationBar(
  destinations: destinations,
  currentIndex: 0,
  onDestinationSelected: (i) {},
)

// Build a Material 3 staggered grid
AdaptiveScaffold.toMaterialGrid(widgets: myWidgets)
```

### Built-in Animations

```dart
AdaptiveScaffold.bottomToTop  // Slide up from bottom
AdaptiveScaffold.topToBottom  // Slide down off screen
AdaptiveScaffold.leftOutIn    // Slide in from left
AdaptiveScaffold.leftInOut    // Slide out to left
AdaptiveScaffold.rightOutIn   // Slide in from right
AdaptiveScaffold.fadeIn       // Fade in with easeInCubic
AdaptiveScaffold.fadeOut      // Fade out with easeInCubic
AdaptiveScaffold.stayOnScreen // Keep visible during transition
```

### AdaptiveLayout — Low-Level Layout API

More customizable than `AdaptiveScaffold`. Uses 6 named slots, each accepting a `SlotLayout`:

```dart
AdaptiveLayout(
  primaryNavigation: SlotLayout(
    config: {
      Breakpoints.small: SlotLayout.from(
        key: const Key('Primary Navigation Small'),
        builder: (_) => const SizedBox.shrink(),
      ),
      Breakpoints.medium: SlotLayout.from(
        key: const Key('Primary Navigation Medium'),
        inAnimation: AdaptiveScaffold.leftOutIn,
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          destinations: destinations,
          selectedIndex: selectedIndex,
        ),
      ),
      Breakpoints.mediumLarge: SlotLayout.from(
        key: const Key('Primary Navigation MediumLarge'),
        inAnimation: AdaptiveScaffold.leftOutIn,
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          extended: true,
          destinations: destinations,
          selectedIndex: selectedIndex,
        ),
      ),
    },
  ),
  body: SlotLayout(
    config: {
      Breakpoints.small: SlotLayout.from(
        key: const Key('Body Small'),
        builder: (_) => ListView.builder(
          itemCount: children.length,
          itemBuilder: (_, idx) => children[idx],
        ),
      ),
      Breakpoints.mediumAndUp: SlotLayout.from(
        key: const Key('Body Medium'),
        builder: (_) => GridView.count(
          crossAxisCount: 2,
          children: children,
        ),
      ),
    },
  ),
  secondaryBody: SlotLayout(...),
  bottomNavigation: SlotLayout(...),
  topNavigation: SlotLayout(...),
  secondaryNavigation: SlotLayout(...),
  bodyRatio: 0.5,
  bodyOrientation: Axis.horizontal,
  transitionDuration: const Duration(seconds: 1),
  internalAnimations: true,
)
```

### SlotLayout — Breakpoint-Based Widget Switching

Maps `Breakpoint`s to `SlotLayoutConfig`s. The last active breakpoint wins.

```dart
SlotLayout(
  config: {
    Breakpoints.small: SlotLayout.from(
      key: const Key('nav-small'),
      builder: (_) => const BottomNavBar(),
      inAnimation: AdaptiveScaffold.bottomToTop,
      outAnimation: AdaptiveScaffold.topToBottom,
      inDuration: const Duration(milliseconds: 500),
      outDuration: const Duration(milliseconds: 300),
      inCurve: Curves.easeOut,
      outCurve: Curves.easeIn,
    ),
    Breakpoints.mediumAndUp: SlotLayout.from(
      key: const Key('nav-medium'),
      builder: (_) => const SideNav(),
    ),
  },
)

// Pick widget programmatically
final config = SlotLayout.pickWidget(context, slotConfig);
```

### Breakpoints — Material 3 Screen Size Constants

```dart
// Size-based breakpoints
Breakpoints.small          // width: 0–600 dp
Breakpoints.medium         // width: 600–840 dp
Breakpoints.mediumLarge    // width: 840–1200 dp
Breakpoints.large          // width: 1200–1600 dp
Breakpoints.extraLarge     // width: 1600+ dp

// "And up" variants (no upper bound)
Breakpoints.smallAndUp     // width >= 0
Breakpoints.mediumAndUp    // width >= 600
Breakpoints.mediumLargeAndUp // width >= 840
Breakpoints.largeAndUp     // width >= 1200

// Platform-specific variants
Breakpoints.smallDesktop   // small + desktop only
Breakpoints.smallMobile    // small + mobile only
Breakpoints.mediumDesktop  // medium + desktop only
Breakpoints.mediumMobile   // medium + mobile only
// ... same pattern for mediumLarge, large, extraLarge

// Fallthrough
Breakpoints.standard       // Always active (lowest priority)
```

### Breakpoint Class

```dart
// Check which breakpoint is active
final bp = Breakpoint.activeBreakpointOf(context);
final bp = Breakpoint.defaultBreakpointOf(context);

// Platform checks
Breakpoint.isDesktop(context) // macOS, Windows, Linux
Breakpoint.isMobile(context)  // Android, iOS, Fuchsia

// Comparison operators
Breakpoints.medium > Breakpoints.small   // true
Breakpoints.small < Breakpoints.large    // true
bp.between(Breakpoints.medium, Breakpoints.large) // true if in range

// Custom breakpoint
const myBreakpoint = Breakpoint(
  beginWidth: 500,
  endWidth: 900,
  beginHeight: 400,
  endHeight: 700,
  platform: Breakpoint.desktop,
  spacing: 24,
  margin: 24,
  padding: 8,
  recommendedPanes: 2,
  maxPanes: 2,
);

if (myBreakpoint.isActive(context)) { ... }
```

### Material 3 Spacing Constants

```dart
kMaterialCompactSpacing     // 0.0  (small breakpoint)
kMaterialMediumAndUpSpacing // 24.0 (medium+ breakpoints)
kMaterialCompactMargin      // 16.0 (small breakpoint)
kMaterialMediumAndUpMargin  // 24.0 (medium+ breakpoints)
kMaterialPadding            // 4.0  (base padding, scaled per breakpoint)
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:duskmoon_adaptive_scaffold/duskmoon_adaptive_scaffold.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static const _pages = [InboxPage(), ArticlesPage(), ChatPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveScaffold(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.article), label: 'Articles'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        selectedIndex: _selectedIndex,
        onSelectedIndexChange: (i) => setState(() => _selectedIndex = i),
        body: (_) => _pages[_selectedIndex],
        secondaryBody: (_) => const DetailPanel(),
        bodyRatio: 0.4,
        useDrawer: true,
        showCollapseToggle: true,
        onExtendedChange: (extended) {
          // Persist user preference
        },
      ),
    );
  }
}
```
