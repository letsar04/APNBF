import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/media/media_service.dart';
import '../../../core/session/app_session.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final db = Supabase.instance.client;
  final session = AppSession();
  late Future<List<Map<String, dynamic>>> future;

  @override void initState() { super.initState(); future = _list(); }
  Future<List<Map<String, dynamic>>> _list() async {
    final id = await session.businessId();
    final data = await db.from('products').select('*, product_images(storage_path)').eq('business_id', id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
  void refresh() => setState(() => future = _list());
  Future<void> add() async { final ok = await showDialog<bool>(context: context, builder: (_) => const _ProductDialog()); if (ok == true) refresh(); }

  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Produits'), actions: [IconButton(onPressed: add, icon: const Icon(Icons.add))]),
    body: FutureBuilder<List<Map<String, dynamic>>>(future: future, builder: (c, s) {
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      final list = s.data!;
      if (list.isEmpty) return const Center(child: Text('Aucun produit.'));
      return ListView.separated(padding: const EdgeInsets.all(16), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) {
        final p = list[i];
        final images = List<Map<String, dynamic>>.from(p['product_images'] ?? const []);
        final path = images.isEmpty ? null : images.first['storage_path']?.toString();
        final imageUrl = path == null ? null : db.storage.from('apnbf-media').getPublicUrl(path);
        return Card(child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: imageUrl == null ? Container(width: 58, height: 58, color: Theme.of(c).colorScheme.primaryContainer, child: const Icon(Icons.inventory_2_outlined)) : Image.network(imageUrl, width: 58, height: 58, fit: BoxFit.cover)),
          title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${p['price']} F • Stock : ${p['quantity']}'),
          trailing: Text(p['status'] ?? ''),
        ));
      });
    }),
    floatingActionButton: FloatingActionButton.extended(onPressed: add, icon: const Icon(Icons.add), label: const Text('Produit')),
  );
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog();
  @override State<_ProductDialog> createState() => _ProductDialogState();
}
class _ProductDialogState extends State<_ProductDialog> {
  final name = TextEditingController(), price = TextEditingController(), qty = TextEditingController(), desc = TextEditingController();
  final media = MediaService();
  XFile? image; bool loading = false;
  @override void dispose() { name.dispose(); price.dispose(); qty.dispose(); desc.dispose(); super.dispose(); }

  @override Widget build(BuildContext c) => AlertDialog(
    title: const Text('Nouveau produit'),
    content: SingleChildScrollView(child: SizedBox(width: 420, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(onTap: () async { final x = await media.pickImage(); if (x != null) setState(() => image = x); }, child: Container(width: double.infinity, height: 150, decoration: BoxDecoration(color: Theme.of(c).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)), child: image == null ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 36), SizedBox(height: 8), Text('Ajouter une photo')]) : FutureBuilder(future: image!.readAsBytes(), builder: (_, s) => s.hasData ? Image.memory(s.data!, fit: BoxFit.cover) : const Center(child: CircularProgressIndicator())))),
      const SizedBox(height: 14),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom du produit')),
      const SizedBox(height: 10), TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix de vente (F CFA)')),
      const SizedBox(height: 10), TextField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantité')),
      const SizedBox(height: 10), TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
    ]))),
    actions: [TextButton(onPressed: loading ? null : () => Navigator.pop(c), child: const Text('Annuler')), FilledButton(onPressed: loading ? null : _save, child: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Créer'))],
  );

  Future<void> _save() async {
    final p = double.tryParse(price.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
    final q = double.tryParse(qty.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
    if (name.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final id = await AppSession().businessId();
      final product = await Supabase.instance.client.from('products').insert({'business_id': id, 'name': name.text.trim(), 'price': p, 'quantity': q, 'description': desc.text.trim(), 'status': q > 0 ? 'available' : 'draft', 'condition': 'used'}).select('id').single();
      if (image != null) await media.uploadProductImage(productId: product['id'], file: image!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d’enregistrer : $e'))); }
    finally { if (mounted) setState(() => loading = false); }
  }
}
