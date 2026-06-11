# Address Management + Checkout + Order System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete address management system with geolocation, integrate it into checkout, make order history dynamic, add admin notifications, and enable admin order status management — all across Flutter app, Laravel API, and web frontend.

**Architecture:** 
- New `addresses` table stores user addresses with default flag
- Checkout flow changed: address selection → order placement (address fields removed from inline form)
- Order status workflow: pending → processing → shipped → delivered (admin-controlled)
- Admin gets badge notification for new pending orders
- Web order history loads dynamically from API instead of hardcoded data

**Tech Stack:** Laravel 9, Flutter (Riverpod + Freezed), Tailwind CSS, MySQL, Browser Geolocation API + OpenStreetMap Nominatim (free reverse geocoding)

---

## File Structure

### New Files
| File | Responsibility |
|------|---------------|
| `api_backend/database/migrations/2026_06_11_130000_create_addresses_table.php` | Addresses table migration |
| `api_backend/app/Models/Address.php` | Address Eloquent model |
| `api_backend/app/Http/Controllers/AddressController.php` | Address CRUD API controller |
| `skill_profile_app/lib/models/address.dart` | Freezed Address model |
| `skill_profile_app/lib/providers/address_provider.dart` | Address state management |
| `skill_profile_app/lib/screens/address_form_screen.dart` | Add/edit address form with geolocation |
| `skill_profile_app/lib/screens/address_list_screen.dart` | Address list with default toggle |
| `skill_profile_app/lib/screens/order_history_screen.dart` | **REWRITE** - dynamic from API |
| `SkillProfile/addresses.html` | Web address management page |
| `SkillProfile/order_history.html` | Web order history page (dynamic) |

### Modified Files
| File | Changes |
|------|---------|
| `api_backend/routes/api.php` | Add address routes |
| `api_backend/app/Http/Controllers/OrderController.php` | Accept address_id, link to address |
| `api_backend/app/Http/Controllers/AdminOrderController.php` | Add status options, notification count |
| `api_backend/app/Models/Order.php` | Add `address_id` relationship, fix `payment_method` in `$fillable` |
| `skill_profile_app/lib/screens/checkout_screen.dart` | Address selection, remove inline address form |
| `skill_profile_app/lib/screens/admin/admin_orders_screen.dart` | Status update UI |
| `SkillProfile/checkout.html` | Address selection, remove inline form |
| `SkillProfile/user_dashboard.html` | Dynamic order history |
| `SkillProfile/auth.js` | Address helper functions |

---

## Task 1: Database — Create Addresses Table

**Files:**
- Create: `api_backend/database/migrations/2026_06_11_130000_create_addresses_table.php`
- Create: `api_backend/app/Models/Address.php`

- [ ] **Step 1: Create migration**

```php
<?php
// api_backend/database/migrations/2026_06_11_130000_create_addresses_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('addresses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('label')->default('Rumah'); // Rumah, Kantor, etc.
            $table->string('recipient_name');
            $table->string('phone');
            $table->text('address'); // Full address string
            $table->string('city');
            $table->string('province');
            $table->string('postal_code')->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->boolean('is_default')->default(false);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('addresses');
    }
};
```

- [ ] **Step 2: Create Address model**

```php
<?php
// api_backend/app/Models/Address.php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    protected $fillable = [
        'user_id', 'label', 'recipient_name', 'phone',
        'address', 'city', 'province', 'postal_code',
        'latitude', 'longitude', 'is_default',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'is_default' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
```

- [ ] **Step 3: Run migration**

Run: `cd api_backend && php artisan migrate`
Expected: Migration runs successfully

---

## Task 2: Backend — Address CRUD API

**Files:**
- Create: `api_backend/app/Http/Controllers/AddressController.php`
- Modify: `api_backend/routes/api.php`

- [ ] **Step 1: Create AddressController**

