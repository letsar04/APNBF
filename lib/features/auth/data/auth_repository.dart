import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'phone': phone.trim(),
      },
    );

    final session = response.session;
    final user = response.user;
    if (user == null) {
      throw const AuthException('Impossible de créer le compte.');
    }

    if (session != null) {
      await _upsertProfile(user);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Connexion impossible.');
    }

    await _upsertProfile(user);
  }

  Future<bool> hasBusiness() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final result = await _client
        .from('business_members')
        .select('id')
        .eq('user_id', user.id)
        .limit(1);

    return result.isNotEmpty;
  }

  Future<void> createBusiness({
    required String name,
    required String phone,
    required String whatsapp,
    required String address,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Session utilisateur absente.');

    final business = await _client
        .from('businesses')
        .insert({
          'name': name.trim(),
          'phone': phone.trim(),
          'whatsapp': whatsapp.trim(),
          'address': address.trim(),
          'currency': 'XOF',
          'created_by': user.id,
        })
        .select('id')
        .single();

    await _client.from('business_members').insert({
      'business_id': business['id'],
      'user_id': user.id,
      'role': 'owner',
    });
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> _upsertProfile(User user) async {
    await _client.from('profiles').upsert({
      'id': user.id,
      'full_name': user.userMetadata?['full_name'],
      'phone': user.userMetadata?['phone'],
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
