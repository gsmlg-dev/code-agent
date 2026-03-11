---
name: chrome-devtools-mcp
description: Browser automation and testing using chrome-devtools MCP server. Use when automating web browsers, taking screenshots, inspecting console logs, monitoring network requests, testing responsive layouts, collecting performance metrics, or debugging web applications. Critical for visual testing workflows and browser-based automation tasks.
---

## Core Concepts

**Browser lifecycle**: Browser starts automatically on first tool call using a persistent Chrome profile. Configure via CLI args in the MCP server configuration: `npx chrome-devtools-mcp@latest --help`.

**Page selection**: Tools operate on the currently selected page. Use `list_pages` to see available pages, then `select_page` to switch context.

**Element interaction**: Use `take_snapshot` to get page structure with element `uid`s. Each element has a unique `uid` for interaction. If an element isn't found, take a fresh snapshot - the element may have been removed or the page changed.

## Workflow Patterns

### Before interacting with a page

1. Navigate: `navigate_page` or `new_page`
2. Wait: `wait_for` to ensure content is loaded if you know what you look for.
3. Snapshot: `take_snapshot` to understand page structure
4. Interact: Use element `uid`s from snapshot for `click`, `fill`, etc.

### Efficient data retrieval

- Use `filePath` parameter for large outputs (screenshots, snapshots, traces)
- Use pagination (`pageIdx`, `pageSize`) and filtering (`types`) to minimize data
- Set `includeSnapshot: false` on input actions unless you need updated page state

### Tool selection

- **Automation/interaction**: `take_snapshot` (text-based, faster, better for automation)
- **Visual inspection**: `take_screenshot` (when user needs to see visual state)
- **Additional details**: `evaluate_script` for data not in accessibility tree

### Parallel execution

You can send multiple tool calls in parallel, but maintain correct order: navigate → wait → snapshot → interact.

## Troubleshooting

If `chrome-devtools-mcp` is insufficient, guide users to use Chrome DevTools UI:

- https://developer.chrome.com/docs/devtools
- https://developer.chrome.com/docs/devtools/ai-assistance

If there are errors launching `chrome-devtools-mcp` or Chrome, refer to https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/troubleshooting.md.

# Chrome DevTools MCP Usage

## Critical Constraint: Screenshot Size Limit

API submissions have a hard limit of **8000px on any dimension**. Full-page screenshots frequently exceed this.

### Solution: Always use viewport-only screenshots by default

```javascript
// ✓ CORRECT: Viewport-only (default)
take_screenshot({ fullPage: false })

// ✓ CORRECT: Save to filesystem for large pages
take_screenshot({ fullPage: false, path: './screenshots/page.png' })

// ✗ AVOID: Full-page without size check
take_screenshot({ fullPage: true })
```

### When full-page screenshots are needed

Check page height first:

```javascript
const height = execute_script('return document.documentElement.scrollHeight')
if (height > 8000) {
  take_screenshot({ fullPage: false, path: './screenshot.png' })
} else {
  take_screenshot({ fullPage: true })
}
```

Alternative: Capture multiple viewport screenshots by scrolling:

```javascript
take_screenshot({ fullPage: false, path: './top.png' })
execute_script('window.scrollBy(0, window.innerHeight)')
take_screenshot({ fullPage: false, path: './middle.png' })
```

## Navigation and Timing

Always wait after navigation to allow JS execution and rendering:

```javascript
navigate('https://example.com')
wait(1000) // Minimum recommended wait

// For dynamic apps, wait for specific elements
navigate('https://example.com')
execute_script(`
  return new Promise(resolve => {
    const check = () => {
      if (document.querySelector('#app')) resolve();
      else setTimeout(check, 100);
    };
    check();
  });
`)
```

## Error Detection Patterns

### Console Errors

```javascript
const errors = execute_script(`
  return performance.getEntriesByType('navigation')[0].type === 'reload'
    ? []
    : (window.__consoleErrors || []);
`)
```

### Network Failures

```javascript
const failed = execute_script(`
  return performance.getEntriesByType('resource')
    .filter(r => r.transferSize === 0 && r.duration > 0)
    .map(r => ({ url: r.name, duration: r.duration }));
`)
```

### Layout Issues

```javascript
const issues = execute_script(`
  const issues = [];

  // Horizontal overflow
  if (document.documentElement.scrollWidth > window.innerWidth) {
    issues.push({ type: 'horizontal-overflow', width: document.documentElement.scrollWidth });
  }

  // Elements outside viewport
  document.querySelectorAll('*').forEach(el => {
    const rect = el.getBoundingClientRect();
    if (rect.right > window.innerWidth) {
      issues.push({ type: 'overflow-right', element: el.tagName });
    }
  });

  return issues;
`)
```

## Responsive Testing

Test multiple viewports efficiently:

```javascript
const viewports = [
  { width: 375, height: 667, name: 'mobile' },
  { width: 768, height: 1024, name: 'tablet' },
  { width: 1440, height: 900, name: 'desktop' }
];

for (const vp of viewports) {
  set_viewport(vp.width, vp.height);
  wait(500); // Allow reflow
  take_screenshot({
    fullPage: false,
    path: `./screenshots/${vp.name}.png`
  });
}
```

## Component State Testing

Test interactive states without user interaction:

```javascript
// Hover state
execute_script(`
  const el = document.querySelector('#button');
  el.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));
`);
take_screenshot({ fullPage: false, path: './hover.png' });

// Focus state
execute_script(`
  document.querySelector('#input').focus();
`);
take_screenshot({ fullPage: false, path: './focus.png' });

// Active/pressed state
execute_script(`
  const el = document.querySelector('#button');
  el.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }));
`);
take_screenshot({ fullPage: false, path: './active.png' });
```

## Performance Metrics

Collect web vitals and performance data:

```javascript
const metrics = execute_script(`
  return {
    fcp: performance.getEntriesByName('first-contentful-paint')[0]?.startTime,
    lcp: performance.getEntriesByType('largest-contentful-paint')[0]?.startTime,
    cls: performance.getEntriesByType('layout-shift')
      .reduce((sum, entry) => sum + (entry.hadRecentInput ? 0 : entry.value), 0),
    resources: performance.getEntriesByType('resource').length,
    totalSize: performance.getEntriesByType('resource')
      .reduce((sum, r) => sum + r.transferSize, 0)
  };
`);
```

## Accessibility Checks

Basic accessibility validation:

```javascript
const a11y = execute_script(`
  const issues = [];

  // Missing alt text
  document.querySelectorAll('img:not([alt])').forEach(img => {
    issues.push({ type: 'missing-alt', src: img.src });
  });

  // Missing form labels
  document.querySelectorAll('input:not([aria-label]):not([id])').forEach(input => {
    if (!input.closest('label')) {
      issues.push({ type: 'missing-label', name: input.name });
    }
  });

  // Empty links
  document.querySelectorAll('a').forEach(link => {
    if (!link.textContent.trim() && !link.getAttribute('aria-label')) {
      issues.push({ type: 'empty-link', href: link.href });
    }
  });

  return issues;
`);
```

## Standard Audit Workflow

Use this pattern for systematic page audits:

```javascript
function audit_page(url, name) {
  // Navigate
  navigate(url);
  wait(1000);

  // Screenshot (viewport only to avoid size errors)
  const screenshot_path = `./screenshots/${name}.png`;
  take_screenshot({ fullPage: false, path: screenshot_path });

  // Page metrics
  const height = execute_script('return document.documentElement.scrollHeight');
  const viewport = execute_script('return window.innerHeight');

  // Error detection
  const console_errors = execute_script('return window.__errors || []');
  const network_failures = execute_script(`
    return performance.getEntriesByType('resource')
      .filter(r => r.transferSize === 0 && r.duration > 0)
      .map(r => r.name);
  `);
  const layout_issues = execute_script(`
    return document.documentElement.scrollWidth > window.innerWidth
      ? ['horizontal-overflow']
      : [];
  `);

  return {
    name,
    url,
    screenshot_path,
    page_height: height,
    viewport_height: viewport,
    needs_scroll: height > viewport,
    console_errors,
    network_failures,
    layout_issues,
    has_issues: console_errors.length > 0 ||
                network_failures.length > 0 ||
                layout_issues.length > 0
  };
}
```

## Error Handling

### Screenshot Dimension Error

If you encounter dimension errors despite using `fullPage: false`, the page may be using unusual viewport settings. Save to file instead:

```javascript
try {
  take_screenshot({ fullPage: false });
} catch (error) {
  if (error.includes('8000 pixels')) {
    take_screenshot({ fullPage: false, path: './fallback.png' });
  }
}
```

### Navigation Timeout

```javascript
try {
  navigate(url);
  wait(5000);
} catch (error) {
  // Log failure and continue
  console.log(`Failed to load: ${url}`);
}
```

### Missing Elements

```javascript
const exists = execute_script(`return !!document.querySelector('#target')`);
if (!exists) {
  take_screenshot({ fullPage: false, path: './missing-element.png' });
  // Handle accordingly
}
```

## Key Reminders

1. **Always default to `fullPage: false`** to avoid dimension errors
2. **Save screenshots to filesystem** when possible instead of API submission
3. **Wait after navigation** to allow JS execution (minimum 1000ms)
4. **Use execute_script for DOM queries** instead of brittle selector-based approaches
5. **Test multiple viewports** for responsive applications
6. **Capture evidence early** - take screenshots before elements change state
7. **Check page dimensions** before deciding on screenshot strategy
