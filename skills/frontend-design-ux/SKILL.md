---
name: frontend-design-ux
description: UI/UX design principles for developers - visual hierarchy, spacing, contrast, accessibility (WCAG), component states, interaction patterns, forms, mobile UX. Use for design decisions and UX guidance. For Tailwind CSS use tailwind skill. For shadcn components use shadcn-svelte skill.
license: MIT
compatibility: opencode
metadata:
  author: OpenCode Community
  version: "1.1.0"
---

# Frontend Design (UI/UX for Developers)

Practical UI/UX guidance with strict best-practice enforcement for responsive, accessible interfaces.

## When to Use Me

Use me when:

- Building user interfaces (web, mobile, desktop)
- Designing forms, dashboards, landing pages
- Implementing responsive layouts
- Adding animations or micro-interactions
- Reviewing UI for accessibility issues
- Creating component states (loading, error, empty)
- Setting up design systems

Do not use me for:

- Backend architecture
- Database design
- API development
- Business logic implementation

---

## Non-Negotiable Enforcement Rules

For restyling/design tasks, these rules are mandatory:

1. **Mobile-first is required**: build 375px base first, then enhance with breakpoints.
2. **All domain checks must pass**: mobile, typography, hierarchy, states, forms, interaction, animation, accessibility.
3. **Final deep scan is required**: run domain-by-domain validation and patch gaps before final output.
4. **No partial completion**: if a domain fails, iterate until all critical checks pass.

---

## Workflow (Best-Practice Enforcement)

1. **Analyze requirements**
   - Identify product type and constraints from `references/product-recommendations.csv`
   - Determine primary user action and success metric

2. **Apply mobile-first (VERPLICHT)**
   - Start with mobile base (375px), no desktop-first classes
   - Enforce touch targets >= 44x44 and >= 8px spacing
   - Place primary actions in thumb-friendly zones

3. **Apply typography system**
   - Max 2 fonts
   - Consistent type scale and heading/body contrast
   - Body text min 16px, readable line height

4. **Apply visual hierarchy**
   - Prioritize with size -> color -> weight -> position
   - Keep clear scanning order (headline, key value, CTA, details)

5. **Enhance for larger screens**
   - Add `sm:`, `md:`, `lg:`, `xl:` progressively
   - Validate on 375, 768, 1024, and 1440 widths

6. **Implement component and form states**
   - Component states: default, hover, focus, active, disabled, loading, error, success
   - Form UX: visible labels, field-level errors, correct input types, submit feedback

7. **Review interaction patterns**
   - Apply Fitts's Law (target size/proximity)
   - Apply Hick's Law (limit choices)
   - Add explicit feedback timing for user actions

8. **Apply motion safely**
   - Use short, purposeful motion
   - Animate transform/opacity only
   - Respect reduced-motion preferences

9. **Check accessibility (WCAG 2.1 AA)**
   - Contrast >= 4.5:1 for normal text
   - Visible focus states and keyboard reachability
   - ARIA labels where needed
   - No color-only meaning

10. **Run deep scan and iterate**
    - Run the domain checklist below
    - Fix all failed items
    - Re-scan until zero critical failures

---

## Domain Gate Checklist (Must Pass)

| Domain               | Mandatory Checks                                                                           | Reference                                |
| -------------------- | ------------------------------------------------------------------------------------------ | ---------------------------------------- |
| Mobile UX            | 375px base first, touch >= 44x44, spacing >= 8px, thumb-friendly actions, no desktop-first | `references/mobile-ux.md`                |
| Typography           | Max 2 fonts, min 16px body text, readable line-height, stable type scale                   | `references/typography.md`               |
| Visual Hierarchy     | Size/color/weight/position priorities are clear                                            | `references/visual-hierarchy.md`         |
| Component States     | default/hover/focus/active/disabled/loading/error/success all covered                      | `references/component-states.md`         |
| Forms UX             | Visible labels, input types, validation timing, field-level errors, submit feedback        | `references/forms-ux.md`                 |
| Interaction Patterns | Fitts + Hick + error prevention + timed feedback                                           | `references/interaction-patterns.md`     |
| Animation            | <= 300ms UI motion, transform/opacity only, reduced-motion support                         | `references/animation.md`                |
| Accessibility        | WCAG contrast, focus visibility, ARIA naming, keyboard flow, no color-only signals         | `references/contrast-accessibility.md`   |
| UX Guidelines        | Resolve any high-severity conflicts before final output                                    | `references/ux-guidelines.csv`           |
| Product Fit          | Style direction aligns with product type and context                                       | `references/product-recommendations.csv` |