```php
<?php
// api_backend/app/Http/Controllers/AddressController.php
namespace App\Http\Controllers;

use App\Models\Address;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    // GET /addresses — List user's addresses
    public function index(Request $request)
    {
        $addresses = Address::where('user_id', $request->user()->id)
            ->orderByDesc('is_default')
            ->orderByDesc('updated_at')
            ->get();
        return response()->json(['addresses' => $addresses]);
    }

    // POST /addresses — Create address
    public function store(Request $request)
    {
        $request->validate([
            'label' => 'required|string|max:50',
            'recipient_name' => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'address' => 'required|string',
            'city' => 'required|string|max:100',
            'province' => 'required|string|max:100',
            'postal_code' => 'nullable|string|max:10',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_default' => 'boolean',
        ]);

        // If setting as default, unset other defaults
        if ($request->is_default) {
            Address::where('user_id', $request->user()->id)
                ->where('is_default', true)
                ->update(['is_default' => false]);
        }

        // If this is the user's first address, make it default
        $addressCount = Address::where('user_id', $request->user()->id)->count();
        if ($addressCount === 0) {
            $request->merge(['is_default' => true]);
        }

        $address = Address::create([
            'user_id' => $request->user()->id,
            'label' => $request->label,
            'recipient_name' => $request->recipient_name,
            'phone' => $request->phone,
            'address' => $request->address,
            'city' => $request->city,
            'province' => $request->province,
            'postal_code' => $request->postal_code,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'is_default' => $request->is_default ?? false,
        ]);

        return response()->json(['address' => $address], 201);
    }

    // PUT /addresses/{id} — Update address
    public function update(Request $request, $id)
    {
        $address = Address::where('user_id', $request->user()->id)->findOrFail($id);

        $request->validate([
            'label' => 'required|string|max:50',
            'recipient_name' => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'address' => 'required|string',
            'city' => 'required|string|max:100',
            'province' => 'required|string|max:100',
            'postal_code' => 'nullable|string|max:10',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_default' => 'boolean',
        ]);

        if ($request->is_default) {
            Address::where('user_id', $request->user()->id)
                ->where('id', '!=', $id)
                ->update(['is_default' => false]);
        }

        $address->update($request->only([
            'label', 'recipient_name', 'phone', 'address',
            'city', 'province', 'postal_code',
            'latitude', 'longitude', 'is_default',
        ]));

        return response()->json(['address' => $address]);
    }

    // DELETE /addresses/{id}
    public function destroy(Request $request, $id)
    {
        $address = Address::where('user_id', $request->user()->id)->findOrFail($id);
        $wasDefault = $address->is_default;
        $address->delete();

        // If deleted address was default, set most recent as default
        if ($wasDefault) {
            $mostRecent = Address::where('user_id', $request->user()->id)
                ->latest()
                ->first();
            if ($mostRecent) {
                $mostRecent->update(['is_default' => true]);
            }
        }

        return response()->json(['message' => 'Address deleted']);
    }

    // PUT /addresses/{id}/default — Set as default
    public function setDefault(Request $request, $id)
    {
        $address = Address::where('user_id', $request->user()->id)->findOrFail($id);

        Address::where('user_id', $request->user()->id)
            ->update(['is_default' => false]);

        $address->update(['is_default' => true]);

        return response()->json(['message' => 'Default address updated']);
    }
}
```

- [ ] **Step 2: Add routes**

Add to `api_backend/routes/api.php` inside the auth:sanctum group:

```php
// Address management
Route::get('/addresses', [AddressController::class, 'index']);
Route::post('/addresses', [AddressController::class, 'store']);
Route::put('/addresses/{id}', [AddressController::class, 'update']);
Route::delete('/addresses/{id}', [AddressController::class, 'destroy']);
Route::put('/addresses/{id}/default', [AddressController::class, 'setDefault']);
```

- [ ] **Step 3: Test API**

Run: `cd api_backend && php artisan tinker --execute="echo 'Routes registered';"`
Test: `curl -X GET http://localhost:8000/api/addresses -H "Authorization: Bearer {token}"`
Expected: `{"addresses":[]}`

---

## Task 3: Backend — Fix Order Model & Add address_id

**Files:**
- Modify: `api_backend/database/migrations/2026_06_11_130001_add_address_id_to_orders_table.php` (CREATE)
- Modify: `api_backend/app/Models/Order.php`
- Modify: `api_backend/app/Http/Controllers/OrderController.php`
- Modify: `api_backend/app/Http/Controllers/AdminOrderController.php`

- [ ] **Step 1: Create migration for address_id**

```php
<?php
// api_backend/database/migrations/2026_06_11_130001_add_address_id_to_orders_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->foreignId('address_id')->nullable()->after('user_id')->constrained()->nullOnDelete();
        });
    }

    public function down()
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['address_id']);
            $table->dropColumn('address_id');
        });
    }
};
```

- [ ] **Step 2: Fix Order model**

```php
<?php
// api_backend/app/Models/Order.php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'user_id', 'address_id', 'total_price', 'status',
        'address', 'phone', 'payment_method',
    ];

    protected $casts = [
        'total_price' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function address()
    {
        return $this->belongsTo(Address::class);
    }
}
```

- [ ] **Step 3: Update OrderController to accept address_id**

