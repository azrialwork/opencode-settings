# Component States

Every interactive component must have clear visual feedback for all states.

## State Checklist

| State        | Purpose              | Visual                            |
| ------------ | -------------------- | --------------------------------- |
| **Default**  | Normal appearance    | Standard styling                  |
| **Hover**    | Interactive feedback | Background change, cursor pointer |
| **Focus**    | Keyboard navigation  | Visible ring (a11y requirement)   |
| **Active**   | Pressed feedback     | Scale down, darker background     |
| **Disabled** | Not interactive      | Reduced opacity, no cursor        |
| **Loading**  | Processing           | Spinner, disabled interaction     |
| **Error**    | Validation failed    | Red border/text, error icon       |
| **Success**  | Validation passed    | Green check, success message      |

## Button States

```html
<button
  class="
  /* Base */
  px-4 py-2 rounded font-medium
  /* Default */
  bg-primary text-primary-foreground
  /* Hover */
  hover:bg-primary/90
  /* Focus */
  focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2
  /* Active */
  active:scale-[0.98]
  /* Disabled */
  disabled:opacity-50 disabled:cursor-not-allowed
"
>
  Button Text
</button>
```

## Input States

```html
<input
  class="
  /* Base */
  w-full px-3 py-2 rounded border
  /* Default */
  border-input bg-background
  /* Focus */
  focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary
  /* Error */
  data-[error=true]:border-red-500 data-[error=true]:focus:ring-red-500
  /* Disabled */
  disabled:opacity-50 disabled:cursor-not-allowed disabled:bg-muted
"
/>
```

## Card States

```html
<div
  class="
  /* Base */
  rounded-lg border bg-card p-4
  /* Interactive */
  hover:border-primary/50 hover:shadow-sm
  /* Selected */
  data-[selected=true]:border-primary data-[selected=true]:bg-primary/5
  /* Disabled */
  data-[disabled=true]:opacity-50 data-[disabled=true]:pointer-events-none
"
></div>
```

## Loading Patterns

### Button Loading

```html
<button disabled class="relative">
  <span class={loading ? 'opacity-0' : ''}>Submit</span>
  {#if loading}
    <span class="absolute inset-0 flex items-center justify-center">
      <Loader2 class="animate-spin" />
    </span>
  {/if}
</button>
```

### Content Loading

```html
{#if loading}
<div class="animate-pulse">
  <div class="h-4 bg-muted rounded w-3/4 mb-2"></div>
  <div class="h-4 bg-muted rounded w-1/2"></div>
</div>
{:else}
<p>{content}</p>
{/if}
```

## Empty State

```html
<div class="text-center py-12">
  <EmptyIcon class="mx-auto h-12 w-12 text-muted-foreground" />
  <h3 class="mt-4 text-lg font-medium">No items found</h3>
  <p class="mt-2 text-muted-foreground">
    Get started by creating your first item.
  </p>
  <button class="mt-4">Create Item</button>
</div>
```

## Error State

```html
<div class="rounded-lg border border-red-200 bg-red-50 p-4">
  <div class="flex">
    <AlertCircle class="h-5 w-5 text-red-500" />
    <div class="ml-3">
      <h3 class="text-sm font-medium text-red-800">Something went wrong</h3>
      <p class="mt-1 text-sm text-red-700">{errorMessage}</p>
      <button variant="outline" size="sm" class="mt-2">Try again</button>
    </div>
  </div>
</div>
```
