import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/module_api.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  AuthService() {
    _client = ApiClient(tokenProvider: () async => _token);
    modules = ModuleApi(_client);
    _restore();
  }

  late final ApiClient _client;
  String? _token;
  UserModel? _user;
  bool _loading = true;
  bool _onboarded = false;

  ApiClient get client => _client;
  late final ModuleApi modules;
  UserModel? get user => _user;
  String? get token => _token;

  /// True only when we have a non-empty token AND a known user profile.
  /// Token without user is treated as incomplete session → force re-login.
  bool get isLoggedIn =>
      _token != null && _token!.isNotEmpty && _user != null && _user!.id > 0;

  bool get isLoading => _loading;
  bool get onboarded => _onboarded;
  String get role => (_user?.role ?? 'user').toLowerCase();

  /// Restore session from disk, then **validate** token with `/api/auth/me`
  /// before ending the loading state. This prevents opening the admin
  /// dashboard with a stale/invalid token and blocking the login screen.
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(ApiConfig.keyToken);
      _onboarded = prefs.getBool(ApiConfig.keyOnboarded) ?? false;

      final id = prefs.getInt(ApiConfig.keyUserId) ?? 0;
      final name = prefs.getString(ApiConfig.keyUserName) ?? '';
      final email = prefs.getString(ApiConfig.keyUserEmail) ?? '';
      final role = (prefs.getString(ApiConfig.keyRole) ?? 'user').toLowerCase();

      if (_token != null && _token!.isNotEmpty && id > 0) {
        // Provisional profile from disk (used only while validating).
        _user = UserModel(id: id, name: name, email: email, role: role);
        await _validateSession();
      } else {
        // Incomplete / empty session → clear everything.
        await _clearLocal(prefs);
      }
    } catch (e) {
      debugPrint('Auth restore error: $e');
      await _clearLocal(await SharedPreferences.getInstance());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Validate stored token. On 401/403 clear session so login works.
  /// On network error keep provisional offline session (token + user from disk).
  Future<void> _validateSession() async {
    try {
      final res = await _client.get(ApiConfig.me, auth: true);
      if (res.statusCode == 401 || res.statusCode == 403) {
        await _clearLocal(await SharedPreferences.getInstance());
        return;
      }
      if (!res.isOk || res.json == null) {
        // Network / server error: keep offline session if profile looks valid.
        if (_user == null || _user!.id <= 0) {
          await _clearLocal(await SharedPreferences.getInstance());
        }
        return;
      }

      Map<String, dynamic> data = res.json!;
      if (data['data'] is Map) {
        data = Map<String, dynamic>.from(data['data'] as Map);
      } else if (data['user'] is Map) {
        data = Map<String, dynamic>.from(data['user'] as Map);
      }
      final user = UserModel.fromJson(data);
      if (user.id <= 0) {
        await _clearLocal(await SharedPreferences.getInstance());
        return;
      }
      final token = _token;
      if (token == null || token.isEmpty) {
        await _clearLocal(await SharedPreferences.getInstance());
        return;
      }
      // Persist refreshed profile without flipping loading flag.
      await _persist(token, user, notify: false);
    } catch (e) {
      debugPrint('Auth validate error: $e');
      // Keep offline session if we already have a user id.
      if (_user == null || _user!.id <= 0) {
        await _clearLocal(await SharedPreferences.getInstance());
      }
    }
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ApiConfig.keyOnboarded, true);
    _onboarded = true;
    notifyListeners();
  }

  /// [identity] = email, nomor HP, atau ID pelanggan / user id.
  Future<String?> login(String identity, String password) async {
    final id = identity.trim();
    if (id.isEmpty) return 'Email / No. HP / ID wajib diisi';
    if (password.isEmpty) return 'Password wajib diisi';

    final res = await _client.post(ApiConfig.login, body: {
      // Kompatibel backend yang mengharapkan `email`, `login`, atau `username`
      'login': id,
      'email': id,
      'username': id,
      'password': password,
      'device_name': 'mport-flutter',
    });
    if (!res.isOk) return res.message;
    return _saveAuthFromResponse(res.json);
  }

  /// Request reset password. Return error message, atau null jika sukses.
  Future<String?> forgotPassword(String identity) async {
    final id = identity.trim();
    if (id.isEmpty) return 'Email / No. HP / ID wajib diisi';
    try {
      final res = await _client.post(ApiConfig.forgotPassword, body: {
        'login': id,
        'email': id,
      });
      if (!res.isOk) return res.message;
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': 'mport-flutter',
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    final res = await _client.post(ApiConfig.register, body: body);
    if (!res.isOk) return res.message;
    return _saveAuthFromResponse(res.json);
  }

  Future<String?> _saveAuthFromResponse(Map<String, dynamic>? json) async {
    if (json == null) return 'Response kosong dari server';

    // Unwrap common Laravel / Sanctum envelopes.
    var root = Map<String, dynamic>.from(json);
    if (root['data'] is Map) {
      final data = Map<String, dynamic>.from(root['data'] as Map);
      final hasToken = data.containsKey('token') ||
          data.containsKey('access_token') ||
          data.containsKey('plainTextToken') ||
          (data['token'] is Map);
      if (hasToken || data.containsKey('user')) {
        root = data;
      }
    }

    final token = _extractToken(root);
    if (token == null || token.isEmpty) {
      return 'Token tidak ditemukan pada respons login';
    }

    UserModel? user;
    if (root['user'] is Map) {
      user = UserModel.fromJson(Map<String, dynamic>.from(root['user'] as Map));
    } else if (root['data'] is Map &&
        (root['data'] as Map).containsKey('id')) {
      // Some APIs return the user object at data after unwrap failed above.
      user = UserModel.fromJson(Map<String, dynamic>.from(root['data'] as Map));
    }

    if (user == null || user.id <= 0) {
      // Token ok but no user — still try /me before failing.
      _token = token;
      try {
        final me = await _client.get(ApiConfig.me, auth: true);
        if (me.isOk && me.json != null) {
          Map<String, dynamic> data = me.json!;
          if (data['data'] is Map) {
            data = Map<String, dynamic>.from(data['data'] as Map);
          } else if (data['user'] is Map) {
            data = Map<String, dynamic>.from(data['user'] as Map);
          }
          user = UserModel.fromJson(data);
        }
      } catch (_) {}
    }

    if (user == null || user.id <= 0) {
      _token = null;
      return 'Login berhasil tetapi data user tidak lengkap. Coba lagi.';
    }

    await _persist(token, user);
    return null;
  }

  /// Extract bearer token from varied API shapes.
  String? _extractToken(Map<String, dynamic> root) {
    final direct = root['token'] ?? root['access_token'] ?? root['plainTextToken'];
    if (direct is String && direct.isNotEmpty) return direct;
    if (direct is Map) {
      // Sanctum: { token: { plainTextToken: "..." } } or { token: { accessToken: "..." } }
      final m = Map<String, dynamic>.from(direct);
      final nested = m['plainTextToken'] ??
          m['access_token'] ??
          m['accessToken'] ??
          m['token'];
      if (nested is String && nested.isNotEmpty) return nested;
    }
    // { data: { token: "..." } } already unwrapped; try authorization header style
    final auth = root['authorization'] ?? root['Authorization'];
    if (auth is String && auth.isNotEmpty) {
      return auth.replaceFirst(RegExp(r'^(Bearer\s+)', caseSensitive: false), '');
    }
    return null;
  }

  Future<void> fetchMe() async {
    final res = await _client.get(ApiConfig.me, auth: true);
    if (res.statusCode == 401 || res.statusCode == 403) {
      await logout();
      return;
    }
    if (!res.isOk || res.json == null) return;

    Map<String, dynamic> data = res.json!;
    if (data['data'] is Map) {
      data = Map<String, dynamic>.from(data['data'] as Map);
    } else if (data['user'] is Map) {
      data = Map<String, dynamic>.from(data['user'] as Map);
    }
    final user = UserModel.fromJson(data);
    final token = _token;
    if (token == null || token.isEmpty || user.id <= 0) return;
    await _persist(token, user);
  }

  Future<void> _persist(String token, UserModel? user, {bool notify = true}) async {
    final prefs = await SharedPreferences.getInstance();
    _token = token;
    await prefs.setString(ApiConfig.keyToken, token);
    await prefs.setString(ApiConfig.keyTokenType, 'Bearer');
    if (user != null) {
      _user = user;
      await prefs.setInt(ApiConfig.keyUserId, user.id);
      await prefs.setString(ApiConfig.keyUserName, user.name);
      await prefs.setString(ApiConfig.keyUserEmail, user.email);
      await prefs.setString(ApiConfig.keyRole, user.role.toLowerCase());
    }
    if (notify) notifyListeners();
  }

  Future<void> _clearLocal(SharedPreferences prefs) async {
    await prefs.remove(ApiConfig.keyToken);
    await prefs.remove(ApiConfig.keyTokenType);
    await prefs.remove(ApiConfig.keyUserId);
    await prefs.remove(ApiConfig.keyUserName);
    await prefs.remove(ApiConfig.keyUserEmail);
    await prefs.remove(ApiConfig.keyRole);
    _token = null;
    _user = null;
  }

  Future<void> logout() async {
    try {
      if (_token != null && _token!.isNotEmpty) {
        await _client.post(ApiConfig.logout, auth: true);
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await _clearLocal(prefs);
    notifyListeners();
  }
}