In `OrderController@store`, change the validation and create to:

```php
public function store(Request $request)
{
    $request->validate([
        'address_id' => 'required|exists:addresses,id',
        'phone' => 'required|string',
        'payment_method' => 'required|string|in:cod,transfer,ewallet',
        'items' => 'required|array|min:1',
        'items.*.product_id' => 'required|exists:products,id',
        'items.*.quantity' => 'required|integer|min:1',
        'items.*.color' => 'required|string',
        'items.*.size' => 'required|string',
    ]);

    $address = \App\Models\Address::where('user_id', $request->user()->id)
        ->where('id', $request->address_id)
        ->firstOrFail();

    $totalPrice = 0;
    foreach ($request->items as $item) {
        $product = \App\Models\Product::findOrFail($item['product_id']);
        $totalPrice += $product->price * $item['quantity'];
    }

    // Add shipping fee
    $shippingFee = $totalPrice < 250000 ? 15000 : 0;
    $totalPrice += $shippingFee;

    $order = \App\Models\Order::create([
        'user_id' => $request->user()->id,
        'address_id' => $request->address_id,
        'total_price' => $totalPrice,
        'status' => 'pending',
        'address' => $address->address . ', ' . $address->city . ', ' . $address->province,
        'phone' => $request->phone,
        'payment_method' => $request->payment_method,
    ]);

    foreach ($request->items as $item) {
        \App\Models\OrderItem::create([
            'order_id' => $order->id,
            'product_id' => $item['product_id'],
            'quantity' => $item['quantity'],
            'price' => \App\Models\Product::find($item['product_id'])->price,
            'color' => $item['color'],
            'size' => $item['size'],
        ]);

        // Decrement stock
        $variant = \App\Models\ProductVariant::where('product_id', $item['product_id'])
            ->where('color', $item['color'])
            ->where('size', $item['size'])
            ->first();
        if ($variant && $variant->stock >= $item['quantity']) {
            $variant->decrement('stock', $item['quantity']);
        }
    }

    return response()->json([
        'message' => 'Order placed successfully',
        'order' => $order->load('items.product'),
    ], 201);
}
```

- [ ] **Step 4: Update AdminOrderController with status workflow**

```php
<?php
// api_backend/app/Http/Controllers/AdminOrderController.php
namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;

class AdminOrderController extends Controller
{
    public function index()
    {
        $orders = Order::with('user', 'items.product', 'address')
            ->latest()
            ->get();
        return response()->json(['orders' => $orders]);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,processing,shipped,delivered,cancelled',
        ]);

        $order = Order::findOrFail($id);
        $order->update(['status' => $request->status]);

        return response()->json([
            'message' => 'Status updated',
            'order' => $order->load('user', 'items.product'),
        ]);
    }

    // GET /admin/orders/pending-count — For notification badge
    public function pendingCount()
    {
        $count = Order::where('status', 'pending')->count();
        return response()->json(['count' => $count]);
    }
}
```

- [ ] **Step 5: Add pending count route**

Add to `api_backend/routes/api.php` in admin group:

```php
Route::get('/admin/orders/pending-count', [AdminOrderController::class, 'pendingCount']);
```

- [ ] **Step 6: Run migration**

Run: `cd api_backend && php artisan migrate`
Expected: Migration creates address_id column

---

## Task 4: Flutter — Address Model & Provider

**Files:**
- Create: `skill_profile_app/lib/models/address.dart`
- Create: `skill_profile_app/lib/providers/address_provider.dart`

- [ ] **Step 1: Create Address model**

```dart
// skill_profile_app/lib/models/address.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
class Address with _$Address {
  const factory Address({
    required dynamic id,
    @JsonKey(name: 'user_id') required dynamic userId,
    @Default('Rumah') String label,
    @JsonKey(name: 'recipient_name') required String recipientName,
    required String phone,
    required String address,
    required String city,
    required String province,
    @JsonKey(name: 'postal_code') String? postalCode,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}
```

- [ ] **Step 2: Create Address provider**

```dart
// skill_profile_app/lib/providers/address_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class AddressNotifier extends StateNotifier<AsyncValue<List<Address>>> {
  AddressNotifier() : super(const AsyncValue.loading()) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    state = const AsyncValue.loading();
    try {
      final result = await ApiService.get('/addresses');
      final list = (result['addresses'] as List)
          .map((e) => Address.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    try {
      await ApiService.post('/addresses', body: data);
      await loadAddresses();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAddress(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.put('/addresses/$id', body: data);
      await loadAddresses();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAddress(int id) async {
    try {
      await ApiService.delete('/addresses/$id');
      await loadAddresses();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setDefault(int id) async {
    try {
      await ApiService.put('/addresses/$id/default');
      await loadAddresses();
      return true;
    } catch (_) {
      return false;
    }
  }

  Address? get defaultAddress {
    final addresses = state.valueOrNull ?? [];
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, AsyncValue<List<Address>>>((ref) {
  return AddressNotifier();
});
```

