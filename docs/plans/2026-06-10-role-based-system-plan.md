# Role-Based System Implementation Plan

> **For agentic workers:** Use executing-plans or subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a role-based system separating Admin (sell) and User (buy) across Flutter app and web, sharing the same Laravel backend + MySQL database.

**Architecture:** Laravel 9 API with Sanctum auth, MySQL database, Flutter app with Riverpod state management, HTML/CSS/JS web. Incremental 5-phase approach.

**Tech Stack:** Laravel 9.5.2, PHP 8.0.30, MySQL, Sanctum, Flutter (Riverpod, Freezed), HTML/Tailwind/JS, Pusher (real-time chat)

---

## Phase 1: Auth System

### Task 1.1: Add role field to users table

**Files:**
- Create: `api_backend/database/migrations/2026_06_10_010000_add_role_to_users_table.php`

- [ ] **Step 1: Create migration**

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('role', ['user', 'admin'])->default('user')->after('email');
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('role');
        });
    }
};
```

- [ ] **Step 2: Run migration**

```bash
cd api_backend
php artisan migrate
```

Expected: Migration runs successfully.

- [ ] **Step 3: Update User model**

File: `api_backend/app/Models/User.php`

Add `'role'` to `$fillable` array:

```php
protected $fillable = [
    'name',
    'email',
    'password',
    'role',
];
```

- [ ] **Step 4: Commit**

```bash
git add api_backend/database/migrations/2026_06_10_010000_add_role_to_users_table.php api_backend/app/Models/User.php
git commit -m "feat: add role field to users table"
```

---

### Task 1.2: Create AuthController

**Files:**
- Create: `api_backend/app/Http/Controllers/AuthController.php`
- Modify: `api_backend/routes/api.php`

- [ ] **Step 1: Create AuthController**

```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'user',
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out']);
    }

    public function profile(Request $request)
    {
        return response()->json($request->user());
    }
}
```

- [ ] **Step 2: Add routes**

File: `api_backend/routes/api.php`

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\AuthController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::apiResource('products', ProductController::class);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user/profile', [AuthController::class, 'profile']);
});
```

- [ ] **Step 3: Seed admin user**

File: `api_backend/database/seeders/AdminSeeder.php`

```php
<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run()
    {
        User::firstOrCreate(
            ['email' => 'admin@featuresfound.com'],
            [
                'name' => 'Admin',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
            ]
        );
    }
}
```

- [ ] **Step 4: Update DatabaseSeeder**

File: `api_backend/database/seeders/DatabaseSeeder.php`

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        $this->call([
            ProductSeeder::class,
            AdminSeeder::class,
        ]);
    }
}
```

- [ ] **Step 5: Run seeder**

```bash
cd api_backend
php artisan db:seed --class=AdminSeeder
```

- [ ] **Step 6: Test API**

```bash
# Register
curl -X POST http://localhost:8000/api/register -H "Content-Type: application/json" -d '{"name":"Test User","email":"user@test.com","password":"password123","password_confirmation":"password123"}'

# Login admin
curl -X POST http://localhost:8000/api/login -H "Content-Type: application/json" -d '{"email":"admin@featuresfound.com","password":"admin123"}'
```

- [ ] **Step 7: Commit**

```bash
git add api_backend/app/Http/Controllers/AuthController.php api_backend/routes/api.php api_backend/database/seeders/AdminSeeder.php api_backend/database/seeders/DatabaseSeeder.php
git commit -m "feat: add auth system with register, login, logout"
```

---

### Task 1.3: Flutter Auth - Models & Services

**Files:**
- Create: `skill_profile_app/lib/models/auth_result.dart`
- Create: `skill_profile_app/lib/services/api_service.dart`
- Create: `skill_profile_app/lib/services/auth_service.dart`
- Create: `skill_profile_app/lib/providers/auth_provider.dart`
- Modify: `skill_profile_app/pubspec.yaml` (add `shared_preferences` if not exists)

- [ ] **Step 1: Add shared_preferences to pubspec.yaml**

File: `skill_profile_app/pubspec.yaml`

Add under dependencies:

```yaml
dependencies:
  shared_preferences: ^2.2.0
```

Run:

```bash
cd skill_profile_app
flutter pub get
```

- [ ] **Step 2: Create ApiService**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static String? _token;

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('API Error: ${response.statusCode} - ${response.body}');
  }
}
```

- [ ] **Step 3: Create AuthService**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await ApiService.post('/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    await _saveAuthData(result);
    return result;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await ApiService.post('/login', body: {
      'email': email,
      'password': password,
    });
    await _saveAuthData(result);
    return result;
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/logout');
    } finally {
      await ApiService.clearToken();
    }
  }

  static Future<void> _saveAuthData(Map<String, dynamic> result) async {
    final token = result['token'];
    final user = result['user'];
    final prefs = await SharedPreferences.getInstance();
    await ApiService.setToken(token);
    await prefs.setString('user_role', user['role']);
    await prefs.setString('user_name', user['name']);
    await prefs.setInt('user_id', user['id']);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}
