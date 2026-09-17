# Interaction Patterns

Design patterns that reduce user effort and improve experience.

## Fitts's Law

**Principle**: Targets closer and larger are faster to click.

### Apply It

- Make important buttons larger
- Place related actions close together
- Use full-width mobile buttons

```html
<!-- Bad: Small, far apart -->
<div class="flex gap-8">
  <button class="px-1 py-0.5 text-xs">Save</button>
  <button class="px-1 py-0.5 text-xs">Cancel</button>
</div>

<!-- Good: Large, close together -->
<div class="flex gap-2">
  <button class="px-4 py-2 min-h-[44px]">Save</button>
  <button class="px-4 py-2 min-h-[44px]">Cancel</button>
</div>
```

## Hick's Law

**Principle**: Fewer choices speed up decision-making.

### Apply It

- Limit menu items to 7±2
- Highlight recommended options
- Use progressive disclosure

```html
<!-- Bad: Too many choices at once -->
<select>
  <option>Select country...</option>
  <!-- 200+ countries -->
</select>

<!-- Good: Popular first, then full list -->
<select>
  <option>Select country...</option>
  <optgroup label="Popular">
    <option>United States</option>
    <option>United Kingdom</option>
    <option>Canada</option>
  </optgroup>
  <optgroup label="All Countries">
    <!-- Full list -->
  </optgroup>
</select>
```

## Miller's Law

**Principle**: Working memory holds ~7 items at once.

### Apply It

- Chunk information into groups
- Use categories and sections
- Break long forms into steps

## Recognition vs Recall

**Principle**: Recognizing is easier than remembering.

### Apply It

- Show recently viewed items
- Use familiar icons with labels
- Provide search suggestions

```html
<!-- Recognition: Show recent searches -->
<input type="search" placeholder="Search..." />
<div class="recent-searches">
  <p class="text-sm text-muted">Recent:</p>
  <button>svelte components</button>
  <button>tailwind dark mode</button>
</div>
```

## Feedback Timing

| Response Time | User Perception | Solution            |
| ------------- | --------------- | ------------------- |
| < 100ms       | Instant         | Direct response     |
| 100ms - 1s    | Slight delay    | Show progress       |
| 1s - 10s      | Waiting         | Loading indicator   |
| > 10s         | Frustrated      | Background + notify |

## Error Prevention

### Before Error Occurs

- Input masks for formatted data
- Confirmation for destructive actions
- Clear constraints shown upfront

### After Error Occurs

- Specific error message
- Suggested solution
- Preserve user input