If any row fails, do not finalize. Fix and re-run the checklist.

---

## Quick Reference

### Component States Checklist

Every interactive component needs:

| State        | Visual                | Code Example                       |
| ------------ | --------------------- | ---------------------------------- |
| **Default**  | Normal appearance     | `class="btn"`                      |
| **Hover**    | Subtle feedback       | `hover:bg-gray-100`                |
| **Focus**    | Visible ring (a11y)   | `focus:ring-2 focus:ring-blue-500` |
| **Active**   | Pressed feedback      | `active:scale-95`                  |
| **Disabled** | Reduced opacity       | `opacity-50 cursor-not-allowed`    |
| **Loading**  | Spinner + disabled    | `disabled spinner`                 |
| **Error**    | Red border + message  | `border-red-500 text-red-600`      |
| **Success**  | Positive confirmation | `text-green-700 border-green-300`  |

### Touch Targets

- **Minimum size**: 44x44px
- **Minimum gap**: 8px between targets
- **Code**: `min-h-[44px] min-w-[44px]`

### Typography Quick Rules

| Element | Size    | Weight   | Line Height |
| ------- | ------- | -------- | ----------- |
| H1      | 32-48px | Bold     | 1.2-1.3     |
| H2      | 24-32px | Semibold | 1.3-1.4     |
| Body    | 16px    | Regular  | 1.5-1.6     |
| Small   | 12-14px | Regular  | 1.4-1.5     |
| Minimum | 12px    | -        | -           |

- **Max fonts**: 2 families
- **Line length**: 65-75ch desktop, 30-40ch mobile

### Color Accessibility

- **Normal text**: 4.5:1 contrast ratio minimum
- **Large text**: 3:1 contrast ratio minimum
- **Never rely on color alone** - add icons or text

### Mobile-First Checklist

Bij elke styling taak:

| Check                      | Voorbeeld                   |
| -------------------------- | --------------------------- |
| ✅ Base = mobile (375px)   | `flex flex-col gap-4 p-4`   |
| ✅ Enhance met breakpoints | `md:flex-row md:gap-8`      |
| ✅ Touch targets ≥ 44px    | `min-h-[44px] min-w-[44px]` |
| ✅ Primary actions bottom  | Fixed bottom nav            |
| ❌ No desktop-first        | Niet `lg:` als basis        |

### Motion Checklist

- UI motion meestal <= 300ms
- Alleen `transform` en `opacity` animeren
- `prefers-reduced-motion` respecteren
- Geen decoratieve oneindige animaties

---

### Mobile-First Regel (Altijd Toepassen)

```
❌ FOUT: Desktop first, dan "fixen" voor mobile
   class="flex-row gap-8 p-8 md:flex-col md:gap-4 md:p-4"

✅ GOED: Mobile base, enhance voor desktop
   class="flex flex-col gap-4 p-4 md:flex-row md:gap-8 md:p-8"
```

**Tailwind volgorde**: base styles (mobile) → `sm:` (640px) → `md:` (768px) → `lg:` (1024px) → `xl:` (1280px)

---

## Key Principles

### 1. Mobile-First (VERPLICHT)

**Bij ELKE styling of restyling taak: begin met mobile (375px), enhance voor grotere schermen.**

Dit is niet optioneel - mobile-first zorgt voor:

- Betere performance (minder CSS op mobile)
- Betere UX (meest beperkte scherm eerst)
- Eenvoudigere code (additive, niet subtractive)

```html
<!-- ❌ FOUT: Desktop first -->
<div class="flex-row gap-8 p-8 md:flex-col md:gap-4 md:p-4"></div>

<!-- ✅ GOED: Mobile first -->
<div class="flex flex-col gap-4 p-4 md:flex-row md:gap-8 md:p-8"></div>
```

**Zie**: `references/mobile-ux.md` voor complete mobile patterns.

### 2. Typography Before Decoration

Text clarity comes before ornamental style:

- Body text stays readable on mobile (>= 16px)
- Heading scale is consistent
- No more than 2 font families
- Paragraph width remains scannable

### 3. Visual Hierarchy

Guide user attention through:

- **Size**: Larger = more important
- **Color**: Darker/vibrant = more attention
- **Weight**: Bolder = stands out
- **Position**: Top/center = noticed first

### 4. Feedback

Every action needs response:

- **Immediate**: Button press, hover state
- **Progress**: Loading spinners, skeletons
- **Completion**: Success toasts, checkmarks
- **Failure**: Error messages with recovery

### 5. Accessibility (WCAG 2.1)

Non-negotiable requirements:

- All images have `alt` text
- All inputs have labels
- All interactive elements have focus states
- Color contrast meets 4.5:1 minimum
- Never convey info by color alone
- Respect reduced-motion settings

---

## Common Patterns

### Form UX

```
✓ Label above input
✓ Error below input
✓ Inline validation on blur
✓ Show/hide password toggle
✓ Appropriate input types (email, tel, number)
✓ Required field indicators
✓ Submit feedback (loading + success/error)
```

### Loading States

```
✓ Skeleton screens for content
✓ Spinners for actions
✓ Progress bars for multi-step
✓ Disable buttons during submission
✓ Reduced-motion fallback
```

### Empty States

```
✓ Clear message explaining why empty
✓ Actionable CTA to fix it
✓ Helpful tips or suggestions
✓ Maintain brand personality
✓ Focusable CTA for keyboard users
```

### Error Handling

```
✓ Clear message what went wrong
✓ Actionable solution
✓ Preserve user input
✓ Don't blame the user
✓ Announce critical errors (`role="alert"`)
```

---

## Anti-Patterns to Avoid

| Don't                    | Do Instead                    |
| ------------------------ | ----------------------------- |
| Remove focus outlines    | Add custom focus styles       |
| Use placeholder as label | Always show visible label     |
| Auto-play video/audio    | Click-to-play only            |
| Infinite animations      | Animate on interaction        |
| Generic "Error occurred" | Specific error with solution  |
| Disable zoom             | Never disable user zoom       |
| Fixed 100vh on mobile    | Use `min-h-dvh`               |
| More than 2 fonts        | Keep typography system simple |
| Animate width/height     | Animate transform/opacity     |

---

## Design Workflow Example: Card Component Restyling

Een praktisch voorbeeld van hoe je een component restyled met mobile-first aanpak.

### Scenario

**Opdracht**: Restyle een simpele ProductCard naar een moderne DashboardCard

**Before (Desktop-first, verouderd)**:

```html
<div class="w-80 h-48 p-6 border rounded shadow-lg flex-row gap-4">
  <img class="w-32 h-32 object-cover" src="product.jpg" />
  <div class="flex-1">
    <h3 class="text-xl font-bold mb-2">Product Naam</h3>
    <p class="text-gray-600 mb-4">Omschrijving...</p>
    <button class="bg-blue-500 text-white px-4 py-2 rounded">Bekijk</button>
  </div>
</div>
```

**Problemen**:

- ❌ Desktop-first (w-80, flex-row als basis)
- ❌ Geen responsive breakpoints
- ❌ Touch target te klein (py-2 < 44px)
- ❌ Geen states (hover, focus, loading)
- ❌ Geen accessibility (geen alt, geen focus ring)