```

- [ ] **Step 4: Create AuthProvider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, User? user, String? error, bool clearError = false}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      final role = await AuthService.getRole();
      final prefs = await SharedPreferences.getInstance();
      state = state.copyWith(
        user: User(
          id: prefs.getInt('user_id') ?? 0,
          name: prefs.getString('user_name') ?? '',
          email: '',
          role: role ?? 'user',
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await AuthService.login(email: email, password: password);
      final userData = result['user'];
      state = state.copyWith(
        isLoading: false,
        user: User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          role: userData['role'],
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password, String passwordConfirmation) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final userData = result['user'];
      state = state.copyWith(
        isLoading: false,
        user: User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          role: userData['role'],
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```

- [ ] **Step 5: Update User model (add role field)**

File: `skill_profile_app/lib/models/user.dart`

Ensure `role` field exists in the User class. If not, add it.

- [ ] **Step 6: Commit**

```bash
git add skill_profile_app/lib/services/api_service.dart skill_profile_app/lib/services/auth_service.dart skill_profile_app/lib/providers/auth_provider.dart skill_profile_app/pubspec.yaml
git commit -m "feat: add Flutter auth services and provider"
```

---

### Task 1.4: Flutter Auth - Login & Register Screens

**Files:**
- Create: `skill_profile_app/lib/screens/login_screen.dart`
- Create: `skill_profile_app/lib/screens/register_screen.dart`
- Modify: `skill_profile_app/lib/main.dart` (add routes)
- Modify: `skill_profile_app/lib/screens/splash_screen.dart` (redirect based on auth)

- [ ] **Step 1: Create LoginScreen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.user != null && prev?.user == null) {
        if (next.user!.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 80, color: Color(0xFF8B7355)),
                  const SizedBox(height: 16),
                  const Text('Features & Found', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Masuk ke akun Anda', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B7355),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Masuk', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create RegisterScreen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.user != null && prev?.user == null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (v) => v!.length < 6 ? 'Password minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (v) => v != _passwordController.text ? 'Password tidak cocok' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B7355),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Daftar', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Sudah punya akun? Masuk'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Update main.dart routes**

Add login, register, and admin routes to `main.dart`.

- [ ] **Step 4: Update splash_screen.dart**

Check auth state on startup and redirect to appropriate screen.

- [ ] **Step 5: Test**

Run `flutter analyze lib/` to verify no errors.

- [ ] **Step 6: Commit**

```bash
git add skill_profile_app/lib/screens/login_screen.dart skill_profile_app/lib/screens/register_screen.dart skill_profile_app/lib/main.dart skill_profile_app/lib/screens/splash_screen.dart
git commit -m "feat: add login and register screens with role-based redirect"
```

---

### Task 1.5: Web Login

**Files:**
- Modify: `SkillProfile/login.html`

- [ ] **Step 1: Update login.html**

Replace hardcoded login logic with API call to `/api/login`.

- [ ] **Step 2: Test**

Open `login.html` in browser, test login with admin and user accounts.

- [ ] **Step 3: Commit**

```bash
git add SkillProfile/login.html
git commit -m "feat: connect web login to Laravel API"
```

---

## Phase 2: Admin Dashboard (Flutter)

### Task 2.1: Admin Home Screen (Stats)

**Files:**
- Create: `skill_profile_app/lib/screens/admin/admin_home_screen.dart`
- Create: `skill_profile_app/lib/providers/admin_provider.dart`
- Modify: `api_backend/app/Http/Controllers/AdminController.php` (create)
- Modify: `api_backend/routes/api.php`

- [ ] **Step 1: Create AdminController**

```php
<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Order;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function stats()
    {
        return response()->json([
            'total_products' => Product::count(),
            'total_orders' => Order::count(),
            'total_users' => User::where('role', 'user')->count(),
            'total_revenue' => Order::where('status', 'completed')->sum('total_price'),
        ]);
    }
}
```

- [ ] **Step 2: Add admin routes**

```php
Route::prefix('admin')->middleware(['auth:sanctum'])->group(function () {
    Route::get('/stats', [AdminController::class, 'stats']);
    Route::apiResource('products', AdminProductController::class);
    Route::get('/orders', [AdminOrderController::class, 'index']);
    Route::put('/orders/{id}/status', [AdminOrderController::class, 'updateStatus']);
});
```

- [ ] **Step 3: Create AdminHomeScreen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF8B7355),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (stats) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Statistik', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _statCard('Produk', stats['total_products'].toString(), Icons.inventory),
                  const SizedBox(width: 12),
                  _statCard('Pesanan', stats['total_orders'].toString(), Icons.shopping_bag),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statCard('User', stats['total_users'].toString(), Icons.people),
                  const SizedBox(width: 12),
                  _statCard('Revenue', 'Rp ${stats['total_revenue']}', Icons.attach_money),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF8B7355)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Create AdminProvider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ApiService.get('/admin/stats');
  return result;
});
```

- [ ] **Step 5: Test**

Run `flutter analyze lib/`.

- [ ] **Step 6: Commit**

```bash
git add skill_profile_app/lib/screens/admin/admin_home_screen.dart skill_profile_app/lib/providers/admin_provider.dart api_backend/app/Http/Controllers/AdminController.php api_backend/routes/api.php
git commit -m "feat: add admin home screen with stats"
```

---

### Task 2.2: Admin Products CRUD

**Files:**
- Create: `skill_profile_app/lib/screens/admin/admin_products_screen.dart`
- Create: `skill_profile_app/lib/screens/admin/admin_product_form_screen.dart`
- Create: `api_backend/app/Http/Controllers/AdminProductController.php`

- [ ] **Step 1: Create AdminProductController**

```php
<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;

