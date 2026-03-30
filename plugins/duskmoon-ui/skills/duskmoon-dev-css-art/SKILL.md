---
name: duskmoon-dev-css-art
description: When using npm package `@duskmoon-dev/css-art`, this skill shows how to install, configure, and use the pure CSS art component library
---

# @duskmoon-dev/css-art Skill

## Overview

`@duskmoon-dev/css-art` is a pure CSS art component library — decorative illustrations built entirely with CSS. No images, no SVGs, no JavaScript. Each art piece is a self-contained CSS class with customizable properties.

## Installation

```bash
# Bun
bun add @duskmoon-dev/css-art

# npm
npm install @duskmoon-dev/css-art

# pnpm
pnpm add @duskmoon-dev/css-art
```

## Setup

### CSS Import

```css
@import "@duskmoon-dev/css-art";
```

All art styles are wrapped in `@layer css-art { }`, so they won't conflict with `@duskmoon-dev/core`'s `@layer components { }`.

### Using with @duskmoon-dev/core

```css
@import "tailwindcss";
@import "@duskmoon-dev/core";
@import "@duskmoon-dev/css-art";
```

## Available Art Components

### Celestial

- `art-moon` — Moon with craters, crescent variant, and animated glow
  - Variants: `art-moon-crescent`, `art-moon-glow`
  - Sizes: `art-moon-sm` (4rem), default (8rem), `art-moon-lg` (12rem), `art-moon-xl` (16rem)
  - Custom properties: `--art-moon-size`, `--art-moon-color`, `--art-moon-shadow`, `--art-moon-glow`

- `art-sun` — Sun with radial gradient, spinning rays, and pulse animation
  - Variants: `art-sun-rays`, `art-sun-sunset`, `art-sun-pulse`
  - Sizes: `art-sun-sm` (4rem), default (8rem), `art-sun-lg` (12rem), `art-sun-xl` (16rem)
  - Custom properties: `--art-sun-size`, `--art-sun-color`, `--art-sun-corona`, `--art-sun-glow`

- `art-atom` — Animated atom with three orbiting electrons and pulsing nucleus
  - Sizes: `art-atom-sm` (180px), default (360px), `art-atom-lg` (480px)
  - Children: `.electron`, `.electron-alpha`, `.electron-omega` — three electron orbits
  - Custom properties: `--art-atom-size`, `--art-atom-color`, `--art-atom-electron-color`, `--art-atom-speed`

- `art-eclipse` — Solar eclipse with six animated corona layers
  - Sizes: `art-eclipse-sm` (300px), default (600px), `art-eclipse-lg` (800px)
  - Children: `.layer.layer-1` through `.layer.layer-6` — six corona layers
  - Custom properties: `--art-eclipse-size`, `--art-eclipse-bg`

### Landscape

- `art-mountain` — Mountain peak with snow cap, range variant with multiple peaks
  - Variants: `art-mountain-range`, `art-mountain-sunset`, `art-mountain-forest`
  - Sizes: `art-mountain-sm` (10rem×6rem), default (16rem×10rem), `art-mountain-lg` (24rem×15rem)
  - Children (range): `.art-peak` — individual peaks within a range
  - Custom properties: `--art-mountain-width`, `--art-mountain-height`, `--art-mountain-color`, `--art-mountain-shadow`, `--art-mountain-snow`

### Weather

- `art-snowflake` — Snowflake dot with optional Unicode character variant
  - Variants: `art-snowflake-unicode` (❆ character), `art-snowflake-fall` (falling animation)
  - Custom properties: `--art-snowflake-size`, `--art-snowflake-color`, `--art-snowflake-duration`

### Interactive

- `art-plasma-ball` — Interactive plasma ball with glass sphere, electrode, electric rays, and toggle switch
  - Sizes: `art-plasma-ball-sm` (200px), default (350px), `art-plasma-ball-lg` (500px)
  - Uses `input:checked` CSS selectors for toggle behavior (no JS required)
  - Children: `input.switcher`, `.glassball`, `.electrode`, `.rays`, `.ray`, `.base`, `.switch`
  - Custom properties: `--art-plasma-ball-size`, `--art-plasma-ball-base-color`

