import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            Icon(Icons.person_outline, size: 80, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 24),
            Text(
              'Welcome to Features & Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to access your profile, wishlist, orders, and more.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
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
                child: const Text('CREATE ACCOUNT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInProfile(BuildContext context, WidgetRef ref, AuthUser user, bool isAdmin) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
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
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: secondary,
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor,
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
          if (!isAdmin) ...[
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
          ],
          if (isAdmin) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'ADMIN',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: secondary,
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
          _buildMenuItem(
            context,
            icon: Icons.palette_outlined,
            title: 'Ubah Warna Tampilan',
            onTap: () {
              _showColorPicker(context, ref);
            },
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: ref.watch(themeProvider).primary,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.surface),
              ),
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
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              }
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
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.secondary),
      onTap: onTap,
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Warna Tema',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Warna akan diterapkan ke seluruh aplikasi',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: colorThemes.map((theme) {
                      final isSelected = currentTheme.name == theme.name;
                      return GestureDetector(
                        onTap: () {
                          ref.read(themeProvider.notifier).setTheme(theme);
                          setState(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 72,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.canvas,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? theme.primary : theme.surface,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: theme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                theme.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: theme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
