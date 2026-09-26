import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/session/app_session.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});
  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final db = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> future;
  @override
  void initState() {
    super.initState();
    future = _list();
  }

  Future<List<Map<String, dynamic>>> _list() async {
    final id = await AppSession().businessId();
    final x = await db
        .from('transactions')
        .select()
        .eq('business_id', id)
        .order('transaction_date', ascending: false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(x);
  }

  void refresh() => setState(() => future = _list());
  Future<void> add() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _MovementDialog(),
    );
    if (ok == true) refresh();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Trésorerie'),
      actions: [IconButton(onPressed: add, icon: const Icon(Icons.add))],
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final list = s.data!;
        double income = 0, expense = 0;
        for (final x in list) {
          final a = (x['amount'] as num).toDouble();
          if (x['type'] == 'income')
            income += a;
          else
            expense += a;
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _Box('Entrées', '${income.toStringAsFixed(0)} F'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Box('Sorties', '${expense.toStringAsFixed(0)} F'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Box(
                      'Solde',
                      '${(income - expense).toStringAsFixed(0)} F',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('Aucun mouvement.'))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final x = list[i];
                        return ListTile(
                          leading: Icon(
                            x['type'] == 'income'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                          ),
                          title: Text('${x['amount']} F'),
                          subtitle: Text(
                            '${x['category']} • ${x['transaction_date']}',
                          ),
                          trailing: Text(x['description'] ?? ''),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: add,
      icon: const Icon(Icons.add),
      label: const Text('Mouvement'),
    ),
  );
}

class _Box extends StatelessWidget {
  const _Box(this.a, this.b);
  final String a, b;
  @override
  Widget build(BuildContext c) => Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(a),
          const SizedBox(height: 4),
          Text(b, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

class _MovementDialog extends StatefulWidget {
  const _MovementDialog();
  @override
  State<_MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<_MovementDialog> {
  final amount = TextEditingController(),
      category = TextEditingController(),
      desc = TextEditingController();
  String type = 'income';
  @override
  void dispose() {
    amount.dispose();
    category.dispose();
    desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => AlertDialog(
    title: const Text('Mouvement de trésorerie'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField(
          value: type,
          items: const [
            DropdownMenuItem(value: 'income', child: Text('Entrée d’argent')),
            DropdownMenuItem(value: 'expense', child: Text('Sortie / dépense')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => type = v);
          },
        ),
        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant (F)'),
        ),
        TextField(
          controller: category,
          decoration: const InputDecoration(labelText: 'Catégorie'),
        ),
        TextField(
          controller: desc,
          decoration: const InputDecoration(labelText: 'Description'),
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
          final a = double.tryParse(amount.text);
          if (a == null || a <= 0 || category.text.trim().isEmpty) return;
          await Supabase.instance.client.from('transactions').insert({
            'business_id': await AppSession().businessId(),
            'type': type,
            'amount': a,
            'category': category.text.trim(),
            'description': desc.text.trim(),
          });
          if (c.mounted) Navigator.pop(c, true);
        },
        child: const Text('Enregistrer'),
      ),
    ],
  );
}