- [ ] **Step 3: Run build_runner**

Run: `cd skill_profile_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates address.freezed.dart and address.g.dart

---

## Task 5: Flutter — Address Form Screen with Geolocation

**Files:**
- Create: `skill_profile_app/lib/screens/address_form_screen.dart`

- [ ] **Step 1: Create address form screen**

```dart
// skill_profile_app/lib/screens/address_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/address_provider.dart';
import '../models/address.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  final Address? address; // null = add, non-null = edit

  const AddressFormScreen({super.key, this.address});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: 'Rumah');
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isDefault = false;
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final a = widget.address!;
      _labelController.text = a.label;
      _nameController.text = a.recipientName;
      _phoneController.text = a.phone;
      _addressController.text = a.address;
      _cityController.text = a.city;
      _provinceController.text = a.province;
      _postalCodeController.text = a.postalCode ?? '';
      _isDefault = a.isDefault;
      _latitude = a.latitude;
      _longitude = a.longitude;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak permanen. Aktifkan di pengaturan.')),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _addressController.text =
              '${place.street ?? ''}, ${place.subLocality ?? ''}'.trim();
          _cityController.text = place.subAdministrativeArea ?? place.locality ?? '';
          _provinceController.text = place.administrativeArea ?? '';
          _postalCodeController.text = place.postalCode ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendeteksi lokasi: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'label': _labelController.text,
      'recipient_name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'province': _provinceController.text,
      'postal_code': _postalCodeController.text,
      'latitude': _latitude,
      'longitude': _longitude,
      'is_default': _isDefault,
    };

    bool success;
    if (widget.address != null) {
      success = await ref
          .read(addressProvider.notifier)
          .updateAddress(widget.address!.id, data);
    } else {
      success = await ref.read(addressProvider.notifier).addAddress(data);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan alamat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address != null ? 'Edit Alamat' : 'Tambah Alamat'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Location detection button
            OutlinedButton.icon(
              onPressed: _isLoadingLocation ? null : _detectLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isLoadingLocation
                  ? 'Mendeteksi lokasi...'
                  : 'Izinkan Akses Lokasi'),
            ),
            const SizedBox(height: 16),

            // Label (Rumah, Kantor, etc.)
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label (Rumah, Kantor, etc.)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Recipient name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap Penerima',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
                prefixText: '+62 ',
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // Address
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
                border: OutlineInputBorder(),
                hintText: 'Jl. Contoh No. 123, RT/RW',
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // City & Province
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Kota/Kabupaten',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _provinceController,
                    decoration: const InputDecoration(
                      labelText: 'Provinsi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Postal code
            TextFormField(
              controller: _postalCodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kode Pos (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Default toggle
            SwitchListTile(
              title: const Text('Tetapkan sebagai alamat default'),
              subtitle: const Text('Alamat ini akan dipilih otomatis saat checkout'),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.address != null ? 'Simpan Perubahan' : 'Tambah Alamat',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Add geocoding package to pubspec.yaml**

Add to `skill_profile_app/pubspec.yaml` under dependencies:
```yaml
  geolocator: ^10.1.0
  geocoding: ^2.1.1
```

Run: `cd skill_profile_app && flutter pub get`

---

## Task 6: Flutter — Address List Screen

**Files:**
- Create: `skill_profile_app/lib/screens/address_list_screen.dart`

- [ ] **Step 1: Create address list screen**

```dart
// skill_profile_app/lib/screens/address_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/address_provider.dart';
import '../models/address.dart';
import 'address_form_screen.dart';

class AddressListScreen extends ConsumerWidget {
  final bool selectMode; // true = tap to select, false = manage

  const AddressListScreen({super.key, this.selectMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectMode ? 'Pilih Alamat' : 'Alamat Saya'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressFormScreen()),
          );
          if (result == true) {
            ref.read(addressProvider.notifier).loadAddresses();
          }
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('Belum ada alamat', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Tekan + untuk menambah alamat baru'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return _AddressCard(
                address: addr,
                selectMode: selectMode,
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddressFormScreen(address: addr),
                    ),
                  );
                  if (result == true) {
                    ref.read(addressProvider.notifier).loadAddresses();
                  }
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Alamat?'),
                      content: const Text('Alamat ini akan dihapus permanen.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(addressProvider.notifier).deleteAddress(addr.id);
                  }
                },
                onSetDefault: () {
                  ref.read(addressProvider.notifier).setDefault(addr.id);
                },
                onSelect: selectMode ? () => Navigator.pop(context, addr) : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool selectMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback? onSelect;

  const _AddressCard({
    required this.address,
    required this.selectMode,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: address.isDefault
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      address.label,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                  const Spacer(),
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (!address.isDefault)
                        const PopupMenuItem(value: 'default', child: Text('Set Default')),
                      const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'default') onSetDefault();
                      if (v == 'delete') onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(address.recipientName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(address.phone),
              const SizedBox(height: 4),
              Text(
                '${address.address}, ${address.city}, ${address.province}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Task 7: Flutter — Update Checkout Screen

**Files:**
- Modify: `skill_profile_app/lib/screens/checkout_screen.dart`

- [ ] **Step 1: Rewrite checkout screen**

The checkout screen should show:
1. Address selection card (tap to choose/change)
2. Payment method
3. Order summary
4. Place order button

```dart
// skill_profile_app/lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../models/address.dart';
import '../services/api_service.dart';
import 'address_list_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = false;
  String _selectedPayment = 'cod';
  Address? _selectedAddress;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cod', 'label': 'Bayar di Tempat (COD)', 'icon': Icons.money},
    {'value': 'transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'value': 'ewallet', 'label': 'E-Wallet (GoPay/OVO)', 'icon': Icons.phone_android},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-select default address
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addr = ref.read(addressProvider.notifier).defaultAddress;
      if (addr != null && _selectedAddress == null) {
        setState(() => _selectedAddress = addr);
      }
    });
  }

  Map<String, String> _parseSpecs(String specs) {
    final parts = specs.split(' / ');
    if (parts.length >= 2) {
      return {'color': parts[0].trim(), 'size': parts[1].trim()};
    }
    return {'color': specs, 'size': ''};
  }

  Future<bool> _validateStock() async {
    final cartState = ref.read(cartProvider);
    for (var data in cartState.items) {
      try {
        final result = await ApiService.get('/products/${data.item.productId}/variants');
        final variants = result is List ? result : (result['variants'] ?? []);
        final specs = _parseSpecs(data.item.specs);
        bool found = false;
        for (var v in variants) {
          if (v['color']?.toString().toUpperCase() == specs['color']?.toUpperCase() &&
              v['size']?.toString().toUpperCase() == specs['size']?.toUpperCase() &&
              (v['stock'] ?? 0) >= data.item.quantity) {
            found = true;
            break;
          }
        }
        if (!found) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${data.item.name} (${specs['color']}/${specs['size']}) stok tidak cukup')),
            );
          }
          return false;
        }
      } catch (_) {}
    }
    return true;
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pengiriman terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (!await _validateStock()) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final cartState = ref.read(cartProvider);
      final items = cartState.items.map((data) {
        final specs = _parseSpecs(data.item.specs);
        return {
          'product_id': int.parse(data.item.productId),
          'quantity': data.item.quantity,
          'color': specs['color'],
          'size': specs['size'],
        };
      }).toList();

      await ApiService.post('/orders', body: {
        'address_id': _selectedAddress!.id,
        'phone': _selectedAddress!.phone,
        'payment_method': _selectedPayment,
        'items': items,
      });

      await ref.read(cartProvider.notifier).clearCart();
      await ref.read(addressProvider.notifier).loadAddresses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Address selection
          Text('Alamat Pengiriman', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _selectedAddress != null
              ? InkWell(
                  onTap: () async {
                    final addr = await Navigator.push<Address>(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressListScreen(selectMode: true)),
                    );
                    if (addr != null) setState(() => _selectedAddress = addr);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(_selectedAddress!.label,
                                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    if (_selectedAddress!.isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Default', style: TextStyle(color: Colors.green, fontSize: 10)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(_selectedAddress!.recipientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(_selectedAddress!.phone),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedAddress!.address}, ${_selectedAddress!.city}, ${_selectedAddress!.province}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: () async {
                    final addr = await Navigator.push<Address>(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressListScreen(selectMode: true)),
                    );
                    if (addr != null) setState(() => _selectedAddress = addr);
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Tambah Alamat Pengiriman'),
                ),

          const SizedBox(height: 24),

          // Payment method
          Text('Metode Pembayaran', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._paymentMethods.map((pm) => RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(pm['icon'] as IconData, size: 20),
                    const SizedBox(width: 8),
                    Text(pm['label'] as String),
                  ],
                ),
                value: pm['value'] as String,
                groupValue: _selectedPayment,
                onChanged: (v) => setState(() => _selectedPayment = v!),
              )),

          const SizedBox(height: 24),

          // Order summary
          Text('Ringkasan Pesanan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...cartState.items.map((data) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Text('${data.item.specs} x${data.item.quantity}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                            Text('Rp${(data.item.price * data.item.quantity).toStringAsFixed(0)}'),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('Rp${cartState.subtotal.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ongkos Kirim'),
                      Text(cartState.shippingFee > 0
                          ? 'Rp${cartState.shippingFee.toStringAsFixed(0)}'
                          : 'GRATIS'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Rp${cartState.total.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Place order button
          ElevatedButton(
            onPressed: _isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Buat Pesanan', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add geolocator and geocoding to pubspec.yaml**

```yaml
dependencies:
  geolocator: ^10.1.0
  geocoding: ^2.1.1
```

Run: `cd skill_profile_app && flutter pub get`

---

## Task 8: Flutter — Admin Order Status Management

**Files:**
- Modify: `skill_profile_app/lib/screens/admin/admin_orders_screen.dart`

- [ ] **Step 1: Update admin orders screen with status update**

Read the existing file first, then add status update functionality:

```dart
// Add this method inside the admin orders screen
Future<void> _updateOrderStatus(int orderId, String newStatus) async {
  try {
    await ApiService.put('/admin/orders/$orderId/status', body: {
      'status': newStatus,
    });
    setState(() {}); // Refresh
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diperbarui ke $newStatus')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }
}
```

Add a status dropdown to each order card:
```dart
// In the order card, replace static status badge with dropdown
DropdownButton<String>(
  value: order['status'],
  items: const [
    DropdownMenuItem(value: 'pending', child: Text('Menunggu')),
    DropdownMenuItem(value: 'processing', child: Text('Diproses')),
    DropdownMenuItem(value: 'shipped', child: Text('Dikirim')),
    DropdownMenuItem(value: 'delivered', child: Text('Selesai')),
    DropdownMenuItem(value: 'cancelled', child: Text('Dibatalkan')),
  ],
  onChanged: (v) {
    if (v != null) _updateOrderStatus(order['id'], v);
  },
),
```

- [ ] **Step 2: Update OrderController status enum**

In `OrderController` migration or manually, update the enum to include `processing` and `delivered`:

```php
// Run in tinker or create migration
DB::statement("ALTER TABLE orders MODIFY COLUMN status ENUM('pending','processing','shipped','delivered','cancelled') DEFAULT 'pending'");
```

---

## Task 9: Web — Address Management Page

**Files:**
- Create: `SkillProfile/addresses.html`

- [ ] **Step 1: Create addresses.html**

Full HTML page with:
- List of addresses (fetched from API)
- "Tambah Alamat" button → modal form
- Edit/Delete/Set Default buttons per address
- Geolocation button (Browser Geolocation API + Nominatim reverse geocoding)
- Same layout/style as other pages

Key JavaScript functions:
```javascript
// Load addresses
async function loadAddresses() {
  const result = await apiRequest('/addresses');
  renderAddresses(result.addresses);
}

// Add address
async function addAddress(data) {
  await apiRequest('/addresses', { method: 'POST', body: JSON.stringify(data) });
  loadAddresses();
}

// Get user location
async function detectLocation() {
  return new Promise((resolve, reject) => {
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        const { latitude, longitude } = pos.coords;
        // Reverse geocode using Nominatim
        const res = await fetch(`https://nominatim.openstreetmap.org/reverse?lat=${latitude}&lon=${longitude}&format=json`);
        const data = await res.json();
        resolve({
          latitude, longitude,
          address: data.address.road || '',
          city: data.address.city || data.address.county || '',
          province: data.address.state || '',
          postal_code: data.address.postcode || '',
        });
      },
      (err) => reject(err),
      { enableHighAccuracy: true }
    );
  });
}
```

- [ ] **Step 2: Add address link to navigation**

Add "Alamat Saya" link to the sidebar in `user_dashboard.html`.

---

## Task 10: Web — Dynamic Order History

**Files:**
- Modify: `SkillProfile/user_dashboard.html`
- Create: `SkillProfile/order_history.html`

- [ ] **Step 1: Create order_history.html**

Full HTML page that fetches orders from API and displays them dynamically:

```javascript
async function loadOrders() {
  const result = await apiRequest('/orders');
  renderOrders(result); // result is array of orders
}

