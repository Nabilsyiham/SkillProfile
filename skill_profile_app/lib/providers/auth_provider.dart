import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role;

  AuthUser({required this.id, required this.name, required this.email, required this.role});
}

class AuthState {
  final bool isLoading;
  final AuthUser? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, AuthUser? user, String? error, bool clearError = false}) {
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
        user: AuthUser(
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
        user: AuthUser(
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
        user: AuthUser(
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