class AdminProductController extends Controller
{
    public function index()
    {
        return Product::all();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|string',
            'material' => 'required|string',
            'price' => 'required|numeric|min:0',
            'img' => 'required|url',
        ]);

        $product = Product::create($validated);
        return response()->json($product, 201);
    }

    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|string',
            'material' => 'required|string',
            'price' => 'required|numeric|min:0',
            'img' => 'required|url',
        ]);

        $product->update($validated);
        return response()->json($product);
    }

    public function destroy($id)
    {
        $product = Product::findOrFail($id);
        $product->delete();
        return response()->json(['message' => 'Produk dihapus']);
    }
}
```

- [ ] **Step 2: Create AdminProductsScreen**

Screen with list of products + FAB to add new product. Each product has edit/delete buttons.

- [ ] **Step 3: Create AdminProductFormScreen**

Form for adding/editing product (name, category, material, price, image URL).

- [ ] **Step 4: Test**

Run `flutter analyze lib/`.

- [ ] **Step 5: Commit**

```bash
git add skill_profile_app/lib/screens/admin/admin_products_screen.dart skill_profile_app/lib/screens/admin/admin_product_form_screen.dart api_backend/app/Http/Controllers/AdminProductController.php
git commit -m "feat: add admin products CRUD screens and controller"
```

---

### Task 2.3: Admin Orders Management

**Files:**
- Create: `skill_profile_app/lib/screens/admin/admin_orders_screen.dart`
- Create: `api_backend/app/Http/Controllers/AdminOrderController.php`

- [ ] **Step 1: Create Order model + migration**

- [ ] **Step 2: Create AdminOrderController**

- [ ] **Step 3: Create AdminOrdersScreen**

- [ ] **Step 4: Commit**

---

### Task 2.4: Admin Navigation

**Files:**
- Create: `skill_profile_app/lib/screens/admin/admin_main_screen.dart`

Bottom nav: Home (stats), Products, Orders, Chat.

- [ ] **Step 1: Create AdminMainScreen**

- [ ] **Step 2: Update routes in main.dart**

- [ ] **Step 3: Commit**

---

## Phase 3: User Shopping (Flutter + Web)

### Task 3.1: Orders Table + Checkout API

**Files:**
- Create: `api_backend/database/migrations/2026_06_10_020000_create_orders_table.php`
- Create: `api_backend/database/migrations/2026_06_10_020001_create_order_items_table.php`
- Create: `api_backend/app/Models/Order.php`
- Create: `api_backend/app/Models/OrderItem.php`
- Create: `api_backend/app/Http/Controllers/OrderController.php`

### Task 3.2: Flutter Checkout Screen

### Task 3.3: Flutter Order History Screen

### Task 3.4: Web Checkout + Order History

---

## Phase 4: Wishlist & Review

### Task 4.1: Wishlist Table + API
### Task 4.2: Review Table + API
### Task 4.3: Flutter Wishlist Screen
### Task 4.4: Flutter Review Form
### Task 4.5: Web Wishlist + Review

---

## Phase 5: Chat Real-Time

### Task 5.1: Chat Tables + API
### Task 5.2: Laravel Broadcasting Setup
### Task 5.3: Flutter Chat Screen (User)
### Task 5.4: Flutter Chat Screen (Admin)
### Task 5.5: Web Chat Widget

---

## Critical Notes

- PHP 8.0.30 limits Laravel to v9.x
- Sanctum is already installed in the Laravel project
- All API responses should be JSON
- Flutter uses Riverpod for state management
- Web uses fetch() for API calls
- CORS allows all origins (development mode)
