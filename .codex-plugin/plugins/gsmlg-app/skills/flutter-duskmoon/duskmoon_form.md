# duskmoon_form

BLoC-based form state management with adaptive form widgets. Merges `form_bloc` and `flutter_form_bloc` into a single DuskMoon package.

## Installation

```yaml
dependencies:
  duskmoon_form: ^1.6.0
```

```dart
import 'package:duskmoon_form/duskmoon_form.dart';
```

Also available via the umbrella:

```dart
import 'package:duskmoon_ui/duskmoon_ui.dart';
```

## Field BLoCs

9 field types for managing form input state:

### TextFieldBloc

```dart
final email = TextFieldBloc(
  name: 'email',
  validators: [FieldBlocValidators.required, FieldBlocValidators.email],
);

final password = TextFieldBloc(
  validators: [FieldBlocValidators.required, FieldBlocValidators.passwordMin6Chars],
  asyncValidatorDebounceTime: const Duration(milliseconds: 500),
);
```

Properties: `value` (String), `valueToInt`, `valueToDouble`.

### BooleanFieldBloc

```dart
final acceptTerms = BooleanFieldBloc(
  validators: [FieldBlocValidators.required],
);
```

Value is `bool`, defaults to `false`.

### SelectFieldBloc

```dart
final country = SelectFieldBloc<String, dynamic>(
  items: ['US', 'UK', 'DE', 'JP'],
  validators: [FieldBlocValidators.required],
);
```

Methods: `updateItems()`, `addItem()`, `removeItem()`.

### MultiSelectFieldBloc

```dart
final tags = MultiSelectFieldBloc<String, dynamic>(
  items: ['flutter', 'dart', 'bloc'],
);
```

Methods: `select()`, `deselect()`, `updateItems()`, `addItem()`, `removeItem()`.

### InputFieldBloc

Generic field for any value type:

```dart
final rating = InputFieldBloc<double, dynamic>(initialValue: 0.5);
final birthday = InputFieldBloc<DateTime?, dynamic>(initialValue: null);
```

### GroupFieldBloc

Composite field grouping:

```dart
final address = GroupFieldBloc(
  name: 'address',
  fieldBlocs: [street, city, zip],
);
```

### ListFieldBloc

Dynamic field arrays:

```dart
final phoneNumbers = ListFieldBloc<TextFieldBloc, dynamic>(
  name: 'phones',
  fieldBlocs: [TextFieldBloc(name: 'phone_0')],
);

phoneNumbers.addFieldBloc(TextFieldBloc(name: 'phone_1'));
phoneNumbers.removeFieldBlocAt(0);
```

Methods: `addFieldBloc()`, `addFieldBlocs()`, `removeFieldBlocAt()`, `removeFieldBloc()`, `insertFieldBloc()`, `updateFieldBlocs()`, `clearFieldBlocs()`.

### MarkdownFieldBloc

Extends `InputFieldBloc` for markdown text with write/preview tab state:

```dart
final notes = MarkdownFieldBloc<dynamic>(
  initialValue: '# Hello',
  initialTab: DmMarkdownTab.write,
);
```

Use `initialTab` to control the default active tab and `updateTab(tab)` to
change tab state.

### CodeEditorFieldBloc

Extends `InputFieldBloc` for source code with language/syntax highlighting state:

```dart
final code = CodeEditorFieldBloc<dynamic>(
  initialValue: 'void main() {}',
  initialLanguage: 'dart',
);
```

Use `updateLanguage(language)` to change syntax highlighting at runtime.
Pass `null` to clear the language.

Methods: `updateLanguage(String?)` to change syntax highlighting language at runtime.

## FormBloc

Main form management class. Subclass it, add fields in constructor, override `onSubmitting()`:

```dart
class LoginFormBloc extends FormBloc<String, String> {
  final email = TextFieldBloc(
    validators: [FieldBlocValidators.required, FieldBlocValidators.email],
  );
  final password = TextFieldBloc(
    validators: [FieldBlocValidators.required, FieldBlocValidators.passwordMin6Chars],
  );

  LoginFormBloc() {
    addFieldBlocs(fieldBlocs: [email, password]);
  }

  @override
  void onSubmitting() async {
    try {
      await authService.login(email.value, password.value);
      emitSuccess(successResponse: 'Logged in!');
    } catch (e) {
      emitFailure(failureResponse: e.toString());
    }
  }
}
```

### FormBloc constructor

```dart
FormBloc({
  bool isLoading = false,      // Start in loading state
  bool autoValidate = true,    // Validate on value change
  bool isEditing = false,      // Edit mode flag
})
```

### State emission methods

- `emitLoading({double progress})` / `emitLoaded()` / `emitLoadFailed({F?})`
- `emitSubmitting({double? progress})` / `emitSuccess({S?, bool? canSubmitAgain, bool? isEditing})` / `emitFailure({F?})`
- `emitSubmissionCancelled()` / `emitDeleteFailed({F?})` / `emitDeleteSuccessful({S?})`
- `emitUpdatingFields({double? progress})`

### Field management methods

```dart
addFieldBlocs(fieldBlocs: [...]);        // Add multiple field blocs
addFieldBloc(step: 0, fieldBloc: f);     // Add single field (specific step)
removeFieldBloc(fieldBloc: f);           // Remove a single field
removeFieldBlocs(fieldBlocs: [...]);     // Remove multiple fields
clear();                                 // Clear all field blocs
```

### Lifecycle methods

```dart
reload()             // Calls onLoading() and sets state to FormBlocLoading
delete()             // Calls onDeleting() and sets state to FormBlocDeleting
cancelSubmission()   // Calls onCancelingSubmission() when form is submitting
```

Override these callbacks in your subclass:
```dart
@override void onLoading() async { ... }
@override void onDeleting() async { ... }
@override void onCancelingSubmission() async { ... }
```

### Utility methods

```dart
isValuesChanged({int? step})   // true if any field value changed from initial
hasInitialValues({int? step})  // true if all fields have initial values
hasUpdatedValues({int? step})  // true if any field has updated values
```

### State properties

- `state.canSubmit` — `bool`, whether the form is currently submittable
- `state.fieldBlocs([int? step])` — field blocs map for a given step
- `state.flatFieldBlocs([int? step])` — flat list of all field blocs

### Multi-step forms

```dart
class WizardFormBloc extends FormBloc<String, String> {
  WizardFormBloc() {
    addFieldBloc(step: 0, fieldBloc: nameField);
    addFieldBloc(step: 1, fieldBloc: emailField);
    addFieldBloc(step: 2, fieldBloc: passwordField);
  }
}
```

State provides: `currentStep`, `numberOfSteps`, `isLastStep`, `isFirstStep`, `notValidStep`.
Methods: `previousStep()`, `updateCurrentStep(int)`.

### 12 FormBlocState subclasses

`FormBlocLoading`, `FormBlocLoaded`, `FormBlocLoadFailed`, `FormBlocSubmitting`, `FormBlocSuccess`, `FormBlocFailure`, `FormBlocSubmissionCancelled`, `FormBlocSubmissionFailed`, `FormBlocDeleting`, `FormBlocDeleteFailed`, `FormBlocDeleteSuccessful`, `FormBlocUpdatingFields`.

## Validators

```dart
FieldBlocValidators.required      // Non-null, non-empty, non-false
FieldBlocValidators.email          // Email format
FieldBlocValidators.passwordMin6Chars  // Min 6 characters
FieldBlocValidators.confirmPassword(passwordFieldBloc)  // Match password
```

Custom validators:

```dart
final username = TextFieldBloc(
  validators: [(value) => value.length < 3 ? 'Min 3 characters' : null],
  asyncValidators: [(value) async {
    final exists = await api.checkUsername(value);
    return exists ? 'Username taken' : null;
  }],
  asyncValidatorDebounceTime: const Duration(milliseconds: 300),
);
```

