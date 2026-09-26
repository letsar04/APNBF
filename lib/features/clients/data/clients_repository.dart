import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/session/app_session.dart';

class ClientsRepository {
  SupabaseClient get _client => Supabase.instance.client;
  final AppSession _session = AppSession();

  Future<List<Map<String, dynamic>>> list() async {
    final businessId = await _session.businessId();
    final data = await _client.from('clients').select().eq('business_id', businessId).order('full_name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> get(String id) async {
    final data = await _client.from('clients').select().eq('id', id).single();
    return Map<String, dynamic>.from(data);
  }

  Future<void> save({
    String? id,
    required String fullName,
    String phone = '',
    String whatsapp = '',
    String email = '',
    String address = '',
    String notes = '',
  }) async {
    final businessId = await _session.businessId();
    final payload = {
      'business_id': businessId,
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'whatsapp': whatsapp.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'notes': notes.trim(),
    };
    if (id == null) {
      await _client.from('clients').insert(payload);
    } else {
      await _client.from('clients').update(payload).eq('id', id);
    }
  }

  Future<void> delete(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> credits(String clientId) async {
    final data = await _client.from('credits').select().eq('client_id', clientId).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createCredit({
    required String clientId,
    required double amount,
    DateTime? dueDate,
    String notes = '',
  }) async {
    final businessId = await _session.businessId();
    await _client.from('credits').insert({
      'business_id': businessId,
      'client_id': clientId,
      'original_amount': amount,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'notes': notes.trim(),
      'status': 'active',
    });
  }

  Future<void> payCredit({
    required String creditId,
    required double amount,
    required String clientId,
    String method = 'cash',
  }) async {
    final credit = await _client.from('credits').select('original_amount,paid_amount,business_id,order_id').eq('id', creditId).single();
    final original = (credit['original_amount'] as num).toDouble();
    final paid = (credit['paid_amount'] as num).toDouble();
    if (amount <= 0 || paid + amount > original) {
      throw Exception('Le paiement dépasse le montant restant.');
    }
    final newPaid = paid + amount;
    final status = newPaid >= original ? 'paid' : 'partially_paid';
    await _client.from('credits').update({
      'paid_amount': newPaid,
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', creditId);
    await _client.from('payments').insert({
      'business_id': credit['business_id'],
      'client_id': clientId,
      'order_id': credit['order_id'],
      'credit_id': creditId,
      'amount': amount,
      'payment_method': method,
    });
    await _client.from('transactions').insert({
      'business_id': credit['business_id'],
      'type': 'income',
      'amount': amount,
      'category': 'Remboursement crédit',
      'reference_type': 'credit',
      'reference_id': creditId,
      'description': 'Paiement client',
    });
  }
}
