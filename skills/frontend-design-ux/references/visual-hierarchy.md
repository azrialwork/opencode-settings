# Visual Hierarchy

Visual hierarchy guides user attention through the interface.

## Key Elements

### Size

- Larger elements attract more attention
- Headings > Body text
- Primary CTA > Secondary buttons

### Color

- Darker and vibrant colors draw focus
- Primary color for CTAs
- Muted colors for less important elements

### Weight

- Bolder fonts stand out
- Use for headings and emphasis
- Don't overuse - selective bolding

### Position

- Elements at top or center get noticed first
- Primary actions in prominent positions
- F-pattern for content-heavy pages

## Common Mistakes

### Don't prioritize unimportant information

- Don't make product images too big, stealing spotlight from details
- Don't highlight less critical information

### Do prioritize important information

1. List features/elements by importance
2. Rank them for the user
3. Use color, size, position, contrast to highlight

## Example: E-commerce Product Card

```
Good hierarchy:
1. Product image (large, top)
2. Product name (bold, prominent)
3. Price (distinct color/weight)
4. Add to cart button (primary CTA)
5. Description (smaller, muted)
```

## Code Example

```html
<!-- Good: Clear hierarchy -->
<div class="product-card">
  <img class="w-full h-48 object-cover" src="..." />
  <h3 class="text-lg font-bold mt-2">Product Name</h3>
  <p class="text-primary font-semibold">$99.00</p>
  <button class="bg-primary text-white px-4 py-2 mt-2">Add to Cart</button>
  <p class="text-sm text-muted-foreground mt-1">Description...</p>
</div>
```
