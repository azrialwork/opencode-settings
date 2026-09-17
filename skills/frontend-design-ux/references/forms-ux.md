# Forms UX

Form design patterns that reduce user friction and errors.

## Form Layout

### Label Position

- **Above input** (recommended) - Better for mobile and scanning
- **Left of input** - Only for long forms on wide screens

### Spacing

- 12-16px between label and input
- 24-32px between form groups

```html
<div class="space-y-6">
  <div class="space-y-2">
    <label class="text-sm font-medium" for="email">Email</label>
    <input id="email" type="email" class="..." />
  </div>

  <div class="space-y-2">
    <label class="text-sm font-medium" for="password">Password</label>
    <input id="password" type="password" class="..." />
  </div>
</div>
```

## Input Types

Use appropriate types for better mobile keyboards:

| Data   | Type            | Mobile Keyboard |
| ------ | --------------- | --------------- |
| Email  | `type="email"`  | @ symbol shown  |
| Phone  | `type="tel"`    | Number pad      |
| Number | `type="number"` | Number pad      |
| URL    | `type="url"`    | .com button     |
| Search | `type="search"` | Search button   |

## Validation Patterns

### When to Validate

- **On blur** - After user leaves field (recommended)
- **On submit** - All at once (simplest)
- **On input** - Real-time (for instant feedback)

### Error Display

```html
<div class="space-y-1">
  <input
    id="email"
    type="email"
    class="border-red-500 focus:ring-red-500"
    aria-invalid="true"
    aria-describedby="email-error"
  />
  <p id="email-error" class="text-sm text-red-500" role="alert">
    Please enter a valid email address
  </p>
</div>
```

## Common Patterns

### Password Field

```html
<div class="relative">
  <input
    id="password"
    type={showPassword ? "text" : "password"}
    class="pr-10"
  />
  <button
    type="button"
    class="absolute right-2 top-1/2 -translate-y-1/2"
    onclick={() => (showPassword = !showPassword)}
    aria-label={showPassword ? "Hide password" : "Show password"}
  >
    {showPassword ? <EyeOff /> : <Eye />}
  </button>
</div>
```

### No Confirm Password

Instead of "confirm password" field:

- Use show/hide toggle
- Inline validation feedback
- Password strength indicator

### Verification Code

```html
<div class="flex gap-2">
  {#each Array(6) as _, i}
  <input
    type="text"
    maxlength="1"
    class="w-12 h-12 text-center text-xl"
    bind:value="{code[i]}"
  />
  {/each}
</div>
```

### Search with Clear

```html
<div class="relative">
  <input type="search" placeholder="Search..." class="pl-10 pr-10" />
  <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2" />
  <button
    type="button"
    class="absolute right-3 top-1/2 -translate-y-1/2"
    onclick="clearSearch()"
    aria-label="Clear search"
  >
    <XIcon />
  </button>
</div>
```

## Do/Don't

| Do                            | Don't                   |
| ----------------------------- | ----------------------- |
| Labels above inputs           | Placeholder as label    |
| Inline error messages         | Generic "Invalid input" |
| Show password toggle          | Confirm password field  |
| Autofocus first field         | Autofocus random fields |
| Disable submit during loading | Allow double submission |
| Clear error on input          | Persist error after fix |
| Appropriate input types       | Everything type="text"  |

## Required Fields

```html
<!-- Option 1: Asterisk -->
<label for="email">Email <span class="text-red-500">*</span></label>

<!-- Option 2: Optional label -->
<label for="company">
  Company
  <span class="text-muted-foreground text-sm">(optional)</span>
</label>
```

## Multi-Step Forms

```html
<div class="mb-8">
  <div class="flex items-center">
    <div class="flex items-center">
      <div class="bg-primary text-white">1</div>
      <div class="h-px w-12 bg-muted"></div>
    </div>
    <div class="flex items-center">
      <div class="bg-muted">2</div>
      <div class="h-px w-12 bg-muted"></div>
    </div>
    <div class="flex items-center">
      <div class="bg-muted">3</div>
    </div>
  </div>
</div>
```