---

### Stap 1: Mobile Base (375px)

Start met de kleinste schermgrootte. Verticale layout, full-width, voldoende touch targets.

```html
<!-- Mobile base - altijd eerst! -->
<article class="p-4 border rounded-lg">
  <img
    class="w-full h-40 object-cover rounded"
    src="product.jpg"
    alt="Product afbeelding"
  />
  <h3 class="mt-3 text-lg font-semibold">Product Naam</h3>
  <p class="mt-2 text-sm text-gray-600 line-clamp-2">Omschrijving...</p>
  <button
    class="mt-4 w-full min-h-[44px] bg-blue-500 text-white rounded font-medium"
  >
    Bekijk details
  </button>
</article>
```

**Toegevoegd**:

- ✅ `alt` voor accessibility
- ✅ `min-h-[44px]` voor touch target
- ✅ `line-clamp-2` voor tekst truncation
- ✅ Verticale layout (mobile default)

---

### Stap 2: Tablet Enhancement (768px+)

Voeg `md:` breakpoints toe. NIET vervangen, alleen uitbreiden.

```html
<article class="p-4 md:p-6 border rounded-lg md:flex md:gap-4">
  <img
    class="w-full h-40 object-cover rounded md:w-48 md:h-auto md:flex-shrink-0"
    src="product.jpg"
    alt="Product afbeelding"
  />
  <div class="mt-3 md:mt-0 md:flex-1 md:flex md:flex-col">
    <h3 class="text-lg font-semibold md:text-xl">Product Naam</h3>
    <p class="mt-2 text-sm text-gray-600 line-clamp-2 md:line-clamp-3">
      Omschrijving...
    </p>
    <div class="mt-auto pt-4">
      <button
        class="w-full min-h-[44px] bg-blue-500 text-white rounded font-medium md:w-auto md:px-6"
      >
        Bekijk details
      </button>
    </div>
  </div>
</article>
```

**Toegevoegd**:

- ✅ `md:flex md:gap-4` - horizontale layout
- ✅ `md:w-48` - vaste afbeelding breedte
- ✅ `md:flex-1 md:flex md:flex-col` - content vult ruimte
- ✅ `mt-auto` - button naar beneden duwen

---

### Stap 3: Desktop Enhancement (1024px+)

Extra polish voor grotere schermen.

```html
<article
  class="
  p-4 md:p-6 lg:p-8
  border rounded-lg 
  md:flex md:gap-4 lg:gap-6
  hover:shadow-lg transition-shadow
  focus-within:ring-2 focus-within:ring-blue-500
"
>
  <img
    class="w-full h-40 object-cover rounded md:w-48 lg:w-56 md:h-auto md:flex-shrink-0"
    src="product.jpg"
    alt="Product afbeelding"
    loading="lazy"
  />
  <div class="mt-3 md:mt-0 md:flex-1 md:flex md:flex-col">
    <h3 class="text-lg font-semibold md:text-xl lg:text-2xl">Product Naam</h3>
    <p class="mt-2 text-sm text-gray-600 line-clamp-2 md:line-clamp-3">
      Omschrijving...
    </p>
    <div class="mt-auto pt-4">
      <button
        class="
        w-full min-h-[44px] 
        bg-blue-500 text-white rounded font-medium 
        md:w-auto md:px-6
        hover:bg-blue-600 active:bg-blue-700
        focus:ring-2 focus:ring-blue-500 focus:ring-offset-2
        transition-colors
      "
      >
        Bekijk details
      </button>
    </div>
  </div>
</article>
```

**Toegevoegd**:

- ✅ `lg:` spacing enhancement
- ✅ `hover:shadow-lg` - card interactie
- ✅ `focus-within:ring` - accessibility
- ✅ `loading="lazy"` - performance
- ✅ Button states: `hover:`, `active:`, `focus:`

---

### Stap 4: States Toevoegen

