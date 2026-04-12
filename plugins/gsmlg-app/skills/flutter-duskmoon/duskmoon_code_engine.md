# duskmoon_code_engine

Pure Dart code editor engine -- ground-up port of CodeMirror 6 architecture for Flutter. Provides document model, immutable state management, incremental parsing, syntax highlighting, and an interactive editor widget. No external dependencies beyond Flutter.

## Installation

```yaml
dependencies:
  duskmoon_code_engine: ^1.4.0
```

```dart
import 'package:duskmoon_code_engine/duskmoon_code_engine.dart';
```

## CodeEditorWidget -- Main Editor Widget

```dart
CodeEditorWidget(
  initialDoc: 'print("hello")',
  language: dartLanguageSupport(),
  theme: EditorTheme.dark(),
  lineNumbers: true,
  readOnly: false,
  highlightActiveLine: true,
  autofocus: false,
  onStateChanged: (EditorState state) { /* ... */ },
  controller: null,        // Optional EditorViewController
  focusNode: null,         // Optional FocusNode
  extensions: [],          // List<Extension>
  minHeight: null,         // double?
  maxHeight: 400.0,        // double?
  padding: null,           // EdgeInsets?
  scrollPhysics: null,     // ScrollPhysics?
)
```

Parameters:
- `initialDoc` -- initial text (ignored when `controller` is provided)
- `language` -- `LanguageSupport` for syntax highlighting
- `theme` -- `EditorTheme` (defaults to `EditorTheme.light()`)
- `readOnly` -- disables user input
- `lineNumbers` -- show/hide gutter
- `highlightActiveLine` -- highlight the cursor line
- `onStateChanged` -- callback on every state change
- `controller` -- optional external `EditorViewController`
- `extensions` -- additional `Extension` instances

## EditorViewController -- Programmatic Control

```dart
final controller = EditorViewController(
  text: 'Hello, world!',
  language: dartLanguageSupport(),
  theme: EditorTheme.dark(),
  extensions: [historyExtension()],
);

// Read state
controller.state;          // EditorState
controller.document;       // Document
controller.text;           // String

// Modify
controller.text = 'new content';
controller.insertText('inserted');
controller.replaceRange(0, 5, 'replacement');
controller.setSelection(EditorSelection.cursor(10));

// Change language at runtime
controller.language = pythonLanguageSupport();

// Change theme at runtime
controller.theme = EditorTheme.light();

// Dispatch raw transactions
controller.dispatch(TransactionSpec(
  changes: ChangeSet.of(controller.document.length, [
    ChangeSpec(from: 0, to: 5, insert: 'Hi'),
  ]),
  selection: EditorSelection.cursor(2),
));

controller.dispose();
```

## Document Model

### Document -- Immutable Rope-Backed Text

```dart
final doc = Document.fromString('line one\nline two\nline three');

doc.length;                     // Total character count
doc.lineCount;                  // Number of lines
doc.lineAt(1);                  // Line (1-based) -> Line { from, to, text, number, length }
doc.lineAtOffset(5);            // Line containing character offset 5
doc.sliceString(0, 8);          // 'line one'
doc.toString();                 // Full text
doc.linesInRange(1, 2);         // Iterable<Line> for lines 1-2

// Edits produce new Documents
final newDoc = doc.replace(changeSet);
```

### ChangeSpec / ChangeSet -- Edits

```dart
// Single edit: replace range [from, to) with insert text
ChangeSpec(from: 0, to: 5, insert: 'Hello')   // Replacement
ChangeSpec(from: 10, to: 10, insert: ' world') // Pure insertion
ChangeSpec.insert(10, ' world')                 // Convenience insertion
ChangeSpec(from: 0, to: 5)                     // Pure deletion

// Build a ChangeSet from specs (must be sorted, non-overlapping)
final changes = ChangeSet.of(doc.length, [
  ChangeSpec(from: 0, to: 5, insert: 'Hello'),
  ChangeSpec(from: 10, to: 10, insert: '!'),
]);

changes.oldLength;     // Original doc length
changes.newLength;     // New doc length
changes.docChanged;    // Whether anything was modified
changes.mapPos(8);     // Map old position to new position
changes.compose(other); // Combine two sequential changesets
changes.invert(rope);  // Create inverse changeset for undo
```

## State System

### EditorState -- Immutable State Snapshot

```dart
// Create initial state
final state = EditorState.create(
  docString: 'Hello, world!',
  selection: EditorSelection.cursor(0),
  extensions: [
    dartLanguageSupport().extension,
    historyExtension(),
  ],
);

state.doc;           // Document
state.selection;     // EditorSelection

// Read facet and field values
state.facet(someFacet);
state.field(someStateField);

// Produce a new state via Transaction
final tr = state.update(TransactionSpec(
  changes: ChangeSet.of(state.doc.length, [
    ChangeSpec(from: 0, to: 5, insert: 'Hi'),
  ]),
));
final newState = tr.state;
```

### TransactionSpec -- Describing Changes