- `art-circular-gallery` — CSS anchor-positioned circular gallery with 20 rotating card thumbnails
  - Sizes: `art-circular-gallery-sm` (400px), default (600px), `art-circular-gallery-lg` (800px)
  - Children: `h1` (center title), `div` elements (one per card) with `data-title` attribute, `a > img` (card thumbnail)
  - Uses CSS `offset-path`, `position-anchor`, and `:target` for hover/selection behavior — no JS
  - Custom properties: `--art-circular-gallery-size`, `--art-circular-gallery-radius`, `--art-circular-gallery-card-width`

### Scenes

- `art-cat-stargazer` — A cat in a spacesuit gazing at the night sky with stars and a glowing moon
  - Sizes: `art-cat-stargazer-sm` (300px), default (500px), `art-cat-stargazer-lg` (700px)
  - Children: `.moon`, `.cat`, `.cat .bubble`, `.cat .backpack`, `.cat .tail`, `.cat .body`, `.cat .ear`, `.cat .head`
  - Custom properties: `--art-cat-stargazer-size`

- `art-flower-animation` — Blooming flowers with grass, light particles, and floating heart bubbles against a night sky
  - Sizes: `art-flower-animation-sm` (300px), default (600px), `art-flower-animation-lg` (900px)
  - Children: `.night`, `.flowers`, `.flower.flower--1` through `.flower--4`, `.bubbles`, `.bubble`
  - Custom properties: `--art-flower-animation-size`, `--art-flower-animation-bg`

### Abstract / Generative

- `art-color-spin` — 3D spinning Olympic-style color rings with reflections and perspective
  - Sizes: `art-color-spin-sm` (385px), default (770px), `art-color-spin-lg` (1000px)
  - Children: `ul` (required container), `ul > li` × 4 (one per ring)
  - Custom properties: `--art-color-spin-size`, `--art-color-spin-color1` through `--art-color-spin-color4`

- `art-synthwave-starfield` — Synthwave-aesthetic 3D starfield tunnel with neon grid walls and animated stars
  - Sizes: `art-synthwave-starfield-sm` (300px), default (600px), `art-synthwave-starfield-lg` (900px)
  - Modifier: `art-synthwave-starfield-paused` — pauses all animations
  - Children: `.art-synthwave-starfield-sides.art-synthwave-starfield-lefrig`, `.art-synthwave-starfield-sides.art-synthwave-starfield-topbot`, `.art-synthwave-starfield-stars` (×2)
  - Custom properties: `--art-synthwave-starfield-size`, `--art-synthwave-starfield-line-color`

### Gaming

- `art-csswitch` — CSS-only game controller switch (Nintendo Switch inspired)
  - Sizes: `art-csswitch-sm`, default, `art-csswitch-lg`
  - Children: complex controller structure with `.controller`, `.joycon-left`, `.joycon-right`, `.frame`, `.main-frame`, `.mushroom`, `.direction`, `.bar`, `.logo`, `.light`
  - Custom properties: `--art-csswitch-size`, `--color`, `--color-shadow`, `--joycon-left`, `--joycon-left-shadow`, `--joycon-right`, `--joycon-right-shadow`

### Loading

- `art-snowball-preloader` — Animated snowball loading spinner with orbital rings
  - Sizes: `art-snowball-preloader-sm`, default, `art-snowball-preloader-lg`
  - Children: `.art-snowball-preloader-ball`, `.art-snowball-preloader-ball-texture`, `.art-snowball-preloader-ball-inner-shadow`, `.art-snowball-preloader-ball-outer-shadow`, `.art-snowball-preloader-ball-side-shadows`, `.art-snowball-preloader-inner-ring`, `.art-snowball-preloader-outer-ring`, `.art-snowball-preloader-track-cover`
  - Custom properties: `--art-snowball-preloader-size`, `--art-snowball-preloader-bg`

### UI Components

