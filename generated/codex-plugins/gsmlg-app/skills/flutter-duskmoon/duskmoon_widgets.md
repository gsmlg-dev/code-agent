# duskmoon_widgets

Adaptive widgets plus Markdown, Chat, and Code Editor widgets. The adaptive widgets automatically render Material, Cupertino, or Fluent variants based on platform.

## Installation

```yaml
dependencies:
  duskmoon_widgets: ^1.6.0
```

```dart
import 'package:duskmoon_widgets/duskmoon_widgets.dart';
```

## Platform Resolution (4-tier priority)

1. **Widget `platformOverride`** — per-widget override (highest priority)
2. **`DmPlatformOverride` InheritedWidget** — subtree override
3. **`DuskmoonApp` ancestor** — app-level platform style
4. **`Theme.of(context).platform`** — theme platform (default)

Windows defaults to `fluent`.

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

### DuskmoonApp

App-level InheritedWidget that sets the default platform style for all descendant Dm* widgets.

```dart
DuskmoonApp(
  platformStyle: DmPlatformStyle.cupertino, // or null for auto-detect
  child: MaterialApp(...),
)
```

Static method: `DuskmoonApp.maybeStyleOf(context)` returns `DmPlatformStyle?`.

### DmPlatformStyle enum
- `DmPlatformStyle.material` — Google Material Design
- `DmPlatformStyle.cupertino` — Apple Cupertino
- `DmPlatformStyle.fluent` — Microsoft Fluent Design

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

#### DmDropdown

Adaptive dropdown that renders Material `DropdownButton`, Cupertino picker modal, or Fluent `ComboBox`.

```dart
DmDropdown<String>(
  items: [
    DmDropdownItem(value: 'a', child: Text('Option A')),
    DmDropdownItem(value: 'b', child: Text('Option B')),
  ],
  value: 'a',
  onChanged: (value) {},
  placeholder: 'Select...',
  isExpanded: true,
  platformOverride: null,
)
```

`DmDropdownItem<T>` has `value` (required `T`) and `child` (required `Widget`).

- Material: `DropdownButton`
- Cupertino: button that opens a `CupertinoPicker` modal
- Fluent: `ComboBox`

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
> **Note:** `DmChip` always renders Material widgets (`FilterChip`/`Chip`) regardless of platform — it does not have a Cupertino variant.

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
  appBarBreakpoint: null,  // Breakpoint above which app bar is shown (optional)
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

## Markdown

### DmMarkdown

Read-only markdown renderer with GFM, KaTeX, optional Mermaid, and syntax highlighting support.

```dart
// From a string
DmMarkdown(
  data: '# Hello\n\nWorld',
  selectable: true,
  controller: DmMarkdownScrollController(),
  config: DmMarkdownConfig(
    enableGfm: true,
    enableKatex: true,
    enableMermaid: false,
    enableCodeHighlight: true,
  ),
  onLinkTap: (url, title) {},
  onImageTap: (src, alt) {},
  imageErrorBuilder: (src, alt) => const Icon(Icons.broken_image),
)

// From pre-parsed nodes
DmMarkdown(
  nodes: parsedNodes,
)

// From a stream (for LLM output)
DmMarkdown(
  stream: llmOutputStream,
)
```

Additional props: `shrinkWrap`, `physics`, `padding`, `themeData`.

#### DmMarkdownConfig

Configuration for markdown rendering features.

```dart
DmMarkdownConfig(
  enableGfm: true,          // GitHub Flavored Markdown
  enableKatex: true,         // LaTeX math rendering
  enableMermaid: false,      // Mermaid diagram rendering
  enableCodeHighlight: true, // Syntax highlighting in code blocks
  codeTheme: 'github',       // String theme name; null auto-selects
  blockBuilders: {...},      // Custom block builders
  inlineBuilders: {...},     // Custom inline builders
)
```

#### DmMarkdownScrollController

Controller for scroll-to-anchor navigation within rendered markdown.

### DmMarkdownInput

Markdown editor with write/preview tabs.

```dart
DmMarkdownInput(
  controller: DmMarkdownInputController(),
  initialValue: '# Draft',
  config: DmMarkdownConfig(),
  initialTab: DmMarkdownTab.write,
  onChanged: (value) {},
  onTabChanged: (tab) {},
  showLineNumbers: true,
  maxLines: null,
  minLines: 10,
  readOnly: false,
  enabled: true,
  tabLabelWrite: 'Write',
  tabLabelPreview: 'Preview',
  showPreview: true,         // false hides the preview tab entirely
  onLinkTap: (url, title) {}, // link tap callback in preview mode
  decoration: InputDecoration(...),
  bottomLeft: Text('Markdown'),
  bottomRight: IconButton(icon: Icon(Icons.send), onPressed: () {}),
  bottom: null,              // full custom bottom bar; overrides left/right
)
```

#### DmMarkdownInputController

Controller for `DmMarkdownInput` with helper methods:
`wrapSelection()`, `insertAtCursor()`, `toggleLinePrefix()`,
`insertCodeFence()`, `insertLink()`, and `appendMarkdown()`.

#### DmMarkdownTab

Enum for the active tab: `DmMarkdownTab.write`, `DmMarkdownTab.preview`.

## Chat

LLM-style chat primitives and composed view. Text blocks render markdown, and
streaming blocks use `Stream<String>` chunks.

