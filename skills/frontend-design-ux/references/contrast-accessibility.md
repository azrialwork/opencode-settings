# Contrast & Accessibility

WCAG 2.1 compliance and accessible design patterns.

## Contrast Ratios

| Text Type                       | Minimum | Enhanced |
| ------------------------------- | ------- | -------- |
| Normal text                     | 4.5:1   | 7:1      |
| Large text (18px+ or 14px bold) | 3:1     | 4.5:1    |
| UI components                   | 3:1     | -        |

## Never Rely on Color Alone

```html
<!-- Bad: Color only -->
<span class="text-red-500">Error</span>

<!-- Good: Color + Icon + Text -->
<span class="text-red-500 flex items-center gap-1">
  <AlertCircle />
  Error: Invalid input
</span>
```

## Focus States

**Never remove focus outlines without replacement:**

```css
/* Bad: Removes accessibility */
*:focus {
  outline: none;
}

/* Good: Custom focus style */
*:focus-visible {
  outline: 2px solid currentColor;
  outline-offset: 2px;
}
```

```html
<!-- Tailwind example -->
<button
  class="focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
>
  Click me
</button>
```

## ARIA Labels

### Icon Buttons

```html
<!-- Bad: No label -->
<button><SearchIcon /></button>

<!-- Good: Accessible label -->
<button aria-label="Search">
  <SearchIcon />
</button>
```

### Form Fields

```html
<!-- Good: Associated label -->
<label for="email">Email</label>
<input id="email" type="email" />

<!-- Good: ARIA for complex fields -->
<input type="email" aria-label="Email address" aria-describedby="email-hint" />
<p id="email-hint">We'll never share your email</p>
```

## Skip Links

```html
<a
  href="#main-content"
  class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:p-4 focus:bg-primary focus:text-primary-foreground"
>
  Skip to main content
</a>

<!-- ... navigation ... -->

<main id="main-content">
  <!-- Page content -->
</main>
```

## Screen Reader Only

```html
<!-- Visually hidden but accessible -->
<span class="sr-only">Loading, please wait</span>

<!-- Tailwind sr-only class -->
.sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin:
-1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap;
border-width: 0; }
```

## Heading Hierarchy

Maintain sequential heading levels:

```html
<!-- Good: Sequential -->
<h1>Page Title</h1>
<h2>Section</h2>
<h3>Subsection</h3>

<!-- Bad: Skips levels -->
<h1>Page Title</h1>
<h3>Section</h3>
<!-- Skips h2 -->
```

## Color Contrast Tools

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Coolors Contrast Checker](https://coolors.co/contrast-checker)
- Browser DevTools accessibility panel

## Motion & Animation

```css
/* Respect user preferences */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

```html
<!-- Tailwind example -->
<div class="transition-transform motion-reduce:transition-none hover:scale-105">
  Card
</div>
```

## Checklist

- [ ] All images have alt text
- [ ] All inputs have labels
- [ ] Focus states visible
- [ ] Color contrast 4.5:1 minimum
- [ ] No color-only information
- [ ] Heading hierarchy correct
- [ ] Skip link present
- [ ] Keyboard navigable
- [ ] ARIA labels for icon buttons
- [ ] Reduced motion supported
