import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userName;

  bool get isLoggedIn => _user != null;
  User? get user => _user;
  String? get userName => _userName ?? _user?.email?.split('@').first;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      _userName =
          _user?.userMetadata?['name'] ?? _user?.email?.split('@').first;
      debugPrint('🔐 Auth state changed: ${_user?.email ?? 'null'}');
      notifyListeners();
    });

    // 🔥 Load user from existing session on app start
    _initUser();
  }

  // ============================================================
  // 🔥🔥 NEW: Initialize user from existing session
  // ============================================================
  Future<void> _initUser() async {
    try {
      final session = await _supabase.auth.currentSession;
      if (session?.user != null) {
        _user = session!.user;
        _userName =
            _user?.userMetadata?['name'] ?? _user?.email?.split('@').first;
        debugPrint('✅ AuthProvider: User loaded from session: ${_user?.email}');
        notifyListeners();
      } else {
        debugPrint('⚠️ AuthProvider: No active session found');
      }
    } catch (e) {
      debugPrint('❌ AuthProvider init error: $e');
    }
  }

  // ============================================================
  // 🔥🔥 NEW: Refresh user state (called by AppState)
  // ============================================================
  Future<void> refreshUser() async {
    await _initUser();
  }

  // ============================================================
  // LOGIN
  // ============================================================
  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔐 Attempting login: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
      _userName =
          _user?.userMetadata?['name'] ?? _user?.email?.split('@').first;
      _isLoading = false;
      debugPrint('✅ Login successful: ${_user?.email}');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      debugPrint('❌ Login error: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // SIGNUP
  // ============================================================
  Future<bool> signup(String name, String email, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📝 Attempting signup: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      _user = response.user;
      _userName = name;
      _isLoading = false;
      debugPrint('✅ Signup successful: ${_user?.email}');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      debugPrint('❌ Signup error: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================
  Future<bool> resetPassword(String email) async {
    _errorMessage = null;
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      debugPrint('✅ Password reset email sent to: $email');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Reset password error: $e');
      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  void logout() {
    debugPrint('🔓 Logging out...');
    _supabase.auth.signOut();
    _user = null;
    _userName = null;
    debugPrint('✅ Logged out');
    notifyListeners();
  }
}