Error constants: `FieldBlocValidatorsErrors.required`, `.email`, `.passwordMin6Chars`, `.confirmPassword`.

## Widget Builders

### DmTextFieldBlocBuilder

```dart
DmTextFieldBlocBuilder(
  textFieldBloc: formBloc.email,
  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
  keyboardType: TextInputType.emailAddress,
  suffixButton: SuffixButton.clearText,
)
```

Supports type-ahead suggestions via `suggestionsBoxDecoration`, `debounceDuration`, `loadingBuilder`, `noItemsFoundBuilder`.

### DmCheckboxFieldBlocBuilder

```dart
DmCheckboxFieldBlocBuilder(
  booleanFieldBloc: formBloc.acceptTerms,
  body: const Text('I accept the terms'),
)
```

### DmSwitchFieldBlocBuilder

```dart
DmSwitchFieldBlocBuilder(
  booleanFieldBloc: formBloc.notifications,
  body: const Text('Enable notifications'),
)
```

### DmDropdownFieldBlocBuilder

```dart
DmDropdownFieldBlocBuilder<String>(
  selectFieldBloc: formBloc.country,
  decoration: const InputDecoration(labelText: 'Country'),
  itemBuilder: (context, value) => FieldItem(child: Text(value)),
)
```

### DmSliderFieldBlocBuilder

```dart
DmSliderFieldBlocBuilder(
  inputFieldBloc: formBloc.rating,
  decoration: const InputDecoration(labelText: 'Rating'),
  min: 0.0,
  max: 5.0,
  divisions: 10,
  labelBuilder: (context, value) => value.toStringAsFixed(1),
)
```

### DmDateTimeFieldBlocBuilder

```dart
DmDateTimeFieldBlocBuilder(
  dateTimeFieldBloc: formBloc.birthday,
  format: DateFormat('yyyy-MM-dd'),
  initialDate: DateTime.now(),
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  decoration: const InputDecoration(labelText: 'Birthday'),
)
```

### DmTimeFieldBlocBuilder

```dart
DmTimeFieldBlocBuilder(
  dateTimeFieldBloc: formBloc.meetingTime,
  format: DateFormat.Hm(),
  initialTime: TimeOfDay.now(),
  decoration: const InputDecoration(labelText: 'Time'),
)
```

### DmChoiceChipFieldBlocBuilder

```dart
DmChoiceChipFieldBlocBuilder<String>(
  selectFieldBloc: formBloc.size,
  itemBuilder: (context, value) => ChipFieldItem(label: Text(value)),
)
```

### DmFilterChipFieldBlocBuilder

```dart
DmFilterChipFieldBlocBuilder<String>(
  multiSelectFieldBloc: formBloc.colors,
  itemBuilder: (context, value) => ChipFieldItem(label: Text(value)),
)
```

### DmCheckboxGroupFieldBlocBuilder

```dart
DmCheckboxGroupFieldBlocBuilder<String>(
  multiSelectFieldBloc: formBloc.toppings,
  itemBuilder: (context, value) => FieldItem(child: Text(value)),
)
```

### DmRadioButtonGroupFieldBlocBuilder

```dart
DmRadioButtonGroupFieldBlocBuilder<String>(
  selectFieldBloc: formBloc.priority,
  itemBuilder: (context, value) => FieldItem(child: Text(value)),
)
```

### DmMarkdownFieldBlocBuilder

```dart
DmMarkdownFieldBlocBuilder(
  markdownFieldBloc: formBloc.notes,
  config: const DmMarkdownConfig(),
  tabLabelWrite: 'Write',
  tabLabelPreview: 'Preview',
  showLineNumbers: false,
  maxLines: null,
  minLines: 10,
  onLinkTap: (url, title) {},
  decoration: const InputDecoration(labelText: 'Notes'),
)
```

### DmCodeEditorFieldBlocBuilder

