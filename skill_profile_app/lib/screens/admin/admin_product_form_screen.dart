import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../providers/flash_sale_provider.dart';
import '../../services/api_service.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  ConsumerState<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _materialController;
  late TextEditingController _priceController;
  late TextEditingController _imgController;
  late TextEditingController _discountController;
  bool _isLoading = false;
  late bool _isFlashSale;

  static const _defaultColors = ['Charcoal', 'Warm Earth', 'Bone White'];
  static const _defaultSizes = ['XS', 'S', 'M', 'L'];

  late final List<String> _selectedColors;
  late final List<String> _selectedSizes;
  final Map<String, int> _stocks = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['name'] ?? '');
    _categoryController = TextEditingController(text: widget.product?['category'] ?? '');
    _materialController = TextEditingController(text: widget.product?['material'] ?? '');
    _priceController = TextEditingController(text: widget.product?['price']?.toString() ?? '');
    _imgController = TextEditingController(text: widget.product?['img'] ?? '');
    _discountController = TextEditingController(text: widget.product?['discount_percent']?.toString() ?? '0');
    _isFlashSale = widget.product?['is_flash_sale'] == true || widget.product?['is_flash_sale'] == 1;

    final variants = widget.product?['variants'] as List<dynamic>? ?? [];
    if (variants.isNotEmpty) {
      _selectedColors = variants.map((v) => v['color'] as String).toSet().toList();
      _selectedSizes = variants.map((v) => v['size'] as String).toSet().toList();
      for (var v in variants) {
        final key = '${v['color']}_${v['size']}';
        _stocks[key] = v['stock'] as int;
      }
    } else {
      _selectedColors = List.from(_defaultColors);
      _selectedSizes = List.from(_defaultSizes);
      for (var c in _selectedColors) {
        for (var s in _selectedSizes) {
          _stocks['${c}_$s'] = 10;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _materialController.dispose();
    _priceController.dispose();
    _imgController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.product != null;

  int _getStock(String color, String size) {
    return _stocks['${color}_$size'] ?? 0;
  }

  void _setStock(String color, String size, int value) {
    setState(() {
      _stocks['${color}_$size'] = value;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final body = {
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'material': _materialController.text.trim(),
        'price': double.parse(_priceController.text),
        'img': _imgController.text.trim(),
        'is_flash_sale': _isFlashSale,
        'discount_percent': int.tryParse(_discountController.text) ?? 0,
      };

      int productId;
      if (isEditing) {
        await ApiService.put('/admin/products/${widget.product!['id']}', body: body);
        productId = widget.product!['id'];
      } else {
        final result = await ApiService.post('/admin/products', body: body);
        productId = result['id'];
      }

      // Sync variants
      final variants = <Map<String, dynamic>>[];
      for (var color in _selectedColors) {
        for (var size in _selectedSizes) {
          variants.add({
            'color': color,
            'size': size,
            'stock': _getStock(color, size),
          });
        }
      }
      await ApiService.put('/admin/products/$productId/variants', body: {'variants': variants});

      if (mounted) {
        ref.invalidate(adminProductsProvider);
        ref.invalidate(flashSaleProductsProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Produk diperbarui' : 'Produk ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _materialController,
                decoration: const InputDecoration(
                  labelText: 'Material',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imgController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Flash Sale'),
                subtitle: const Text('Tampilkan di bagian Flash Sale di home screen'),
                value: _isFlashSale,
                onChanged: (value) {
                  setState(() {
                    _isFlashSale = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              if (_isFlashSale) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Diskon (%)',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    final val = int.tryParse(v);
                    if (val == null || val < 0 || val > 100) return 'Masukkan 0-100';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              Divider(color: Theme.of(context).colorScheme.surface),
              const SizedBox(height: 16),
              Text(
                'VARIANT & STOK',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Atur stok untuk setiap kombinasi warna dan ukuran. Stok 0 = Sold Out.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildColorSection(),
              const SizedBox(height: 16),
              _buildSizeSection(),
              const SizedBox(height: 16),
              _buildStockTable(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Simpan' : 'Tambah'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Warna', style: TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            TextButton.icon(
              onPressed: _addColor,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedColors.map((color) {
            return Chip(
              label: Text(color),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedColors.remove(color);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Ukuran', style: TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            TextButton.icon(
              onPressed: _addSize,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedSizes.map((size) {
            return Chip(
              label: Text(size),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedSizes.remove(size);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStockTable() {
    if (_selectedColors.isEmpty || _selectedSizes.isEmpty) {
      return const Text('Tambahkan minimal 1 warna dan 1 ukuran');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Warna')),
          const DataColumn(label: Text('Ukuran')),
          DataColumn(
            label: Row(
              children: [
                const Text('Stok '),
                TextButton(
                  onPressed: () {
                    for (var c in _selectedColors) {
                      for (var s in _selectedSizes) {
                        _setStock(c, s, 10);
                      }
                    }
                  },
                  child: const Text('Reset All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
        rows: [
          for (var color in _selectedColors)
            for (var size in _selectedSizes)
              DataRow(cells: [
                DataCell(Text(color)),
                DataCell(Text(size)),
                DataCell(
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: _getStock(color, size).toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        _setStock(color, size, int.tryParse(v) ?? 0);
                      },
                    ),
                  ),
                ),
              ]),
        ],
      ),
    );
  }

  void _addColor() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Warna'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nama warna',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              final color = controller.text.trim();
              if (color.isNotEmpty && !_selectedColors.contains(color)) {
                setState(() {
                  _selectedColors.add(color);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _addSize() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Ukuran'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nama ukuran',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              final size = controller.text.trim();
              if (size.isNotEmpty && !_selectedSizes.contains(size)) {
                setState(() {
                  _selectedSizes.add(size);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
