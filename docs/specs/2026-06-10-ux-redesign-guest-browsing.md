# UX Redesign: Guest Browsing & Unified Navigation

**Date:** 2026-06-10
**Status:** Approved
**Scope:** Flutter app + Web (SkillProfile)

## Problem

Flutter app forces login immediately on open. Users cannot browse products without logging in first. The Flutter UI is also very different from the web version. Admin has completely separate screens.

## Goal

1. Allow guest browsing (view products, search) without login
2. Require login for: cart, wishlist, chat, checkout
3. Unify Flutter navigation to match web (3-tab bottom nav)
4. Admin uses same nav, with admin controls in Profile section
5. Update web to also restrict cart/wishlist for guests
6. Visual consistency between Flutter and web

## User Roles & Access

| Action | Guest | User | Admin |
|--------|-------|------|-------|
| View Homepage | ✅ | ✅ | ✅ |
| Browse Shop | ✅ | ✅ | ✅ |
| View Product Detail | ✅ | ✅ | ✅ |
| Search Products | ✅ | ✅ | ✅ |
| Add to Cart | ❌ Login required | ✅ | ✅ |
| Add to Wishlist | ❌ Login required | ✅ | ✅ |
| Checkout | ❌ Login required | ✅ | ✅ |
| Chat | ❌ Login required | ✅ | ✅ |
| View Order History | ❌ Login required | ✅ | ✅ |
| Manage Products | ❌ | ❌ | ✅ |
| Manage Orders | ❌ | ❌ | ✅ |
| Admin Chat | ❌ | ❌ | ✅ |

## Navigation Structure

### Bottom Navigation (Flutter - All Roles)

```
┌─────────────────────────────────────┐
│          Bottom Navigation          │
│                                     │
│    [Home]    [Shop]    [Profile]    │
│                                     │
└─────────────────────────────────────┘
```

- **3 tabs only**: Home, Shop, Profile
- Same for guest, user, and admin
- Guest: Profile shows "Sign In" prompt
- User: Profile shows user dashboard
- Admin: Profile shows user dashboard + admin controls

### Web Navigation (Updated)

```
Desktop:  [Brand]  Home | Shop | Profile  [Sign In] [Cart]
Mobile:   [☰] [Brand]                    [Cart]
```

- Profile link: guest → login prompt, user → dashboard
- Cart: guest → login prompt, user → cart page
- Wishlist: moved into Profile dashboard (not separate nav)

## Screen Changes

### Flutter

| Current Screen | Change |
|---|---|
| `splash_screen.dart` | Navigate to `/home` always (not `/login`) |
| `login_screen.dart` | Keep as standalone screen (push navigation) |
| `register_screen.dart` | Keep as standalone screen (push navigation) |
| `main_screen.dart` | 3 tabs: Home, Shop, Profile (remove Wishlist tab) |
| `home_screen.dart` | Keep mostly same, add guest-aware cart/chat icons |
| `shop_screen.dart` | Add "login to add cart" prompt for guests |
| `detail_screen.dart` | Hide wishlist/cart buttons for guests, show "Sign In" prompt |
| `profile_screen.dart` | **Complete rewrite**: User Dashboard (like web user_dashboard.html) |
| `wishlist_screen.dart` | Move into Profile dashboard (not a tab) |
| `cart_screen.dart` | Keep, but access from Profile or Home AppBar |
| `chat_screen.dart` | Keep, access from Profile dashboard |
| `order_history_screen.dart` | Move into Profile dashboard |
| `checkout_screen.dart` | Keep as standalone |
| `admin_main_screen.dart` | **DELETE** - admin uses MainScreen |
| `admin_home_screen.dart` | **DELETE** - merged into HomeScreen or removed |
| `admin_products_screen.dart` | **DELETE** - moved to Profile admin section |
| `admin_product_form_screen.dart` | Keep as standalone (push from Profile) |
| `admin_orders_screen.dart` | **DELETE** - moved to Profile admin section |
| `admin_chat_screen.dart` | **DELETE** - admin chat in Profile |
| `admin_chat_detail_screen.dart` | Keep as standalone (push from Profile) |

### Web (SkillProfile)

