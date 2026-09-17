# Typography

Typography best practices for readable interfaces.

## Font Selection

### By Industry

| Industry              | Font Style     | Examples              |
| --------------------- | -------------- | --------------------- |
| Tech/Apps             | Sans-serif     | Inter, Roboto, SF Pro |
| Formal (Law, Finance) | Serif          | Merriweather, Lora    |
| Creative/Casual       | Display/Script | Poppins, Outfit       |

### Safe Choices

```
Inter, Roboto, Open Sans, Lato, Poppins,
SF Pro (Apple), Segoe UI (Windows)
```

## Font Pairing

**Maximum 2 fonts** (1 for headings, 1 for body):

```html
<style>
  body {
    font-family: "Inter", sans-serif;
  }
  h1,
  h2,
  h3 {
    font-family: "Outfit", sans-serif;
  }
</style>
```

## Type Scale

```css
/* Recommended scale (1.25 ratio) */
--text-xs: 0.75rem; /* 12px */
--text-sm: 0.875rem; /* 14px */
--text-base: 1rem; /* 16px */
--text-lg: 1.125rem; /* 18px */
--text-xl: 1.25rem; /* 20px */
--text-2xl: 1.5rem; /* 24px */
--text-3xl: 1.875rem; /* 30px */
--text-4xl: 2.25rem; /* 36px */
```

## Line Height

```css
/* Body text: 1.5-1.75 */
body {
  line-height: 1.6;
}

/* Headings: 1.2-1.4 */
h1,
h2,
h3 {
  line-height: 1.3;
}
```

## Line Length

| Device  | Characters per Line |
| ------- | ------------------- |
| Desktop | 65-75 characters    |
| Mobile  | 30-40 characters    |

```css
/* Prose width */
.prose {
  max-width: 65ch;
}

/* Tailwind */
<p class="max-w-prose">...</p>
```

## Font Weight

```css
/* Headings */
h1,
h2 {
  font-weight: 700;
} /* Bold */
h3 {
  font-weight: 600;
} /* Semibold */

/* Body */
p {
  font-weight: 400;
} /* Regular */
```

## Font Size

```css
/* Minimum sizes */
body {
  font-size: 16px;
} /* Never smaller */
small {
  font-size: 14px;
} /* Absolute minimum */
```

## Text Contrast

```css
/* Bad: Pure black on white */
body {
  color: #000000;
  background: #ffffff;
}

/* Good: Softer contrast */
body {
  color: #1a1a1a; /* Off-black */
  background: #fafafa; /* Off-white */
}

/* Muted text */
.muted {
  color: #666666;
}
```

## Things to Avoid

| Don't               | Why                  |
| ------------------- | -------------------- |
| < 12px font         | Unreadable on mobile |
| > 2 fonts           | Cluttered appearance |
| Same weight for all | No hierarchy         |
| Pure black on white | Eye strain           |
| Center aligned body | Hard to read         |
| All caps paragraphs | Difficult to scan    |
