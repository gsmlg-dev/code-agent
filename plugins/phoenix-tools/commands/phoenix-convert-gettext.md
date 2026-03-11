---
description: Convert Phoenix app hardcoded text to use gettext with domain-based translations
arguments:
  - name: web_dir
    description: Path to the Phoenix web directory (e.g., apps/gsmlg_app_web/lib/gsmlg_app_web)
    required: true
---

In the Phoenix app at {{ web_dir }}, refactor all hardcoded text strings to use gettext with domain-based translation logic. Specifically:

## Tasks

1. **Convert hardcoded strings** in templates, views, and controllers to use gettext functions

2. **Organize translations by domain/context**:
   - `user` - user account, profile, authentication related text
   - `admin` - admin panel, management, settings text
   - `errors` - error messages, validations, warnings
   - `navigation` - menus, links, breadcrumbs, page titles
   - `common` - shared/general purpose text, buttons, actions

3. **Use appropriate gettext functions**:
   - Use `dgettext/2` for domain-specific translations
   - Use `dgettext/3` when interpolation is needed
   - Use `dngettext/4` for pluralization

4. **Extract strings from**:
   - All `.ex` files (controllers, views, live views, components)
   - All `.heex` templates
   - Any JavaScript/TypeScript with user-facing text

## Conventions

- **msgids**: Keep in English as the default language
- **Imports**: Add `import <AppName>Web.Gettext` to modules that need it
- **Context comments**: Add comments for ambiguous translations
- **Interpolation**: Use named parameters for dynamic content

## Example Transformations

### Templates (.heex)
```elixir
# Before
<h1>Welcome to our app</h1>
<p>You have 5 messages</p>

# After
<h1><%= dgettext("navigation", "Welcome to our app") %></h1>
<p><%= dngettext("user", "You have 1 message", "You have %{count} messages", @message_count) %></p>
```

### Controllers
```elixir
# Before
conn
|> put_flash(:info, "User created successfully")
|> redirect(to: ~p"/users")

# After
conn
|> put_flash(:info, dgettext("user", "User created successfully"))
|> redirect(to: ~p"/users")
```

### Views/Components
```elixir
# Before
def error_message, do: "Something went wrong"

# After
def error_message, do: dgettext("errors", "Something went wrong")
```

### LiveViews
```elixir
# Before
{:noreply, put_flash(socket, :error, "Invalid input")}

# After
{:noreply, put_flash(socket, :error, dgettext("errors", "Invalid input"))}
```

## Additional Requirements

1. **Maintain structure**: Preserve existing code formatting and functionality
2. **Ensure imports**: Verify Gettext module is imported where needed
3. **Check configuration**: Ensure the Gettext module is properly configured in the app
4. **Handle edge cases**: 
   - Don't translate attribute names, IDs, or technical values
   - Don't translate log messages unless user-facing
   - Keep email addresses, URLs, and code examples untranslated

## Focus Area

Work only within the {{ web_dir }} directory and its subdirectories.