```dart
DmCodeEditorFieldBlocBuilder(
  codeEditorFieldBloc: formBloc.code,
  lineNumbers: true,
  highlightActiveLine: true,
  theme: null, // EditorTheme? — auto-derived from DmFormTheme or context
  minHeight: null,
  maxHeight: null,
  editorPadding: null,
  scrollPhysics: null,
)
```

### DmCanShowFieldBlocBuilder

Conditionally shows or hides a field based on its `canShow` state:

```dart
DmCanShowFieldBlocBuilder(
  fieldBloc: formBloc.addressField,
  animate: true,  // animated show/hide (default: true)
  builder: (context, canShow) {
    return canShow
        ? DmTextFieldBlocBuilder(textFieldBloc: formBloc.addressField, ...)
        : const SizedBox.shrink();
  },
)
```

## Form Listener

React to form state changes:

```dart
DmFormBlocListener<LoginFormBloc, String, String>(
  onSubmitting: (context, state) => showDialog(...loading...),
  onSuccess: (context, state) {
    Navigator.of(context).pop(); // dismiss loading
    Navigator.of(context).pushReplacementNamed('/home');
  },
  onFailure: (context, state) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.failureResponse ?? 'Error')),
    );
  },
  child: formContent,
)
```

## Stepper Form

Multi-step wizard:

```dart
DmStepperFormBlocBuilder<WizardFormBloc>(
  formBloc: formBloc,
  type: StepperType.horizontal,
  stepsBuilder: (formBloc) => [
    FormBlocStep(title: const Text('Name'), content: nameFields),
    FormBlocStep(title: const Text('Contact'), content: contactFields),
    FormBlocStep(title: const Text('Confirm'), content: confirmFields),
  ],
)
```

`FormBlocStep` constructor:
```dart
const FormBlocStep({
  required Widget title,
  Widget? subtitle,
  required Widget content,
  StepState state = StepState.indexed,
  bool? isActive,
})
```

## Theme

### DmFormTheme

```dart
DmFormThemeProvider(
  theme: DmFormTheme(
    textStyle: const TextStyle(fontSize: 16),
    padding: const EdgeInsets.symmetric(vertical: 12),
    textTheme: const TextFieldTheme(
      decorationTheme: InputDecorationThemeData(border: OutlineInputBorder()),
    ),
    checkboxTheme: const CheckboxFieldTheme(),
    switchTheme: const SwitchFieldTheme(),
    dropdownTheme: const DropdownFieldTheme(),
    sliderTheme: const SliderFieldTheme(),
    dateTimeTheme: const DateTimeFieldTheme(),
    choiceChipTheme: const ChoiceChipFieldTheme(),
    filterChipTheme: const FilterChipFieldTheme(),
    radioTheme: const RadioFieldTheme(),
    clearSuffixButtonTheme: const ClearSuffixButtonTheme(),
    obscureSuffixButtonTheme: const ObscureSuffixButtonTheme(),
    scrollableFormTheme: const ScrollableFormTheme(),
    markdownTheme: const MarkdownFieldTheme(),
    codeEditorTheme: const CodeEditorFieldTheme(),
  ),
  child: yourForm,
)
```

Access: `DmFormTheme.of(context)`.

Field theme classes: `TextFieldTheme`, `CheckboxFieldTheme`, `SwitchFieldTheme`, `DropdownFieldTheme`, `SliderFieldTheme`, `DateTimeFieldTheme`, `ChoiceChipFieldTheme`, `FilterChipFieldTheme`, `RadioFieldTheme`, `ClearSuffixButtonTheme`, `ObscureSuffixButtonTheme`, `ScrollableFormTheme`, `MarkdownFieldTheme`, `CodeEditorFieldTheme`.

## Scrollable Form Support

Auto-scroll to first invalid field on submission:

```dart
DmScrollableFormBlocManager(
  formBloc: formBloc,
  child: ListView(children: [
    DmScrollableFieldBlocTarget(
      singleFieldBloc: formBloc.email,
      child: DmTextFieldBlocBuilder(textFieldBloc: formBloc.email, ...),
    ),
    DmScrollableFieldBlocTarget(
      singleFieldBloc: formBloc.password,
      child: DmTextFieldBlocBuilder(textFieldBloc: formBloc.password, ...),
    ),
  ]),
)
```

## FormBlocObserver

Debug observer for filtering BLoC events:

```dart
Bloc.observer = FormBlocObserver(
  notifyOnFieldBlocCreate: false,
  notifyOnFieldBlocChange: true,
  notifyOnFieldBlocError: true,
  notifyOnFieldBlocClose: false,
  notifyOnFormBlocCreate: false,
  notifyOnFormBlocChange: false,
  notifyOnFormBlocError: true,
  notifyOnFormBlocClose: false,
  child: yourExistingObserver,
);
```

## Complete Example

```dart
class RegistrationFormBloc extends FormBloc<String, String> {
  final name = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final email = TextFieldBloc(validators: [FieldBlocValidators.required, FieldBlocValidators.email]);
  final password = TextFieldBloc(validators: [FieldBlocValidators.required, FieldBlocValidators.passwordMin6Chars]);
  late final confirmPassword = TextFieldBloc(
    validators: [FieldBlocValidators.required, FieldBlocValidators.confirmPassword(password)],
  );
  final acceptTerms = BooleanFieldBloc(validators: [FieldBlocValidators.required]);

  RegistrationFormBloc() {
    addFieldBlocs(fieldBlocs: [name, email, password, confirmPassword, acceptTerms]);
  }

  @override
  void onSubmitting() async {
    try {
      await api.register(name: name.value, email: email.value, password: password.value);
      emitSuccess(successResponse: 'Registration complete!');
    } catch (e) {
      emitFailure(failureResponse: e.toString());
    }
  }
}

// In widget tree:
BlocProvider(
  create: (_) => RegistrationFormBloc(),
  child: Builder(builder: (context) {
    final formBloc = context.read<RegistrationFormBloc>();
    return DmFormBlocListener<RegistrationFormBloc, String, String>(
      onSuccess: (context, state) => Navigator.of(context).pushReplacementNamed('/home'),
      onFailure: (context, state) => showDmErrorToast(context: context, message: state.failureResponse ?? 'Error'),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        DmTextFieldBlocBuilder(textFieldBloc: formBloc.name, decoration: const InputDecoration(labelText: 'Name')),
        DmTextFieldBlocBuilder(textFieldBloc: formBloc.email, decoration: const InputDecoration(labelText: 'Email')),
        DmTextFieldBlocBuilder(textFieldBloc: formBloc.password, suffixButton: SuffixButton.obscureText, decoration: const InputDecoration(labelText: 'Password')),
        DmTextFieldBlocBuilder(textFieldBloc: formBloc.confirmPassword, suffixButton: SuffixButton.obscureText, decoration: const InputDecoration(labelText: 'Confirm Password')),
        DmCheckboxFieldBlocBuilder(booleanFieldBloc: formBloc.acceptTerms, body: const Text('I accept the terms')),
        ElevatedButton(onPressed: formBloc.submit, child: const Text('Register')),
      ]),
    );
  }),
)
```

## Re-exports

The barrel file re-exports key types from `duskmoon_widgets`:

```dart
export 'package:duskmoon_widgets/duskmoon_widgets.dart'
    show DmMarkdownTab, DmMarkdownConfig, EditorTheme;
```

## Typedefs

```dart
typedef Validator<Value> = Object? Function(Value value);
typedef AsyncValidator<Value> = Future<Object?> Function(Value value);
typedef Suggestions<Value> = Future<List<Value>> Function(String pattern);
typedef FieldItemBuilder<T> = FieldItem Function(BuildContext context, T value);
typedef FieldBlocErrorBuilder = String? Function(BuildContext context, Object error);
```