function renderOrders(orders) {
  const container = document.getElementById('orders-list');
  if (orders.length === 0) {
    container.innerHTML = '<p class="text-center text-gray-500 py-8">Belum ada pesanan</p>';
    return;
  }
  container.innerHTML = orders.map(order => `
    <div class="bg-white rounded-lg shadow p-6 mb-4">
      <div class="flex justify-between items-start mb-4">
        <div>
          <p class="font-bold">#${order.id}</p>
          <p class="text-sm text-gray-500">${new Date(order.created_at).toLocaleDateString('id-ID')}</p>
        </div>
        <span class="px-3 py-1 rounded-full text-sm ${getStatusColor(order.status)}">
          ${getStatusText(order.status)}
        </span>
      </div>
      ${order.items.map(item => `
        <div class="flex items-center gap-3 py-2 border-t">
          <img src="${item.product?.img || ''}" class="w-12 h-12 object-cover rounded">
          <div class="flex-1">
            <p class="font-medium">${item.product?.name || 'Product'}</p>
            <p class="text-sm text-gray-500">${item.color} / ${item.size} x${item.quantity}</p>
          </div>
          <p>Rp${(item.price * item.quantity).toLocaleString('id-ID')}</p>
        </div>
      `).join('')}
      <div class="border-t mt-4 pt-4 flex justify-between font-bold">
        <span>Total</span>
        <span>Rp${Number(order.total_price).toLocaleString('id-ID')}</span>
      </div>
    </div>
  `).join('');
}

