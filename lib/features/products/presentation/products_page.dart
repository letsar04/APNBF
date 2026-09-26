import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/session/app_session.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final db = Supabase.instance.client;
  final session = AppSession();
  late Future<List<Map<String, dynamic>>> future;
  @override
  void initState() {
    super.initState();
    future = _list();
  }

  Future<List<Map<String, dynamic>>> _list() async {
    final id = await session.businessId();
    final x = await db
        .from('products')
        .select()
        .eq('business_id', id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(x);
  }

  void refresh() => setState(() => future = _list());
  Future<void> add() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _ProductDialog(),
    );
    if (ok == true) refresh();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Produits'),
      actions: [IconButton(onPressed: add, icon: const Icon(Icons.add))],
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final list = s.data!;
        if (list.isEmpty) return const Center(child: Text('Aucun produit.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final p = list[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(p['name']),
                subtitle: Text('${p['price']} F • Stock : ${p['quantity']}'),
                trailing: Text(p['status'] ?? ''),
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: add,
      icon: const Icon(Icons.add),
      label: const Text('Produit'),
    ),
  );
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog();
  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final name = TextEditingController(),
      price = TextEditingController(),
      qty = TextEditingController(),
      desc = TextEditingController();
  bool loading = false;
  @override
  void dispose() {
    name.dispose();
    price.dispose();
    qty.dispose();
    desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => AlertDialog(
    title: const Text('Nouveau produit'),
    content: SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          TextField(
            controller: price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Prix de vente (F)'),
          ),
          TextField(
            controller: qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantité'),
          ),
          TextField(
            controller: desc,
            decoration: const InputDecoration(labelText: 'Description'),
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
        onPressed: loading
            ? null
            : () async {
                final p = double.tryParse(price.text) ?? 0,
                    q = double.tryParse(qty.text) ?? 0;
                if (name.text.trim().isEmpty) return;
                setState(() => loading = true);
                try {
                  final id = await AppSession().businessId();
                  await Supabase.instance.client.from('products').insert({
                    'business_id': id,
                    'name': name.text.trim(),
                    'price': p,
                    'quantity': q,
                    'description': desc.text.trim(),
                    'status': q > 0 ? 'available' : 'draft',
                    'condition': 'used',
                  });
                  if (c.mounted) Navigator.pop(c, true);
                } catch (e) {
                  if (c.mounted)
                    ScaffoldMessenger.of(
                      c,
                    ).showSnackBar(SnackBar(content: Text('$e')));
                } finally {
                  if (mounted) setState(() => loading = false);
                }
              },
        child: const Text('Créer'),
      ),
    ],
  );
}
