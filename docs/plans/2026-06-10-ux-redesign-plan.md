# UX Redesign: Guest Browsing & Unified Navigation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow guest browsing without login, unify Flutter navigation to 3-tab bottom nav (Home, Shop, Profile), and match web UX.

**Architecture:** Splash always goes to Home. Guests can browse but not cart/wishlist. Profile shows guest prompt, user dashboard, or admin controls based on auth state.

**Tech Stack:** Flutter, Riverpod, Laravel API, Tailwind CSS (web)

---

## Task 1: Update Routes in main.dart

**Files:**
- Modify: `skill_profile_app/lib/main.dart`

- [ ] **Step 1: Remove /admin route, keep other routes**

```dart
// In main.dart, replace routes block:
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/chat': (context) => const ChatScreen(),
      },
```

Also remove the import for `admin_main_screen.dart`.

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/main.dart`
Expected: No errors

---

## Task 2: Update MainScreen to 3 Tabs

**Files:**
- Modify: `skill_profile_app/lib/screens/main_screen.dart`

- [ ] **Step 1: Replace MainScreen with 3-tab version**

```dart
import 'package:flutter/material.dart';
import 'package:skill_profile_app/screens/home_screen.dart';
import 'package:skill_profile_app/screens/shop_screen.dart';
import 'package:skill_profile_app/screens/profile_screen.dart';
import 'package:skill_profile_app/utils/responsive_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ShopScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: Text('Shop'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/screens/main_screen.dart`
Expected: No errors

---

## Task 3: Rewrite ProfileScreen as User Dashboard

**Files:**
- Create: `skill_profile_app/lib/screens/profile_screen.dart` (replace existing)

- [ ] **Step 1: Write new ProfileScreen with 3 states**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/theme/app_theme.dart';
import 'package:skill_profile_app/providers/auth_provider.dart';
import 'package:skill_profile_app/screens/login_screen.dart';
import 'package:skill_profile_app/screens/order_history_screen.dart';
import 'package:skill_profile_app/screens/chat_screen.dart';
import 'package:skill_profile_app/screens/cart_screen.dart';
import 'package:skill_profile_app/screens/wishlist_screen.dart';
import 'package:skill_profile_app/screens/admin/admin_products_screen.dart';
import 'package:skill_profile_app/screens/admin/admin_orders_screen.dart';
import 'package:skill_profile_app/screens/admin/admin_chat_screen.dart';
import 'package:skill_profile_app/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.user != null;
    final isAdmin = isLoggedIn && authState.user!.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w400,
            color: AppTheme.charcoal,
          ),
        ),
      ),
      body: isLoggedIn
          ? _buildLoggedInProfile(context, ref, authState.user!, isAdmin)
          : _buildGuestPrompt(context),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: AppTheme.pebble),
            const SizedBox(height: 24),
            Text(
              'Welcome to Features & Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.charcoal,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to access your profile, wishlist, orders, and more.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.pebble,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('SIGN IN'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.charcoal,
                  side: const BorderSide(color: AppTheme.linen),
                ),
                child: const Text('CREATE ACCOUNT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInProfile(BuildContext context, WidgetRef ref, AuthUser user, bool isAdmin) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // User Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppTheme.surface,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.charcoal,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppTheme.canvas,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.charcoal,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.pebble,
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.charcoal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: AppTheme.canvas,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Menu Items - Common for all
          _buildMenuItem(
            context,
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.favorite_border,
            title: 'Wishlist',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chat',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.shopping_cart_outlined,
            title: 'Cart',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),

          // Admin Section
          if (isAdmin) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'ADMIN',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.pebble,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Manage Products',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductsScreen()));
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.receipt_long_outlined,
              title: 'Manage Orders',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()));
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.support_agent,
              title: 'Admin Chat',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatScreen()));
              },
            ),
          ],

          const SizedBox(height: 8),

          // Settings
          _buildMenuItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch(
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (_) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              activeThumbColor: AppTheme.charcoal,
            ),
          ),

          const Divider(height: 1, indent: 24, endIndent: 24),

          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Sign Out',
            color: Colors.redAccent,
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.charcoal),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppTheme.charcoal,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.pebble),
      onTap: onTap,
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/screens/profile_screen.dart`
Expected: No errors

---

## Task 4: Add Guest Restriction to ProductCard

**Files:**
- Modify: `skill_profile_app/lib/screens/widgets/product_card.dart`

- [ ] **Step 1: Add auth check to cart and wishlist buttons**

Replace the `onTap` callbacks for wishlist and cart buttons with guest-aware versions:

```dart
// In product_card.dart, add import at top:
import 'package:skill_profile_app/providers/auth_provider.dart';
import 'package:skill_profile_app/screens/login_screen.dart';