| Current Page | Change |
|---|---|
| `index.html` | Add guest-aware cart/wishlist buttons |
| `shop.html` | Add "login to add cart" prompt for guests |
| `detail.html` | Hide add-to-cart/wishlist for guests, show "Sign In" prompt |
| `cart.html` | Add "login required" check |
| `wishlist.html` | Move into user_dashboard.html |
| `login.html` | Keep as is |
| `user_dashboard.html` | Add wishlist section, chat section, order history |
| `chat.html` | Add auth check for guests |

## Profile Dashboard Design (Flutter)

### Guest State
```
┌─────────────────────────┐
│      Welcome Back       │
│                         │
│   [Sign In Button]      │
│   [Register Button]     │
│                         │
│   Browse as Guest →     │
└─────────────────────────┘
```

### User State
```
┌─────────────────────────┐
│  ┌──┐  John Doe         │
│  │👤│  john@email.com   │
│  └──┘                   │
├─────────────────────────┤
│  📋 My Orders           │
│  ❤️ Wishlist            │
│  💬 Chat                │
│  🛒 Cart                │
├─────────────────────────┤
│  ⚙️ Settings            │
│  🚪 Sign Out            │
└─────────────────────────┘
```

### Admin State
```
┌─────────────────────────┐
│  ┌──┐  Admin            │
│  │👑│  admin@features.. │
│  └──┘  [ADMIN BADGE]    │
├─────────────────────────┤
│  📋 My Orders           │
│  ❤️ Wishlist            │
│  💬 Chat                │
│  🛒 Cart                │
├─────────────────────────┤
│  --- ADMIN ---          │
│  📦 Manage Products     │
│  📦 Manage Orders       │
│  💬 Admin Chat          │
├─────────────────────────┤
│  ⚙️ Settings            │
│  🚪 Sign Out            │
└─────────────────────────┘
```

## Guest Restriction Logic

### Flutter

When guest tries to add to cart/wishlist:
1. Show SnackBar: "Login untuk menambahkan ke keranjang"
2. Navigate to LoginScreen
3. After login, return to previous screen

### Web

When guest clicks cart/wishlist button:
1. Show modal: "Login required"
2. Button "Login" → redirect to login.html
3. Button "Cancel" → close modal

## Visual Changes

### Color Palette (Match Web)
- Background: `#FAF9F5` (warm canvas)
- Text: `#1E1E1C` (charcoal)
- Accent: `#8D9387` (sage)
- Secondary: `#C4B8A5` (warm sand)

### Typography
- Font: Manrope (Google Fonts)
- Headings: Bold, charcoal
- Body: Regular, charcoal/gray

### Cards & Components
- Rounded corners (12px)
- Subtle shadows
- Warm neutral backgrounds
- Hover/tap scale effects

## Files to Modify

### Flutter
1. `lib/main.dart` - Update routes, remove admin routes
2. `lib/screens/splash_screen.dart` - Always navigate to /home
3. `lib/screens/main_screen.dart` - 3 tabs, remove Wishlist
4. `lib/screens/home_screen.dart` - Guest-aware icons
5. `lib/screens/shop_screen.dart` - Guest cart restriction
6. `lib/screens/detail_screen.dart` - Guest restriction
7. `lib/screens/profile_screen.dart` - Complete rewrite to User Dashboard
8. `lib/screens/cart_screen.dart` - Access from Profile
9. `lib/screens/chat_screen.dart` - Access from Profile
10. `lib/screens/order_history_screen.dart` - Access from Profile
11. `lib/screens/login_screen.dart` - Minor updates
12. `lib/screens/widgets/product_card.dart` - Guest-aware
13. Remove all admin/ screen files (except form and chat detail)

### Web
1. `SkillProfile/index.html` - Guest-aware cart button
2. `SkillProfile/shop.html` - Guest cart restriction
3. `SkillProfile/detail.html` - Guest restriction
4. `SkillProfile/cart.html` - Auth check
5. `SkillProfile/user_dashboard.html` - Add wishlist, chat, order history
6. `SkillProfile/wishlist.html` - Remove or redirect to dashboard
7. `SkillProfile/chat.html` - Auth check for guests

## Migration Notes

- No database changes needed
- Existing API endpoints remain the same
- `role` field in users table stays as is
- Sanctum token auth stays as is
