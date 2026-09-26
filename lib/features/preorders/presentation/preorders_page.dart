import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/session/app_session.dart';

class PreordersPage extends StatefulWidget {
  const PreordersPage({super.key});
  @override
  State<PreordersPage> createState() => _PreordersPageState();
}

class _PreordersPageState extends State<PreordersPage> {
  late Future<List<Map<String, dynamic>>> future;
  final db = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    future = _list();
  }

  Future<List<Map<String, dynamic>>> _list() async {
    final id = await AppSession().businessId();
    final x = await db
        .from('preorders')
        .select(
          'id,quantity,estimated_price,deposit_amount,expected_arrival,status,products(name),clients(full_name)',
        )
        .eq('business_id', id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(x);
  }

  void refresh() => setState(() => future = _list());
  Future<void> add() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _PreorderDialog(),
    );
    if (ok == true) refresh();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Précommandes'),
      actions: [IconButton(onPressed: add, icon: const Icon(Icons.add))],
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final list = s.data!;
        if (list.isEmpty)
          return const Center(child: Text('Aucune précommande.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final x = list[i];
            final p = x['products'] as Map?;
            final cl = x['clients'] as Map?;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: Text(p?['name']?.toString() ?? 'Produit'),
                subtitle: Text(
                  '${cl?['full_name'] ?? 'Client'} • Qté ${x['quantity']} • Dépôt ${x['deposit_amount']} F',
                ),
                trailing: Text(x['status'] ?? ''),
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: add,
      icon: const Icon(Icons.add),
      label: const Text('Précommande'),
    ),
  );
}

class _PreorderDialog extends StatefulWidget {
  const _PreorderDialog();
  @override
  State<_PreorderDialog> createState() => _PreorderDialogState();
}

class _PreorderDialogState extends State<_PreorderDialog> {
  final db = Supabase.instance.client;
  List<Map<String, dynamic>> products = [], clients = [];
  String? productId, clientId;
  final qty = TextEditingController(text: '1'),
      price = TextEditingController(),
      deposit = TextEditingController();
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await AppSession().businessId();
    final p = await db.from('products').select('id,name').eq('business_id', id);
    final c = await db
        .from('clients')
        .select('id,full_name')
        .eq('business_id', id);
    if (mounted)
      setState(() {
        products = List<Map<String, dynamic>>.from(p);
        clients = List<Map<String, dynamic>>.from(c);
        loading = false;
      });
  }

  @override
  void dispose() {
    qty.dispose();
    price.dispose();
    deposit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    if (loading) return const AlertDialog(content: CircularProgressIndicator());
    return AlertDialog(
      title: const Text('Nouvelle précommande'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: productId,
              decoration: const InputDecoration(labelText: 'Produit'),
              items: products
                  .map(
                    (x) => DropdownMenuItem(
                      value: x['id'].toString(),
                      child: Text(x['name']),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => productId = v);
              },
            ),
            DropdownButtonFormField<String>(
              value: clientId,
              decoration: const InputDecoration(labelText: 'Client'),
              items: clients
                  .map(
                    (x) => DropdownMenuItem(
                      value: x['id'].toString(),
                      child: Text(x['full_name']),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => clientId = v);
              },
            ),
            TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité'),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix estimé total'),
            ),
            TextField(
              controller: deposit,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Dépôt'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: productId == null || clientId == null
              ? null
              : () async {
                  final q = double.tryParse(qty.text) ?? 1,
                      p = double.tryParse(price.text),
                      d = double.tryParse(deposit.text) ?? 0;
                  final bid = await AppSession().businessId();
                  await db.from('preorders').insert({
                    'business_id': bid,
                    'product_id': productId,
                    'client_id': clientId,
                    'quantity': q,
                    'estimated_price': p,
                    'deposit_amount': d,
                    'status': d > 0 ? 'deposit_paid' : 'confirmed',
                  });
                  if (d > 0)
                    await db.from('transactions').insert({
                      'business_id': bid,
                      'type': 'income',
                      'amount': d,
                      'category': 'Dépôt précommande',
                      'reference_type': 'preorder',
                    });
                  if (c.mounted) Navigator.pop(c, true);
                },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