function getStatusColor(status) {
  const colors = {
    pending: 'bg-yellow-100 text-yellow-800',
    processing: 'bg-blue-100 text-blue-800',
    shipped: 'bg-indigo-100 text-indigo-800',
    delivered: 'bg-green-100 text-green-800',
    cancelled: 'bg-red-100 text-red-800',
  };
  return colors[status] || 'bg-gray-100 text-gray-800';
}

function getStatusText(status) {
  const texts = {
    pending: 'Menunggu',
    processing: 'Diproses',
    shipped: 'Dikirim',
    delivered: 'Selesai',
    cancelled: 'Dibatalkan',
  };
  return texts[status] || status;
}
```

- [ ] **Step 2: Update user_dashboard.html to load orders dynamically**

Replace hardcoded orders with API fetch:
```javascript
// In user_dashboard.html, replace hardcoded orders section
async function loadRecentOrders() {
  try {
    const orders = await apiRequest('/orders');
    const container = document.getElementById('recent-orders');
    if (orders.length === 0) {
      container.innerHTML = '<p class="text-gray-500 text-center py-4">Belum ada pesanan</p>';
      return;
    }
    container.innerHTML = orders.slice(0, 3).map(order => `
      <div class="flex items-center gap-4 py-3 border-b">
        <div class="flex-1">
          <p class="font-medium">#${order.id}</p>
          <p class="text-sm text-gray-500">${order.items.length} item</p>
        </div>
        <span class="text-sm ${getStatusColor(order.status)}">${getStatusText(order.status)}</span>
        <p class="font-medium">Rp${Number(order.total_price).toLocaleString('id-ID')}</p>
      </div>
    `).join('');
  } catch (e) {
    console.error('Failed to load orders:', e);
  }
}
```

---

## Task 11: Web — Checkout with Address Selection

**Files:**
- Modify: `SkillProfile/checkout.html`

- [ ] **Step 1: Replace inline address form with address selector**

Remove the textarea/address fields from checkout.html. Replace with:

```html
<!-- Address selection -->
<div class="mb-6">
  <h3 class="font-bold text-lg mb-3">Alamat Pengiriman</h3>
  <div id="selected-address">
    <!-- Loaded dynamically -->
  </div>
  <button onclick="openAddressSelector()" class="mt-2 text-amber-700 underline text-sm">
    Ganti Alamat
  </button>
