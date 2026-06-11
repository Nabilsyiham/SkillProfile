import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/providers/products_provider.dart';
import 'package:skill_profile_app/screens/detail_screen.dart';
import 'package:skill_profile_app/screens/widgets/product_card.dart';
import 'package:skill_profile_app/screens/cart_screen.dart';
import 'package:skill_profile_app/screens/login_screen.dart';
import 'package:skill_profile_app/providers/auth_provider.dart';
import 'package:skill_profile_app/utils/responsive_helper.dart';

class ShopScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ShopScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late String _selectedCategory;
  String _searchQuery = '';
  String _sortOption = 'featured';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  final List<String> _categories = [
    'All',
    'Cardigan',
    'Bags',
    'Shoes',
    'Pants',
    'Shirt',
  ];

  final Map<String, String> _sortOptions = {
    'featured': 'Featured',
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'name_asc': 'Name: A-Z',
  };

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              final isLoggedIn = ref.read(authProvider).user != null;
              if (!isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login untuk mengakses keranjang')),
                );
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxWidth(context),
          ),
          child: CustomScrollView(
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              // Filter + Sort Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
                  child: Row(
                    children: [
                      // Filter button
                      PopupMenuButton<String>(
                        initialValue: _selectedCategory,
                        onSelected: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        itemBuilder: (context) {
                          return _categories.map((cat) {
                            return PopupMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  if (_selectedCategory == cat)
                                    const Icon(Icons.check, size: 16)
                                  else
                                    const SizedBox(width: 16),
                                  const SizedBox(width: 8),
                                  Text(cat),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.filter_list, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCategory == 'All' ? 'Filter' : _selectedCategory,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort button
                      PopupMenuButton<String>(
                        initialValue: _sortOption,
                        onSelected: (value) {
                          setState(() {
                            _sortOption = value;
                          });
                        },
                        itemBuilder: (context) {
                          return _sortOptions.entries.map((entry) {
                            return PopupMenuItem(
                              value: entry.key,
                              child: Row(
                                children: [
                                  if (_sortOption == entry.key)
                                    const Icon(Icons.check, size: 16)
                                  else
                                    const SizedBox(width: 16),
                                  const SizedBox(width: 8),
                                  Text(entry.value),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_sortOptions[_sortOption]!),
                        ),
                      ),
                      const Spacer(),
                      productsAsync.when(
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                        data: (products) {
                          final query = _searchQuery.toLowerCase();
                          final count = products.where((p) {
                            final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
                            final matchesSearch = query.isEmpty ||
                                p.name.toLowerCase().contains(query) ||
                                p.category.toLowerCase().contains(query);
                            return matchesCategory && matchesSearch;
                          }).length;
                          return Text(
                            '$count Products',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Product Grid
              productsAsync.when(
                loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
                data: (products) {
                  final query = _searchQuery.toLowerCase();
                  final filteredProducts = products.where((p) {
                    final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
                    final matchesSearch = query.isEmpty ||
                        p.name.toLowerCase().contains(query) ||
                        p.category.toLowerCase().contains(query);
                    return matchesCategory && matchesSearch;
                  }).toList();

                  switch (_sortOption) {
                    case 'price_asc':
                      filteredProducts.sort((a, b) => a.priceAsDouble.compareTo(b.priceAsDouble));
                      break;
                    case 'price_desc':
                      filteredProducts.sort((a, b) => b.priceAsDouble.compareTo(a.priceAsDouble));
                      break;
                    case 'name_asc':
                      filteredProducts.sort((a, b) => a.name.compareTo(b.name));
                      break;
                  }

                  if (filteredProducts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try different keywords or category',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.all(horizontalPadding),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.getGridColumns(context),
                        childAspectRatio: ResponsiveHelper.getChildAspectRatio(context),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductCard(
                            product: filteredProducts[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(product: filteredProducts[index]),
                                ),
                              );
                            },
                          );
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