- `art-gemini-input` — Gemini-style animated conic-gradient border with glow halo on a textarea input
  - Sizes: `art-gemini-input-sm` (280px), default (450px), `art-gemini-input-lg` (640px)
  - Children: `.art-gemini-input-border`, `.art-gemini-input-inner`, `.art-gemini-input-btn`, `.art-gemini-input-field` (textarea)
  - Custom properties: `--art-gemini-input-width`, `--art-gemini-input-border-size`, `--art-gemini-input-gradient`

## Usage Examples

### Basic Moon

```html
<div class="art-moon"></div>
```

### Crescent Moon with Glow

```html
<div class="art-moon art-moon-crescent art-moon-glow"></div>
```

### Sun with Animated Rays

```html
<div class="art-sun art-sun-rays"></div>
```

### Sunset Sun

```html
<div class="art-sun art-sun-sunset art-sun-rays"></div>
```

### Single Mountain

```html
<div class="art-mountain"></div>
```

### Mountain Range

```html
<div class="art-mountain-range">
  <div class="art-peak"></div>
  <div class="art-peak"></div>
  <div class="art-peak"></div>
</div>
```

### Atom

```html
<div class="art-atom">
  <div class="electron"></div>
  <div class="electron-alpha"></div>
  <div class="electron-omega"></div>
</div>
```

### Eclipse

```html
<div class="art-eclipse">
  <div class="layer layer-1"></div>
  <div class="layer layer-2"></div>
  <div class="layer layer-3"></div>
  <div class="layer layer-4"></div>
  <div class="layer layer-5"></div>
  <div class="layer layer-6"></div>
</div>
```

### Snowflakes

```html
<!-- Simple dot snowflake -->
<div class="art-snowflake art-snowflake-fall"></div>

<!-- Unicode snowflake character -->
<div class="art-snowflake art-snowflake-unicode art-snowflake-fall"></div>
```

### Plasma Ball (Interactive)

```html
<div class="art-plasma-ball">
  <input class="switcher" type="checkbox" />
  <div class="glassball">
    <div class="electrode"></div>
    <div class="rays">
      <div class="ray"><span></span><span></span><span></span></div>
      <div class="ray bigwave"><span></span><span></span></div>
      <div class="ray"><span></span><span></span><span></span></div>
      <div class="ray bigwave"><span></span><span></span></div>
      <div class="ray"><span></span><span></span><span></span></div>
    </div>
    <!-- repeat .rays block 5 more times for full coverage -->
  </div>
  <div class="base"><div></div><div></div><span></span></div>
  <div class="switch"></div>
</div>
```

### Cat Stargazer

```html
<div class="art-cat-stargazer">
  <div class="moon"></div>
  <div class="cat">
    <div class="bubble"></div>
    <div class="backpack"></div>
    <div class="tail"></div>
    <div class="body">
      <div class="leg"></div>
      <div class="paw"></div><div class="paw"></div>
    </div>
    <div class="ear"></div><div class="ear"></div>
    <div class="head">
      <div class="whisker"></div><div class="whisker"></div>
      <div class="whisker"></div><div class="whisker"></div>
      <div class="nose"></div>
      <div class="eye"></div><div class="eye"></div>
    </div>
  </div>
</div>
```

### Color Spin

```html
<div class="art-color-spin">
  <ul>
    <li style="--i:1"></li>
    <li style="--i:2"></li>
    <li style="--i:3"></li>
    <li style="--i:4"></li>
  </ul>
</div>
```

### Synthwave Starfield

```html
<div class="art-synthwave-starfield">
  <div class="art-synthwave-starfield-sides art-synthwave-starfield-lefrig"></div>
  <div class="art-synthwave-starfield-sides art-synthwave-starfield-topbot"></div>
  <div class="art-synthwave-starfield-stars"></div>
  <div class="art-synthwave-starfield-stars"></div>
</div>
```

### Circular Gallery

```html
<div class="art-circular-gallery">
  <h1>Gallery</h1>
  <div style="--i:1" data-title="Photo 1"><a href="#item1"><img src="photo1.jpg" alt="Photo 1" /></a></div>
  <div style="--i:2" data-title="Photo 2"><a href="#item2"><img src="photo2.jpg" alt="Photo 2" /></a></div>
  <!-- repeat for up to 20 items -->
</div>
```

