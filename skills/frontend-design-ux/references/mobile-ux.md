# Mobile UX Reference

> **Zie ook:** [SKILL.md](../SKILL.md) - Workflow stap 2: Apply mobile-first (VERPLICHT)

---

## 1. Mobile-First (VERPLICHT)

**Bij ELKE styling taak: mobile eerst, dan progressive enhancement.**

### Waarom Mobile-First?

- Mobile traffic > 60% van web traffic
- Mobile constraints dwingen focus op essentie
- Progressive enhancement > graceful degradation
- Betere performance (minder CSS, sneller load)

### Tailwind Breakpoint Volgorde

**ALTIJD deze volgorde:**

```html
<!-- ❌ FOUT: Desktop first (breek de regel!) -->
<div class="flex-row gap-8 p-8 md:flex-col md:gap-4 md:p-4">
  <!-- ✅ GOED: Mobile first -->
  <div
    class="flex flex-col gap-4 p-4 md:flex-row md:gap-6 md:p-6 lg:gap-8 lg:p-8"
  ></div>
</div>
```

**Uitleg:**

| Breakpoint | Scherm   | Wanneer gebruiken           |
| ---------- | -------- | --------------------------- |
| (geen)     | < 640px  | Mobile base styles          |
| `sm:`      | ≥ 640px  | Large phones, small tablets |
| `md:`      | ≥ 768px  | Tablets                     |
| `lg:`      | ≥ 1024px | Laptops, desktops           |
| `xl:`      | ≥ 1280px | Large desktops              |
| `2xl:`     | ≥ 1536px | Extra large screens         |

**Regel:** Base class = mobile → Dan `md:` → Dan `lg:`

---

## 2. Mobile-First Checklist

Bij ELKE styling wijziging, check deze lijst:

- [ ] **Base styles** werken op 375px (iPhone)
- [ ] **Touch targets** minimaal 44x44px
- [ ] **Spacing** minimaal 8px tussen klikbare elementen
- [ ] **Font size** minimaal 16px (voorkomt iOS zoom)
- [ ] **Primary actions** in thumb zone (onderin scherm)
- [ ] **Breakpoints** in volgorde: base → `md:` → `lg:`

---

## 3. Touch Targets

**Minimum size: 44x44px (Apple), 48x48px (Android)**

```html
<!-- ❌ FOUT: Te klein -->
<button class="p-1">
  <Icon class="w-4 h-4" />
</button>

<!-- ✅ GOED: Voldoet aan minimum -->
<button class="p-3 min-h-[44px] min-w-[44px] flex items-center justify-center">
  <Icon class="w-5 h-5" />
</button>
```

---

## 4. Minimum Spacing

**8px gap tussen touch targets**

```html
<!-- ❌ FOUT: Te dicht bij elkaar -->
<div class="flex gap-1">
  <button>Action 1</button>
  <button>Action 2</button>
</div>

<!-- ✅ GOED: Voldoende spacing -->
<div class="flex gap-2">
  <button class="min-h-[44px]">Action 1</button>
  <button class="min-h-[44px]">Action 2</button>
</div>
```

---

## 5. Thumb Zone

Plaats primary actions binnen handig thumb bereik:

```
┌─────────────────┐
│    Hard         │  ← Top: Moeilijk bereikbaar
│  ┌───────────┐  │
│  │  Moderate │  │  ← Center: Matig
│  │ ┌───────┐ │  │
│  │ │ EASY  │ │  │  ← Bottom: Thumb zone (PLAATS HIER CTAs!)
│  └─┴───────┴─┘  │
└─────────────────┘
```

### Bottom Navigation

```html
<nav class="fixed bottom-0 left-0 right-0 bg-background border-t">
  <div class="flex justify-around py-2">
    <button class="flex flex-col items-center p-2 min-h-[44px]">
      <HomeIcon />
      <span class="text-xs mt-1">Home</span>
    </button>
    <!-- More nav items -->
  </div>
</nav>
```

### Bottom Sheet Actions

```html
<!-- Primary action onderin -->
<div class="fixed bottom-0 left-0 right-0 p-4 bg-background border-t">
  <button class="w-full min-h-[44px]">Continue</button>
</div>
```

---

## 6. Viewport Height

**Nooit `100vh` op mobile** - URL bar veroorzaakt problemen:

```css
/* ❌ FOUT: Content verborgen achter URL bar */
.container {
  height: 100vh;
}

/* ✅ GOED: Dynamic viewport height */
.container {
  height: 100dvh; /* Modern browsers */
  height: -webkit-fill-available; /* Safari fallback */
}
```

---

## 7. Responsive Breakpoints Test Matrix

Test op deze breedtes:

| Device        | Width  | Use Case          |
| ------------- | ------ | ----------------- |
| Small mobile  | 320px  | iPhone SE         |
| Mobile        | 375px  | iPhone 14         |
| Large mobile  | 428px  | iPhone 14 Pro Max |
| Tablet        | 768px  | iPad              |
| Desktop       | 1024px | Small laptop      |
| Large desktop | 1440px | Standard monitor  |

---

## 8. Font Size

**Minimum 16px voor body text** - Voorkomt iOS zoom on focus:

```css
/* ❌ FOUT: iOS zoomt on focus */
input {
  font-size: 14px;
}

/* ✅ GOED: Geen zoom */
input {
  font-size: 16px;
}
```

---

## 9. Viewport Meta Tag

```html
<!-- VERPLICHT voor responsive design -->
<meta name="viewport" content="width=device-width, initial-scale=1" />
```

---

## 10. Gestures

| Gesture         | Use Case                |
| --------------- | ----------------------- |
| Tap             | Select, activate        |
| Long press      | Context menu, selection |
| Swipe           | Navigate, dismiss       |
| Pinch           | Zoom                    |
| Pull to refresh | Refresh content         |

### Swipe Indicator

```html
<div class="relative overflow-hidden">
  <div class="transition-transform" style="transform: translateX({swipeX}px)">
    {content}
  </div>
  {#if Math.abs(swipeX) > 50}
  <div class="absolute inset-y-0 right-0 flex items-center bg-red-500 px-4">
    <TrashIcon class="text-white" />
  </div>
  {/if}
</div>
```