```dart
TransactionSpec(
  changes: changeSet,                       // ChangeSet?
  selection: EditorSelection.cursor(10),   // EditorSelection?
  effects: [someEffect.of(value)],         // List<StateEffect>
  annotations: [Annotation(type, value)],  // List<Annotation>
  scrollIntoView: true,                    // bool
)
```

### Transaction -- Applied Change

```dart
final tr = state.update(spec);
tr.startState;       // EditorState before
tr.state;            // EditorState after (lazily computed)
tr.changes;          // ChangeSet?
tr.selection;        // EditorSelection
tr.docChanged;       // bool
tr.selectionChanged; // bool
```

### EditorSelection / SelectionRange

```dart
// Cursor (collapsed selection)
EditorSelection.cursor(10);

// Selection range
EditorSelection.single(anchor: 5, head: 15);

// Multi-cursor
EditorSelection(ranges: [
  SelectionRange.cursor(10),
  SelectionRange(anchor: 20, head: 30),
], mainIndex: 0);

// Selection properties
selection.main;          // Primary SelectionRange
selection.ranges;        // All ranges
range.anchor;            // Anchor position
range.head;              // Head (cursor) position
range.from;              // min(anchor, head)
range.to;                // max(anchor, head)
range.isEmpty;           // anchor == head
```

## Language Support

19 built-in languages, each with a factory function returning `LanguageSupport`:

| Language | Factory |
|----------|---------|
| Dart | `dartLanguageSupport()` |
| JavaScript | `javascriptLanguageSupport()` |
| Python | `pythonLanguageSupport()` |
| HTML | `htmlLanguageSupport()` |
| CSS | `cssLanguageSupport()` |
| JSON | `jsonLanguageSupport()` |
| Markdown | `markdownLanguageSupport()` |
| Rust | `rustLanguageSupport()` |
| Go | `goLanguageSupport()` |
| YAML | `yamlLanguageSupport()` |
| C/C++ | `cLanguageSupport()` |
| Elixir | `elixirLanguageSupport()` |
| Java | `javaLanguageSupport()` |
| Kotlin | `kotlinLanguageSupport()` |
| PHP | `phpLanguageSupport()` |
| Ruby | `rubyLanguageSupport()` |
| Erlang | `erlangLanguageSupport()` |
| Swift | `swiftLanguageSupport()` |
| Zig | `zigLanguageSupport()` |

### LanguageRegistry -- Dynamic Lookup

```dart
// Lookup by name, file extension, or MIME type
final lang = LanguageRegistry.byName('dart');
final lang2 = LanguageRegistry.byExtension('.py');
final lang3 = LanguageRegistry.byMimeType('application/json');
final allNames = LanguageRegistry.names;
```

### Custom Language via StreamLanguage

```dart
final myLang = StreamLanguage([
  TokenRule(RegExp(r'//.*'), Tag.lineComment),
  TokenRule(RegExp(r'"[^"]*"'), Tag.string),
  TokenRule(RegExp(r'\b(if|else|while|for|return)\b'), Tag.keyword),
  TokenRule(RegExp(r'\d+'), Tag.number),
]);
```

## EditorTheme -- Visual Configuration

```dart
// Built-in themes
EditorTheme.light()
EditorTheme.dark()

// Custom theme
EditorTheme(
  background: Color(0xFF1E1E1E),
  foreground: Color(0xFFD4D4D4),
  gutterBackground: Color(0xFF252526),
  gutterForeground: Color(0xFF858585),
  gutterActiveForeground: Color(0xFFC6C6C6),
  selectionBackground: Color(0xFF264F78),
  cursorColor: Color(0xFFD4D4D4),
  cursorWidth: 2.0,
  lineHighlight: Color(0x0AFFFFFF),
  searchMatchBackground: Color(0x55FFCC00),
  searchActiveMatchBackground: Color(0xAAFFCC00),
  matchingBracketBackground: Color(0x3300CC00),
  matchingBracketOutline: Color(0xFF00CC00),
  scrollbarThumb: Color(0x33FFFFFF),
  scrollbarTrack: Color(0x0AFFFFFF),
  highlightStyle: myHighlightStyle,
)
```

## Syntax Highlighting -- Tag, TagStyle, HighlightStyle

### Tag -- Syntax Token Categories

Hierarchical tag system. Child tags fall back to parent styles.

| Category | Tags |
|----------|------|
| Comment | `Tag.comment`, `Tag.lineComment`, `Tag.blockComment` |
| Name | `Tag.name_`, `Tag.variableName`, `Tag.typeName`, `Tag.propertyName`, `Tag.className`, `Tag.namespace` |
| Literal | `Tag.literal`, `Tag.string`, `Tag.number`, `Tag.integer`, `Tag.float`, `Tag.bool_`, `Tag.null_`, `Tag.regexp`, `Tag.escape`, `Tag.atom`, `Tag.url`, `Tag.character` |
| Keyword | `Tag.keyword`, `Tag.self_`, `Tag.operatorKeyword`, `Tag.controlKeyword`, `Tag.definitionKeyword`, `Tag.moduleKeyword` |
| Other | `Tag.operator_`, `Tag.function_`, `Tag.punctuation`, `Tag.paren`, `Tag.brace`, `Tag.separator`, `Tag.meta`, `Tag.annotation_`, `Tag.invalid`, `Tag.definition`, `Tag.constant`, `Tag.local`, `Tag.special` |
| Content | `Tag.content`, `Tag.heading`, `Tag.emphasis`, `Tag.strong`, `Tag.link`, `Tag.strikethrough` |

