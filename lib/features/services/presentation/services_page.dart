import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/session/app_session.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
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
        .from('services')
        .select()
        .eq('business_id', id)
        .eq('is_active', true)
        .order('name');
    return List<Map<String, dynamic>>.from(x);
  }

  void refresh() => setState(() => future = _list());
  Future<void> add() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _ServiceDialog(),
    );
    if (ok == true) refresh();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Services'),
      actions: [IconButton(onPressed: add, icon: const Icon(Icons.add))],
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final list = s.data!;
        if (list.isEmpty) return const Center(child: Text('Aucun service.'));
        return ListView(
          children: list
              .map(
                (x) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.handyman_outlined),
                    title: Text(x['name']),
                    subtitle: Text(
                      x['price_type'] == 'quote'
                          ? 'Sur devis'
                          : 'À partir de ${x['base_price']} F',
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: add,
      icon: const Icon(Icons.add),
      label: const Text('Service'),
    ),
  );
}

class _ServiceDialog extends StatefulWidget {
  const _ServiceDialog();
  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  final name = TextEditingController(),
      price = TextEditingController(),
      desc = TextEditingController();
  String type = 'quote';
  @override
  void dispose() {
    name.dispose();
    price.dispose();
    desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => AlertDialog(
    title: const Text('Nouveau service'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        TextField(
          controller: desc,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        DropdownButtonFormField(
          value: type,
          items: const [
            DropdownMenuItem(value: 'quote', child: Text('Sur devis')),
            DropdownMenuItem(value: 'fixed', child: Text('Prix fixe')),
            DropdownMenuItem(
              value: 'starting_from',
              child: Text('À partir de'),
            ),
          ],
          onChanged: (v) {
            if (v != null) setState(() => type = v);
          },
        ),
        TextField(
          controller: price,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Prix'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(c),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () async {
          if (name.text.trim().isEmpty) return;
          await Supabase.instance.client.from('services').insert({
            'business_id': await AppSession().businessId(),
            'name': name.text.trim(),
            'description': desc.text.trim(),
            'price_type': type,
            'base_price': double.tryParse(price.text),
          });
          if (c.mounted) Navigator.pop(c, true);
        },
        child: const Text('Créer'),
      ),
    ],
  );
}
