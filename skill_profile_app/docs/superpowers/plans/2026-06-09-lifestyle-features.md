# Lifestyle E-Commerce Features Plan

**Goal:** Tambah fitur penting untuk e-commerce lifestyle yang lebih lengkap dan profesional

**Fitur yang akan ditambahkan:**
1. Splash Screen (branding saat app dibuka)
2. Wishlist/Favorites (simpan produk favorit)
3. Order History (riwayat pesanan)
4. Kategori produk (filter by category)

---

## Task 1: Buat Splash Screen

**Files:** lib/screens/splash_screen.dart

- [ ] Buat splash screen dengan logo dan branding "Features & Found"
- [ ] Auto-navigate ke MainScreen setelah 2 detik
- [ ] Gunakan animasi fade-in untuk logo

---

## Task 2: Buat Wishlist Provider

**Files:** lib/providers/wishlist_provider.dart

- [ ] Buat WishlistNotifier untuk manage wishlist
- [ ] Method: addItem, removeItem, toggleItem, isInWishlist

---

## Task 3: Buat Wishlist Screen

**Files:** lib/screens/wishlist_screen.dart

- [ ] Tampilkan daftar produk favorit
- [ ] Tap untuk buka detail produk
- [ ] Swipe atau tap icon untuk remove dari wishlist

---

## Task 4: Update ProductCard dengan Wishlist

**Files:** lib/screens/widgets/product_card.dart

- [ ] Tambah icon hati untuk add/remove wishlist
- [ ] Icon filled jika sudah di wishlist

---

## Task 5: Buat Order History Provider

**Files:** lib/providers/order_provider.dart

- [ ] Buat model Order
- [ ] Buat OrderNotifier untuk manage orders
- [ ] Sample data order

---

## Task 6: Buat Order History Screen

**Files:** lib/screens/order_history_screen.dart

- [ ] Tampilkan daftar pesanan
- [ ] Status pesanan (pending, shipped, delivered)
- [ ] Detail order

---

## Task 7: Update MainScreen Navigation

**Files:** lib/screens/main_screen.dart

- [ ] Tambah tab Wishlist di bottom nav
- [ ] Update navigation

---

## Task 8: Tambah Kategori ke ShopScreen

**Files:** lib/screens/shop_screen.dart

- [ ] Tambah horizontal scroll kategori
- [ ] Filter produk berdasarkan kategori

---

## Task 9: Testing

- [ ] Jalankan flutter test
- [ ] Pastikan tidak ada regressions