### Custom HighlightStyle

```dart
final myHighlight = HighlightStyle([
  TagStyle(Tag.keyword, TextStyle(color: Color(0xFF569CD6), fontWeight: FontWeight.bold)),
  TagStyle(Tag.string, TextStyle(color: Color(0xFFCE9178))),
  TagStyle(Tag.comment, TextStyle(color: Color(0xFF6A9955), fontStyle: FontStyle.italic)),
  TagStyle(Tag.number, TextStyle(color: Color(0xFFB5CEA8))),
  TagStyle(Tag.typeName, TextStyle(color: Color(0xFF4EC9B0))),
  TagStyle(Tag.function_, TextStyle(color: Color(0xFFDCDCAA))),
  TagStyle(Tag.variableName, TextStyle(color: Color(0xFF9CDCFE))),
]);

// Default styles included:
defaultLightHighlight  // VS Code light-style colors
defaultDarkHighlight   // VS Code dark-style colors
```

## Extension / Facet System

### Extension -- Base Type (sealed)

All editor configuration is expressed as `Extension` values:
- `StateField<T>` -- per-state computed value updated on each transaction
- `Facet<Input, Output>` -- aggregated configuration (combine multiple inputs)
- `ExtensionGroup` -- bundle multiple extensions
- `PrecedenceExtension` -- wrap with priority ordering
- `Compartment` -- dynamically reconfigurable extension slot

```dart
// Group extensions
ExtensionGroup([
  historyExtension(),
  dartLanguageSupport().extension,
])

// Precedence wrapping
prec(Precedence.override_, myExtension)
```

### Precedence Levels

```dart
enum Precedence { fallback, base, extend, override_ }
```

## Lezer Parser -- Incremental Parsing

### LRParser

The `LRParser` is the core parsing engine. Language grammars compile to `GrammarData` consumed by `LRParser`.

```dart
final parser = LRParser(grammarData);
final tree = parser.parse('let x = 42;');
```

### SyntaxNode / TreeCursor

```dart
// Access the parsed syntax tree from editor state
final tree = syntaxTree(state);
final available = syntaxTreeAvailable(state);

// Walk the tree with a cursor
final cursor = tree?.cursor();
while (cursor?.next() ?? false) {
  print('${cursor!.type.name}: ${cursor.from}-${cursor.to}');
}
```

## EditorCommands -- Built-In Commands

```dart
// Cursor movement
EditorCommands.cursorCharRight(state)   // TransactionSpec?
EditorCommands.cursorCharLeft(state)
EditorCommands.cursorLineDown(state)
EditorCommands.cursorLineUp(state)
EditorCommands.cursorLineStart(state)
EditorCommands.cursorLineEnd(state)
EditorCommands.cursorDocStart(state)
EditorCommands.cursorDocEnd(state)
EditorCommands.cursorWordRight(state)
EditorCommands.cursorWordLeft(state)

// Selection
EditorCommands.selectCharRight(state)
EditorCommands.selectCharLeft(state)
EditorCommands.selectWordRight(state)
EditorCommands.selectWordLeft(state)
EditorCommands.selectAll(state)

// Editing
EditorCommands.insertText(state, 'hello')
EditorCommands.insertNewline(state)
EditorCommands.insertTab(state)
EditorCommands.deleteCharBackward(state)
EditorCommands.deleteCharForward(state)
EditorCommands.deleteSelection(state)
EditorCommands.deleteWordBackward(state)
EditorCommands.deleteWordForward(state)

// Line operations
EditorCommands.deleteLine(state)
EditorCommands.duplicateLine(state)
EditorCommands.moveLineUp(state)
EditorCommands.moveLineDown(state)

// History (requires historyExtension())
EditorCommands.undo(state)
EditorCommands.redo(state)
```

## Keymap

```dart
// Default keymap is auto-applied by CodeEditorWidget
final keymap = defaultKeymap();

// Custom key binding
KeyBinding(
  key: LogicalKeyboardKey.keyS,
  ctrl: true,
  run: (view) { /* save handler */ return true; },
)
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:duskmoon_code_engine/duskmoon_code_engine.dart';

class CodeEditorPage extends StatefulWidget {
  const CodeEditorPage({super.key});

  @override
  State<CodeEditorPage> createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {
  late final EditorViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditorViewController(
      text: 'void main() {\n  print("Hello, world!");\n}\n',
      language: dartLanguageSupport(),
      theme: EditorTheme.dark(),
      extensions: [historyExtension()],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code Editor')),
      body: CodeEditorWidget(
        controller: _controller,
        lineNumbers: true,
        highlightActiveLine: true,
        autofocus: true,
        onStateChanged: (state) {
          // React to changes
        },
      ),
    );
  }
}
```