```dart
final messages = <DmChatMessage>[
  const DmChatMessage(
    id: 'u1',
    role: DmChatRole.user,
    blocks: [DmChatTextBlock(text: 'Summarize this **markdown**.')],
  ),
  DmChatMessage(
    id: 'a1',
    role: DmChatRole.assistant,
    status: DmChatMessageStatus.complete,
    blocks: [
      DmChatThinkingBlock(text: 'Checked the request.', elapsed: Duration(seconds: 2)),
      DmChatToolCallBlock(
        id: 'tool-1',
        name: 'search_docs',
        input: {'query': 'markdown'},
        output: {'matches': 3},
        status: DmChatToolCallStatus.done,
      ),
      DmChatTextBlock(text: 'Here is the summary.'),
    ],
  ),
];

DmChatView(
  messages: messages,
  onSend: (markdown, attachments) {},
  onAttach: (picked) {},
  pendingAttachments: const [],
  inputPlaceholder: 'Message...',
  inputLeading: const Text('Demo'),
  avatarBuilder: (context, message) => switch (message.role) {
    DmChatRole.user => const DmAvatar(child: Text('U')),
    DmChatRole.assistant => const DmAvatar(child: Icon(Icons.auto_awesome)),
    DmChatRole.system => null,
  },
  headerBuilder: (context, message) => Text(message.role.name),
)
```

Core models:

```dart
enum DmChatRole { user, assistant, system }
enum DmChatMessageStatus { pending, streaming, complete, error }
enum DmChatToolCallStatus { pending, running, done, error }
enum DmChatAttachmentStatus { idle, uploading, done, error }

class DmChatMessage {
  const DmChatMessage({
    required String id,
    required DmChatRole role,
    required List<DmChatBlock> blocks,
    DmChatMessageStatus status = DmChatMessageStatus.complete,
    Object? error,
    DateTime? createdAt,
  });
}

sealed class DmChatBlock {}
class DmChatTextBlock extends DmChatBlock { const DmChatTextBlock({String? text, Stream<String>? stream}); }
class DmChatThinkingBlock extends DmChatBlock { const DmChatThinkingBlock({String? text, Stream<String>? stream, Duration? elapsed}); }
class DmChatToolCallBlock extends DmChatBlock { const DmChatToolCallBlock({required String id, required String name, Object? input, Object? output, DmChatToolCallStatus status, String? errorMessage}); }
class DmChatAttachmentBlock extends DmChatBlock { const DmChatAttachmentBlock({required List<DmChatAttachment> attachments}); }
class DmChatCustomBlock extends DmChatBlock { const DmChatCustomBlock({required String kind, Object? data}); }
```

Composer and view:

```dart
typedef DmChatSendCallback = void Function(String markdown, List<DmChatAttachment> attachments);
typedef DmChatRetryCallback = void Function(DmChatMessage message);

enum DmChatSubmitShortcut { cmdEnter, enter }

DmChatInput(
  onSend: (markdown, attachments) {},
  onStop: () {},
  onAttach: (picked) {},
  pendingAttachments: attachments,
  onRemoveAttachment: (attachment) {},
  placeholder: 'Message...',
  leading: selector,
  trailing: status,
  minLines: 1,
  maxLines: 8,
  submitShortcut: DmChatSubmitShortcut.cmdEnter,
)
```

Attachments:

```dart
class DmChatAttachment {
  const DmChatAttachment({
    required String id,
    required String name,
    int? sizeBytes,
    String? mimeType,
    Uri? url,
    Uint8List? bytes,
    DmChatAttachmentStatus status = DmChatAttachmentStatus.idle,
    double? uploadProgress,
    String? errorMessage,
  });
}

abstract class DmChatUploadAdapter {
  Stream<DmChatAttachment> upload(DmChatAttachment local);
  Future<void> cancel(String attachmentId);
}
```

Public block renderers: `DmChatThinkingBlockView`,
`DmChatToolCallBlockView`, and `DmChatAttachmentBlockView`.
Customize colors, spacing, block builders, and fallback avatars with
`DmChatTheme.withContext(context)` or a `ThemeExtension<DmChatTheme>`.

## Code Editor

### DmCodeEditor

Code editor widget integrating `duskmoon_code_engine`. Supports 19 languages by name string.

```dart
DmCodeEditor(
  initialDoc: 'void main() {}',
  language: 'dart',
  theme: DmCodeEditorTheme.fromContext(context),
  readOnly: false,
  lineNumbers: true,
  highlightActiveLine: true,
  onChanged: (String doc) {},
  onStateChanged: (EditorState state) {},
  controller: EditorViewController(),
  focusNode: FocusNode(),
  autofocus: false,
  minHeight: 200,
  maxHeight: 600,
  padding: EdgeInsets.all(8),
  scrollPhysics: ClampingScrollPhysics(),
)
```

Supported languages: Dart, JavaScript, TypeScript, Python, HTML, CSS, JSON, Markdown, Rust, Go, YAML, C, C++, Elixir, Java, Kotlin, PHP, Ruby, Erlang, Swift, Zig.

### DmCodeEditorTheme

`abstract final class` with a static factory for deriving an editor theme from the current build context.

```dart
final theme = DmCodeEditorTheme.fromContext(context); // returns EditorTheme
```

### Re-exports

The following are re-exported from `duskmoon_code_engine`:
- `EditorViewController` — controller for programmatic editor manipulation
- `EditorState` — immutable editor state snapshot
- `EditorTheme` — theme data for the code editor

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
      DmPlatformStyle.fluent => const Text('Fluent'),
    };
  }
}
```