</div>

<!-- Address selector modal -->
<div id="address-modal" class="hidden fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
  <div class="bg-white rounded-lg p-6 w-full max-w-md max-h-[80vh] overflow-y-auto">
    <h3 class="font-bold text-lg mb-4">Pilih Alamat</h3>
    <div id="address-list"></div>
    <button onclick="closeAddressModal()" class="mt-4 w-full py-2 border rounded">Tutup</button>
  </div>
</div>
```

```javascript
// In checkout page JavaScript
let selectedAddress = null;

async function loadCheckoutAddresses() {
  const result = await apiRequest('/addresses');
  const defaultAddr = result.addresses.find(a => a.is_default) || result.addresses[0];
  if (defaultAddr) selectAddress(defaultAddr);
  window._addresses = result.addresses;
}

function selectAddress(addr) {
  selectedAddress = addr;
  document.getElementById('selected-address').innerHTML = `
    <div class="bg-amber-50 border-2 border-amber-600 rounded-lg p-4">
      <div class="flex items-center gap-2 mb-2">
        <span class="bg-amber-100 text-amber-700 px-2 py-1 rounded text-xs font-bold">${addr.label}</span>
        ${addr.is_default ? '<span class="bg-green-100 text-green-700 px-2 py-1 rounded text-xs font-bold">Default</span>' : ''}
      </div>
      <p class="font-bold">${addr.recipient_name}</p>
      <p class="text-sm">${addr.phone}</p>
      <p class="text-sm text-gray-600">${addr.address}, ${addr.city}, ${addr.province}</p>
    </div>
  `;
}

