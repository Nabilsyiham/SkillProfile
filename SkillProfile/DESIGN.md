# Features & Found - Design System (Consolidated)

This document outlines the visual system for the Features & Found e-commerce store, updated to focus on a premium, soft, and neutral minimalist design (Japandi style).

## 1. Color Palette

All colors are chosen to be soft, warm, and neutral, avoiding harsh grays or plain white backgrounds.

*   **Background (Canvas)**: `#FAF9F5` (Alabaster / Off-White) - Warm, soft background to reduce eye strain.
*   **Surface (Card/Containers)**: `#F3F2EC` (Warm Oat / Stone) - Slightly darker tint for visual bounding of content.
*   **Surface High/Hover**: `#EBEAE3` (Darker Oat / Linen) - Active states or elevated cards.
*   **Primary Accent/CTA**: `#1E1E1C` (Soft Charcoal) - Deep near-black for high-contrast text and primary buttons.
*   **Secondary Text**: `#7B7973` (Muted Pebble Gray) - Softened description text.
*   **Border/Outline**: `#E4E2D9` (Soft Linen border) - Low contrast 1px outline for cards, form fields, and dividers.
*   **Soft Sage Accent**: `#8D9387` (Muted Olive Sage) - Delicate color for success, active tabs, and badges.
*   **Soft Clay Accent**: `#C8C2B8` (Warm Oat-Gray) - Warm accent for category pills.

## 2. Typography

We use **Manrope** exclusively, loaded from Google Fonts:
*   `font-family: 'Manrope', sans-serif;`

### Headings
*   **Display Header**: Light weight, tight letter-spacing, very large (`tracking-tight font-light`).
*   **Section Header**: Medium/Semi-Bold weight, elegant proportion (`font-medium`).

### Body & UI
*   **Body**: Regular weight, generous line-height (`leading-relaxed font-normal`).
*   **Labels/UI Elements**: Medium or Semi-Bold weight, uppercase tracking for labels to keep clean hierarchy.

## 3. Shapes & Border Radius

To maintain a clean architectural aesthetic:
*   **Standard Radius**: `rounded` = `0.25rem` (4px) for small controls, tags, and inputs.
*   **Large Radius**: `rounded-lg` = `0.5rem` (8px) for cards, images, and content sections.
*   **Circular**: `rounded-full` for active indicators and circle badges.

## 4. Spacing

Consistent multi-device spacing unit using Tailwind:
*   `stack-sm` = `8px` (`space-y-2` or `gap-2`)
*   `stack-md` = `24px` (`space-y-6` or `gap-6`)
*   `stack-lg` = `64px` (`space-y-16` or `gap-16`)
*   `margin-desktop` = `80px` (`px-20`)
*   `margin-mobile` = `20px` (`px-5`)