### Flower Animation

```html
<div class="art-flower-animation">
  <div class="night"></div>
  <div class="flowers">
    <div class="flower flower--1">
      <div class="flower__leafs flower__leafs--1">
        <div class="flower__leaf flower__leaf--1"></div>
        <div class="flower__leaf flower__leaf--2"></div>
        <div class="flower__leaf flower__leaf--3"></div>
        <div class="flower__leaf flower__leaf--4"></div>
        <div class="flower__white-circle"></div>
      </div>
      <div class="flower__line">
        <div class="flower__line__leaf flower__line__leaf--1"></div>
        <div class="flower__line__leaf flower__line__leaf--2"></div>
      </div>
    </div>
  </div>
</div>
```

### Gemini Input

```html
<div class="art-gemini-input">
  <div class="art-gemini-input-border"></div>
  <div class="art-gemini-input-inner">
    <button class="art-gemini-input-btn">+</button>
    <textarea class="art-gemini-input-field" placeholder="Ask Gemini..."></textarea>
    <button class="art-gemini-input-btn">▶</button>
  </div>
</div>
```

### CSSwitch (Game Controller)

```html
<div class="art-csswitch">
  <div class="controller">
    <div class="frame">
      <div class="main-frame"><!-- controller frame --></div>
    </div>
  </div>
</div>
```

### Snowball Preloader

```html
<div class="art-snowball-preloader">
  <div class="art-snowball-preloader-outer-ring"></div>
  <div class="art-snowball-preloader-inner-ring"></div>
  <div class="art-snowball-preloader-track-cover"></div>
  <div class="art-snowball-preloader-ball">
    <div class="art-snowball-preloader-ball-texture"></div>
    <div class="art-snowball-preloader-ball-outer-shadow"></div>
    <div class="art-snowball-preloader-ball-inner-shadow"></div>
    <div class="art-snowball-preloader-ball-side-shadows"></div>
  </div>
</div>
```

### Custom Colors

Override CSS custom properties to customize any art piece:

```html
<!-- Blue moon -->
<div class="art-moon" style="--art-moon-color: oklch(80% 0.08 240);"></div>

<!-- Custom-sized sun -->
<div class="art-sun" style="--art-sun-size: 6rem;"></div>

<!-- Green atom -->
<div class="art-atom" style="--art-atom-color: #00ff88;">
  <div class="electron"></div>
  <div class="electron-alpha"></div>
  <div class="electron-omega"></div>
</div>
```

### Composing a Night Scene

```html
<div style="background: oklch(15% 0.02 260); padding: 3rem; position: relative; overflow: hidden;">
  <div class="art-moon art-moon-crescent art-moon-glow" style="position: absolute; top: 1rem; right: 2rem;"></div>
  <div class="art-snowflake art-snowflake-fall" style="left: 20%; --art-snowflake-duration: 6s;"></div>
  <div class="art-snowflake art-snowflake-fall" style="left: 50%; --art-snowflake-duration: 4s; animation-delay: 1s;"></div>
  <div class="art-snowflake art-snowflake-fall" style="left: 80%; --art-snowflake-duration: 5s; animation-delay: 2s;"></div>
  <div class="art-mountain-range" style="position: absolute; bottom: 0;">
    <div class="art-peak"></div>
    <div class="art-peak"></div>
    <div class="art-peak"></div>
  </div>
</div>
```

## CSS Architecture

- All classes prefixed with `.art-` to avoid collisions
- All custom properties prefixed with `--art-` for namespacing
- Uses `@layer css-art` to avoid cascade conflicts with other libraries
- Colors use OKLCH format for perceptual uniformity
- Animations use `@keyframes` with `art-` prefixed names

## Importing Individual Art Pieces

```css
/* Import only what you need */
@import "@duskmoon-dev/css-art/art";
```

## Development Commands

```bash
# Build css-art package
bun run build:css-art

# Watch mode
bun run dev:css-art

# Unit tests
cd packages/css-art && bun test tests/unit
```

## Bundle Size

- Unminified: ~50 KB
- Minified: ~36 KB
