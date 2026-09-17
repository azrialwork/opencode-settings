# Animation

Micro-interactions and motion design patterns.

## Duration Guidelines

| Type   | Duration  | Use Case             |
| ------ | --------- | -------------------- |
| Micro  | 100-150ms | Hover, focus states  |
| Short  | 150-300ms | Button click, toggle |
| Medium | 300-500ms | Modal, drawer open   |
| Long   | 500-800ms | Page transition      |

## Easing

```css
/* Recommended easings */
--ease-out: cubic-bezier(0.16, 1, 0.3, 1); /* Smooth exit */
--ease-in-out: cubic-bezier(0.87, 0, 0.13, 1); /* Smooth both */
--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1); /* Bouncy */
```

```html
<!-- Tailwind example -->
<div class="transition-all duration-300 ease-out">Card</div>
```

## Performance

**Only animate these properties for 60fps:**

```css
/* Good: GPU accelerated */
transform: translateX();
transform: scale();
transform: rotate();
opacity: 0;

/* Avoid: Causes layout */
width, height, top, left, margin, padding
```

## Reduced Motion

**Always respect user preferences:**

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

```html
<!-- Tailwind -->
<div class="motion-reduce:transition-none motion-reduce:animate-none">
  Animated element
</div>
```

## Loading States

### Spinner

```html
<div
  class="animate-spin h-5 w-5 border-2 border-primary border-t-transparent rounded-full"
/>
```

### Skeleton

```html
<div class="animate-pulse space-y-2">
  <div class="h-4 bg-muted rounded w-3/4"></div>
  <div class="h-4 bg-muted rounded w-1/2"></div>
</div>
```

### Progress

```html
<div class="h-2 bg-muted rounded-full overflow-hidden">
  <div
    class="h-full bg-primary transition-all duration-300"
    style="width: {progress}%"
  />
</div>
```

## Hover Effects

```html
<!-- Scale -->
<button class="transition-transform hover:scale-105 active:scale-95">
  Click me
</button>

<!-- Shadow -->
<div class="transition-shadow hover:shadow-lg">Card</div>

<!-- Background -->
<button class="transition-colors hover:bg-primary/90">Button</button>
```

## Page Transitions

```html
<!-- Fade in -->
<div class="animate-in fade-in duration-300">Content</div>

<!-- Slide in -->
<div class="animate-in slide-in-from-bottom duration-500">Modal</div>
```

## When to Animate

| Animate            | Don't Animate     |
| ------------------ | ----------------- |
| State changes      | Static content    |
| User actions       | Every interaction |
| Drawing attention  | Distracting users |
| Providing feedback | Just because      |

## Animation Checklist

- [ ] Duration < 300ms for UI elements
- [ ] Uses transform/opacity only
- [ ] Respects prefers-reduced-motion
- [ ] Doesn't loop infinitely (except spinners)
- [ ] Provides visual feedback