function openAddressSelector() {
  const list = document.getElementById('address-list');
  list.innerHTML = (window._addresses || []).map(addr => `
    <div class="border rounded-lg p-4 mb-3 cursor-pointer hover:border-amber-600"
         onclick="selectAddress(${JSON.stringify(addr).replace(/"/g, '&quot;')}); closeAddressModal();">
      <div class="flex items-center gap-2 mb-1">
        <span class="bg-gray-100 px-2 py-1 rounded text-xs">${addr.label}</span>
        ${addr.is_default ? '<span class="bg-green-100 text-green-700 px-2 py-1 rounded text-xs">Default</span>' : ''}
      </div>
      <p class="font-bold text-sm">${addr.recipient_name}</p>
      <p class="text-xs text-gray-600">${addr.address}, ${addr.city}, ${addr.province}</p>
    </div>
  `).join('');
  document.getElementById('address-modal').classList.remove('hidden');
}

function closeAddressModal() {
  document.getElementById('address-modal').classList.add('hidden');
}

// Update placeOrder to use selectedAddress
async function placeOrder() {
  if (!selectedAddress) {
    alert('Pilih alamat pengiriman terlebih dahulu');
    return;
  }
  // ... rest of order placement with selectedAddress.id
}
```

---

## Task 12: Admin — Notification Badge for New Orders

**Files:**
- Modify: `skill_profile_app/lib/screens/admin/admin_orders_screen.dart`
- Modify: `SkillProfile/admin.html` (if exists)

- [ ] **Step 1: Add pending order count polling to admin dashboard**

In the admin orders screen, add periodic check:
```dart
Timer? _pollTimer;

@override
void initState() {
  super.initState();
  _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
    setState(() {}); // Refresh orders list
  });
}

@override
void dispose() {
  _pollTimer?.cancel();
  super.dispose();
}
```

For web admin, add similar polling:
```javascript
// In admin dashboard
setInterval(async () => {
  const result = await apiRequest('/admin/orders/pending-count');
  const badge = document.getElementById('pending-badge');
  if (result.count > 0) {
    badge.textContent = result.count;
    badge.classList.remove('hidden');
  } else {
    badge.classList.add('hidden');
  }
}, 10000);
```

---

## Task 13: Run Migrations & Test

- [ ] **Step 1: Run all migrations**

```bash
cd api_backend && php artisan migrate
```

Expected: Creates `addresses` table, adds `address_id` to `orders`

- [ ] **Step 2: Build Flutter models**

```bash
cd skill_profile_app && dart run build_runner build --delete-conflicting-outputs
```

Expected: Generates freezed files for Address model

- [ ] **Step 3: Full test flow**

1. Flutter app: Login → Shop → Add to cart → Checkout → See "Tambah Alamat" → Allow location → Fill form → Save → See address in checkout → Place order → Order appears in order history
2. Web: Login → Cart → Checkout → Select address → Place order → Order appears in order history
3. Admin: See pending order notification badge → Open order → Change status to "processing" → User sees updated status

---

## Summary of Changes

| Layer | What Changes |
|-------|-------------|
| **Database** | New `addresses` table, `address_id` added to `orders`, status enum updated |
| **Backend** | `AddressController` (CRUD), `OrderController` accepts `address_id`, `AdminOrderController` has `pendingCount()` |
| **Flutter** | `Address` model, `addressProvider`, `AddressFormScreen` (with geolocation), `AddressListScreen`, checkout rewritten |
| **Web** | `addresses.html` (new), `order_history.html` (new), checkout updated, user_dashboard dynamic |
| **Admin** | Status dropdown (pending→processing→shipped→delivered→cancelled), notification badge |
