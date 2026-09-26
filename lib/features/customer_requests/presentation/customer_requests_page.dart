import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/session/app_session.dart';

class CustomerRequestsPage extends StatefulWidget { const CustomerRequestsPage({super.key}); @override State<CustomerRequestsPage> createState() => _CustomerRequestsPageState(); }
class _CustomerRequestsPageState extends State<CustomerRequestsPage> {
  final db = Supabase.instance.client; late Future<List<Map<String, dynamic>>> future;
  @override void initState() { super.initState(); future = _list(); }
  Future<List<Map<String, dynamic>>> _list() async { final id = await AppSession().businessId(); final x = await db.from('customer_requests').select('*,products(name),services(name)').eq('business_id', id).order('created_at', ascending: false); return List<Map<String, dynamic>>.from(x); }
  void refresh() => setState(() => future = _list());
  String _normalise(String v) { var n = v.replaceAll(RegExp(r'[^0-9+]'), ''); if (n.startsWith('00')) n = n.substring(2); if (n.startsWith('0')) n = '226${n.substring(1)}'; if (n.startsWith('+')) n = n.substring(1); return n; }
  Future<void> _status(String id, String value) async { await db.from('customer_requests').update({'status': value}).eq('id', id); refresh(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Demandes clients'), actions: [IconButton(onPressed: refresh, icon: const Icon(Icons.refresh))]), body: FutureBuilder<List<Map<String, dynamic>>>(future: future, builder: (context, snapshot) {
    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final list = snapshot.data!; if (list.isEmpty) return const Center(child: Text('Aucune demande client pour le moment.'));
    return ListView.separated(padding: const EdgeInsets.all(16), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) {
      final x = list[i]; final p = x['products'] as Map?; final service = x['services'] as Map?; final phone = (x['phone'] ?? '').toString();
      return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(x['client_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))), Chip(label: Text(x['status'] ?? 'new'))]),
        Text(p?['name']?.toString() ?? service?['name']?.toString() ?? 'Demande générale'),
        if ((x['message'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(x['message'])),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          if (phone.isNotEmpty) OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse('tel:$phone')), icon: const Icon(Icons.call), label: const Text('Appeler')),
          if (phone.isNotEmpty) OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse('https://wa.me/${_normalise(phone)}'), mode: LaunchMode.externalApplication), icon: const Icon(Icons.chat), label: const Text('WhatsApp')),
          PopupMenuButton<String>(onSelected: (v) => _status(x['id'].toString(), v), itemBuilder: (_) => const [PopupMenuItem(value: 'contacted', child: Text('Marquer contacté')), PopupMenuItem(value: 'confirmed', child: Text('Confirmer')), PopupMenuItem(value: 'completed', child: Text('Terminer')), PopupMenuItem(value: 'cancelled', child: Text('Annuler'))], child: const Icon(Icons.more_horiz)),
        ]),
      ]));
    });
  });
}