// Replace wishlist GestureDetector onTap (line ~59-61):
onTap: () {
  final isLoggedIn = ref.read(authProvider).user != null;
  if (!isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login untuk menambahkan ke wishlist')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    return;
  }
  ref.read(wishlistProvider.notifier).toggleItem(product);
},

// Replace cart GestureDetector onTap (line ~83-98):
onTap: () {
  final isLoggedIn = ref.read(authProvider).user != null;
  if (!isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login untuk menambahkan ke keranjang')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    return;
  }
  ref.read(cartProvider.notifier).addItem(
    CartItem(
      id: DateTime.now().toString(),
      productId: product.id,
      name: product.name,
      specs: product.category,
      price: product.price,
      quantity: 1,
      img: product.img,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${product.name} added to cart')),
  );
},
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/screens/widgets/product_card.dart`
Expected: No errors

---

## Task 5: Add Guest Restriction to DetailScreen

**Files:**
- Modify: `skill_profile_app/lib/screens/detail_screen.dart`

- [ ] **Step 1: Add auth imports**

```dart
// Add at top of detail_screen.dart:
import 'package:skill_profile_app/providers/auth_provider.dart';
import 'package:skill_profile_app/screens/login_screen.dart';
```

- [ ] **Step 2: Replace ADD TO SHOPPING BAG button onPressed**

```dart
// Find the ElevatedButton "ADD TO SHOPPING BAG" and replace onPressed:
onPressed: () {
  final isLoggedIn = ref.read(authProvider).user != null;
  if (!isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login untuk menambahkan ke keranjang')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Added to Shopping Bag')),
  );
},
```

- [ ] **Step 3: Replace wishlist button onPressed**

```dart
// Find the TextButton.icon "ADD TO WISHLIST" and replace onPressed:
onPressed: product != null
    ? () async {
        final isLoggedIn = ref.read(authProvider).user != null;
        if (!isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login untuk menambahkan ke wishlist')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          return;
        }
        if (isInWishlist) {
          await ref.read(wishlistProvider.notifier).removeItem(product.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from wishlist')),
            );
          }
        } else {
          await ref.read(wishlistProvider.notifier).addItem(product);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to wishlist')),
            );
          }
        }
      }
    : null,
```

- [ ] **Step 4: Verify**

Run: `flutter analyze lib/screens/detail_screen.dart`
Expected: No errors

---

## Task 6: Add Guest Restriction to HomeScreen AppBar Icons

**Files:**
- Modify: `skill_profile_app/lib/screens/home_screen.dart`

- [ ] **Step 1: Add auth import**

```dart
// Add at top of home_screen.dart:
import 'package:skill_profile_app/providers/auth_provider.dart';
import 'package:skill_profile_app/screens/login_screen.dart';
```

- [ ] **Step 2: Replace cart badge onPressed**

```dart
// Find IconButton with _buildCartBadge and replace onPressed:
onPressed: () {
  final isLoggedIn = ref.read(authProvider).user != null;
  if (!isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login untuk mengakses keranjang')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    return;
  }
  // Navigate to cart (push cart screen)
},
```

- [ ] **Step 3: Replace chat icon onPressed**

```dart
// Find IconButton with chat_bubble_outline and replace onPressed:
onPressed: () {
  final isLoggedIn = ref.read(authProvider).user != null;
  if (!isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login untuk mengakses chat')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    return;
  }
  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
},
```

- [ ] **Step 4: Replace order history icon onPressed**

```dart
// Find IconButton with receipt_long_outlined and replace onPressed:
onPressed: () {
  final isLoggedIn = ref.read(authProvider).user != null;
  if (!isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login untuk melihat riwayat pesanan')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    return;
  }
  Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
},
```

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/screens/home_screen.dart`
Expected: No errors

---

## Task 7: Add Guest Restriction to Web (shop.html)

**Files:**
- Modify: `SkillProfile/shop.html`

- [ ] **Step 1: Add auth check function**

Find the `<script>` section and add this function before the product rendering code:

```javascript
function isLoggedIn() {
  return localStorage.getItem('auth_token') !== null;
}

function requireLogin(action) {
  if (!isLoggedIn()) {
    if (confirm('Login dulu untuk ' + action + '. Mau login sekarang?')) {
      window.location.href = 'login.html';
    }
    return false;
  }
  return true;
}
```

- [ ] **Step 2: Add auth check to "Add to cart" buttons**

