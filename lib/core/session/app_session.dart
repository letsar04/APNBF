import 'package:supabase_flutter/supabase_flutter.dart';

class AppSession {
  SupabaseClient get _client => Supabase.instance.client;

  Future<Map<String, dynamic>> currentBusiness() async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Session utilisateur absente.');

    final membership = await _client
        .from('business_members')
        .select('business_id, role')
        .eq('user_id', user.id)
        .limit(1)
        .single();

    final business = await _client
        .from('businesses')
        .select()
        .eq('id', membership['business_id'])
        .single();

    return {...business, 'role': membership['role']};
  }

  Future<String> businessId() async => (await currentBusiness())['id'] as String;
}