Alle states voor interactieve elementen.

```html
<!-- Loading state -->
<article class="p-4 md:p-6 border rounded-lg animate-pulse">
  <div class="w-full h-40 bg-gray-200 rounded md:w-48"></div>
  <div class="mt-3 h-6 bg-gray-200 rounded w-3/4"></div>
  <div class="mt-2 h-4 bg-gray-200 rounded w-full"></div>
  <div class="mt-4 h-11 bg-gray-200 rounded"></div>
</article>

<!-- Error state -->
<article class="p-4 md:p-6 border border-red-200 rounded-lg bg-red-50">
  <div class="flex items-center gap-3 text-red-600">
    <svg class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
      />
    </svg>
    <div>
      <h3 class="font-semibold">Kon product niet laden</h3>
      <button class="text-sm underline hover:no-underline">
        Opnieuw proberen
      </button>
    </div>
  </div>
</article>

<!-- Disabled + success action states -->
<div class="flex gap-3 mt-4">
  <button class="min-h-[44px] px-4 rounded bg-gray-300 text-gray-600" disabled>
    Laden...
  </button>
  <button
    class="min-h-[44px] px-4 rounded bg-green-600 text-white hover:bg-green-700 focus:ring-2 focus:ring-green-500"
  >
    Opgeslagen
  </button>
</div>
```

---

### Stap 5: Validatie Checklist

| Check                     | Status                                                           |
| ------------------------- | ---------------------------------------------------------------- |
| ✅ Mobile base (375px)    | Voltooid                                                         |
| ✅ Touch targets ≥ 44px   | `min-h-[44px]`                                                   |
| ✅ Responsive breakpoints | `md:` en `lg:`                                                   |
| ✅ Alle states            | default, hover, active, focus, disabled, loading, error, success |
| ✅ Accessibility          | `alt`, `focus:ring`, semantic HTML                               |
| ✅ Performance            | `loading="lazy"`, geen onnodige animaties                        |
| ✅ Reduced motion         | `motion-reduce:*` of media query                                 |

---

### Samenvatting Workflow

| Stap  | Wat                 | Check                                |
| ----- | ------------------- | ------------------------------------ |
| **1** | Mobile base (375px) | Basis styling zonder breakpoints     |
| **2** | Tablet (768px+)     | `md:` toevoegen, niet vervangen      |
| **3** | Desktop (1024px+)   | `lg:` voor extra polish              |
| **4** | States              | Hover, focus, active, loading, error |
| **5** | Validate            | Alle checks doorlopen                |

---

## Deep Scan Template (Use Before Final Answer)

Run this scan after every restyle/design response:

1. **Mobile UX**: no desktop-first defaults, touch >= 44px, breakpoint progression valid
2. **Typography**: body >= 16px, type scale coherent, max 2 fonts
3. **States**: interactive states + loading + error + success present
4. **Forms** (if present): labels, field errors, input types, submit feedback
5. **Animation**: <= 300ms for UI, transform/opacity only, reduced-motion support
6. **Accessibility**: contrast, focus visibility, ARIA labels, keyboard reachability
7. **Interaction**: clear feedback timing, no dead-end errors, no hidden critical actions
8. **Product fit**: style choice aligns with product type and domain constraints

If any item fails, patch and re-scan. Finalize only when all critical checks pass.

---

## References

For detailed guidance on specific topics:

- **references/visual-hierarchy.md** - Size, color, weight, position
- **references/contrast-accessibility.md** - WCAG compliance, ARIA
- **references/typography.md** - Font selection, sizing, line height
- **references/interaction-patterns.md** - Fitts's Law, Hick's Law
- **references/component-states.md** - All states checklist
- **references/forms-ux.md** - Form design patterns
- **references/mobile-ux.md** - Touch targets, thumb zone
- **references/animation.md** - Micro-interactions, reduced motion
- **references/ux-guidelines.csv** - 99 actionable guidelines
- **references/product-recommendations.csv** - Style by product type