In the product card template, find the "Add to cart" button onclick and wrap with auth check:

```javascript
// Change from:
onclick="addToCart(product)"

// To:
onclick="if(requireLogin('menambahkan ke keranjang')) addToCart(product)"
```

- [ ] **Step 3: Verify**

Open `shop.html` in browser, click "Add to cart" without logging in → should show confirm dialog.

---

## Task 8: Add Guest Restriction to Web (detail.html)

**Files:**
- Modify: `SkillProfile/detail.html`

- [ ] **Step 1: Add auth check function**

Same as Task 7, add `isLoggedIn()` and `requireLogin()` functions in the script section.

- [ ] **Step 2: Add auth check to "Add to Shopping Bag" button**

```javascript
// Change from:
onclick="addToCart(currentProduct)"

// To:
onclick="if(requireLogin('menambahkan ke keranjang')) addToCart(currentProduct)"
```

- [ ] **Step 3: Add auth check to "Add to Wishlist" button**

```javascript
// Change from:
onclick="addToWishlist(currentProduct)"

// To:
onclick="if(requireLogin('menambahkan ke wishlist')) addToWishlist(currentProduct)"
```

- [ ] **Step 4: Verify**

Open `detail.html` in browser, click cart/wishlist buttons without login → should show confirm dialog.

---

## Task 9: Add Auth Check to Web Cart Page

**Files:**
- Modify: `SkillProfile/cart.html`

- [ ] **Step 1: Add auth redirect check**

In the `<script>` section, add at the top:

```javascript
if (localStorage.getItem('auth_token') === null) {
  alert('Silakan login terlebih dahulu untuk mengakses keranjang.');
  window.location.href = 'login.html';
}
```

- [ ] **Step 2: Verify**

Open `cart.html` without login → should redirect to login.html.

---

## Task 10: Add Auth Check to Web Chat Page

**Files:**
- Modify: `SkillProfile/chat.html`

- [ ] **Step 1: Add auth redirect check**

In the `<script>` section, add at the top:

```javascript
if (localStorage.getItem('auth_token') === null) {
  alert('Silakan login terlebih dahulu untuk mengakses chat.');
  window.location.href = 'login.html';
}
```

- [ ] **Step 2: Verify**

Open `chat.html` without login → should redirect to login.html.

---

## Task 11: Update Web Login to Store Token

**Files:**
- Modify: `SkillProfile/login.html`

- [ ] **Step 1: Store token on successful login**

Find the `handleAuthSubmit()` function and add localStorage write:

```javascript
function handleAuthSubmit(e) {
  e.preventDefault();
  // After successful login API call:
  localStorage.setItem('auth_token', 'user_token_here');
  localStorage.setItem('user_role', 'user');
  window.location.href = 'user_dashboard.html';
}
```

Also update `socialLogin()` similarly.

- [ ] **Step 2: Verify**

Login via web → check localStorage has auth_token → navigate to cart should work.

---

## Task 12: Delete Unused Admin Screen Files

**Files:**
- Delete: `skill_profile_app/lib/screens/admin/admin_main_screen.dart`
- Delete: `skill_profile_app/lib/screens/admin/admin_home_screen.dart`

- [ ] **Step 1: Delete admin_main_screen.dart**

```bash
rm skill_profile_app/lib/screens/admin/admin_main_screen.dart
```

- [ ] **Step 2: Delete admin_home_screen.dart**

```bash
rm skill_profile_app/lib/screens/admin/admin_home_screen.dart
```

- [ ] **Step 3: Verify no broken imports**

Run: `flutter analyze`
Expected: No import errors for deleted files

---

## Task 13: Final Verification

- [ ] **Step 1: Run Flutter analyze**

```bash
cd skill_profile_app && flutter analyze
```

Expected: No errors

- [ ] **Step 2: Run Flutter app**

```bash
flutter run
```

Expected behavior:
- App opens → Home screen (no login required)
- Browse Shop → can search/filter products
- Click product → detail page
- Try "Add to Cart" → shows "Login untuk menambahkan ke keranjang" snackbar → navigates to login
- Try wishlist heart → same snackbar → navigates to login
- Login as user → Profile tab shows user dashboard with menu
- Login as admin → Profile tab shows admin menu (Manage Products, Manage Orders, Admin Chat)
- Logout → back to guest state

- [ ] **Step 3: Test Web**

Open `index.html` in browser:
- Browse products without login ✓
- Click "Add to cart" → confirm dialog → redirects to login ✓
- Login → cart/wishlist/chat work ✓
