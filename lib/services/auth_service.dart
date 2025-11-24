import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<bool> signIn(String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      if (res.session != null) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final res = await _client.auth.signUp(email: email, password: password);
      return res.user != null;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    return data;
  }

  Future<void> updateProfile({String? username, String? avatarUrl, String? website}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final update = <String, dynamic>{};
    if (username != null) update['username'] = username;
    if (avatarUrl != null) update['avatar_url'] = avatarUrl;
    if (website != null) update['website'] = website;
    if (update.isEmpty) return;
    await _client.from('profiles').update(update).eq('id', user.id);
  }
}