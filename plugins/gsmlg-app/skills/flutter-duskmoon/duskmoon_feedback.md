# duskmoon_feedback

Adaptive feedback helpers: dialogs, snackbars, toasts, bottom sheets, and fullscreen dialogs.

## Installation

```yaml
dependencies:
  duskmoon_feedback: ^1.4.0
```

```dart
import 'package:duskmoon_feedback/duskmoon_feedback.dart';
```

## Dialogs

### showDmDialog — Adaptive Alert Dialog

Uses `AlertDialog.adaptive` (Material on Android/Windows/Linux, Cupertino on iOS/macOS).

```dart
showDmDialog<bool>(
  context: context,
  title: const Text('Confirm'),
  content: const Text('Are you sure you want to delete?'),
  actions: [
    DmDialogAction(
      onPressed: (ctx) => Navigator.of(ctx).pop(false),
      child: const Text('Cancel'),
    ),
    DmDialogAction(
      onPressed: (ctx) => Navigator.of(ctx).pop(true),
      child: const Text('Delete'),
    ),
  ],
);
```

### DmDialogAction — Adaptive Action Button

Platform-switches between `TextButton` (Material) and `CupertinoDialogAction` (iOS/macOS):

```dart
DmDialogAction(
  onPressed: (BuildContext context) {
    Navigator.of(context).pop();
  },
  child: const Text('OK'),
)
```

### showDmFullscreenDialog

Pushes a fullscreen dialog with close button in the app bar:

```dart
showDmFullscreenDialog(
  context: context,
  title: const Text('Edit Profile'),
  builder: (context) => const ProfileEditor(),
);
```

## Snackbars

### showDmSnackbar — Basic Snackbar

```dart
showDmSnackbar(
  context: context,
  message: const Text('Item saved'),
  duration: const Duration(seconds: 5),
  showCloseIcon: false,
  actionLabel: 'VIEW',
  onActionPressed: () => Navigator.pushNamed(context, '/item'),
);
```

### showDmUndoSnackbar — Snackbar with Undo

```dart
showDmUndoSnackbar(
  context: context,
  message: const Text('Item deleted'),
  onUndoPressed: () => restoreItem(),
  undoLabel: 'Undo',        // Customizable for localization
  duration: const Duration(seconds: 5),
  showCloseIcon: true,
);
```

## Toasts

### showDmSuccessToast — Success Toast

Styled with primary color, checkmark icon, title + message layout:

```dart
showDmSuccessToast(
  context: context,
  message: 'Profile updated successfully',
  title: 'Success',         // Customizable for localization
  duration: const Duration(seconds: 5),
  showCloseIcon: false,
  actionLabel: 'VIEW',
  onActionPressed: () {},
);
```

### showDmErrorToast — Persistent Error Toast

Styled with error color, error icon, selectable message text. **Always persists until manually dismissed** — duration and close icon are not configurable (hardcoded to infinite duration with close icon shown):

```dart
showDmErrorToast(
  context: context,
  message: 'Failed to save: Connection timeout',
  title: 'Error',           // Customizable for localization
  actionLabel: 'RETRY',
  onActionPressed: () => retry(),
);
```

## Bottom Sheets

### showDmBottomSheetActionList

Shows a bottom sheet with a list of action buttons:

```dart
showDmBottomSheetActionList(
  context: context,
  actions: [
    DmBottomSheetAction(
      title: const Text('Take Photo'),
      onTap: () => takePhoto(),
      style: null,  // Optional ButtonStyle override
    ),
    DmBottomSheetAction(
      title: const Text('Choose from Gallery'),
      onTap: () => pickFromGallery(),
    ),
    DmBottomSheetAction(
      title: const Text('Cancel'),
      onTap: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
      ),
    ),
  ],
  showBackdrop: true,  // Semi-transparent overlay; tap outside to dismiss
);
```

## Type Note: message parameter

`message` is typed differently between helpers:
- **Snackbars** (`showDmSnackbar`, `showDmUndoSnackbar`): `message` is `Widget` — pass `const Text('...')`
- **Toasts** (`showDmSuccessToast`, `showDmErrorToast`): `message` is `String` — pass a plain string

## Helpers

### dmScaffoldMessengerKey

Global key for accessing `ScaffoldMessengerState` directly (useful for showing snackbars without a `BuildContext`):

```dart
MaterialApp(
  scaffoldMessengerKey: dmScaffoldMessengerKey,
  // ...
);

// Later, show snackbar without context:
dmScaffoldMessengerKey.currentState?.showSnackBar(
  SnackBar(content: Text('Hello')),
);
```

### getDmWidgetSize

Returns the rendered size of a widget by its `GlobalKey`:

```dart
final key = GlobalKey();
// ... use key on a widget ...
final size = getDmWidgetSize(key); // Size? or null if not rendered
```

## Complete Example

```dart
class FeedbackDemoPage extends StatelessWidget {
  const FeedbackDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => showDmDialog(
                context: context,
                title: const Text('Hello'),
                content: const Text('This is an adaptive dialog'),
                actions: [
                  DmDialogAction(
                    onPressed: (ctx) => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
              child: const Text('Show Dialog'),
            ),
            ElevatedButton(
              onPressed: () => showDmSuccessToast(
                context: context,
                message: 'Operation completed',
              ),
              child: const Text('Success Toast'),
            ),
            ElevatedButton(
              onPressed: () => showDmErrorToast(
                context: context,
                message: 'Something went wrong',
              ),
              child: const Text('Error Toast'),
            ),
            ElevatedButton(
              onPressed: () => showDmUndoSnackbar(
                context: context,
                message: const Text('Item removed'),
                onUndoPressed: () {},
              ),
              child: const Text('Undo Snackbar'),
            ),
          ],
        ),
      ),
    );
  }
}
```
