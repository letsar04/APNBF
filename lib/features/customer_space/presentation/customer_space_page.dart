import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSpacePage extends StatefulWidget {
  const CustomerSpacePage({super.key, required this.businessId});
  final String businessId;
  @override State<CustomerSpacePage> createState() => _CustomerSpacePageState();
}
class _CustomerSpacePageState extends State<CustomerSpacePage> {
  final db = Supabase.instance.client;
  late Future<_Catalog> future;
  @override void initState() { super.initState(); future = _load(); }
  Future<_Catalog> _load() async {
    final b = await db.from('public_businesses').select().eq('id', widget.businessId).single();
    final p = await db.from('public_products').select().eq('business_id', widget.businessId).order('created_at', ascending: false);
    final s = await db.from('public_services').select().eq('business_id', widget.businessId).order('name');
    return _Catalog(Map<String, dynamic>.from(b), List<Map<String, dynamic>>.from(p), List<Map<String, dynamic>>.from(s));
  }
  String _normalise(String v) { var n = v.replaceAll(RegExp(r'[^0-9+]'), ''); if (n.startsWith('00')) n = n.substring(2); if (n.startsWith('0')) n = '226${n.substring(1)}'; if (n.startsWith('+')) n = n.substring(1); return n; }
  Future<void> _request({String? productId, String? serviceId, required String type, String? itemName}) async {
    final name = TextEditingController(); final phone = TextEditingController(); final message = TextEditingController(); final qty = TextEditingController(text: '1');
    final ok = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: Text(type == 'quote' ? 'Demander un devis' : 'Commander'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom complet')), const SizedBox(height: 10), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone')), if (productId != null) TextField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantité')), const SizedBox(height: 10), TextField(controller: message, maxLines: 3, decoration: const InputDecoration(labelText: 'Message / précision'))])), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Envoyer'))]));
    if (ok != true) return;
    try {
      await db.from('customer_requests').insert({'business_id': widget.businessId, 'client_name': name.text.trim(), 'phone': phone.text.trim(), 'request_type': type, 'product_id': productId, 'service_id': serviceId, 'quantity': double.tryParse(qty.text.replaceAll(',', '.')) ?? 1, 'message': message.text.trim()});
      name.dispose(); phone.dispose(); message.dispose(); qty.dispose();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande envoyée. Le professionnel pourra vous contacter.')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'))); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: FutureBuilder<_Catalog>(future: future, builder: (context, snapshot) {
    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
    final data = snapshot.data!; final b = data.business; final phone = (b['phone'] ?? '').toString(); final whatsapp = (b['whatsapp'] ?? phone).toString();
    return CustomScrollView(slivers: [SliverAppBar(pinned: true, expandedHeight: 180, flexibleSpace: FlexibleSpaceBar(title: Text(b['name'] ?? 'APNBF'), background: Container(color: Theme.of(context).colorScheme.primaryContainer, child: const Center(child: Icon(Icons.storefront_outlined, size: 70))))),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(b['description'] ?? 'Bienvenue.', style: Theme.of(context).textTheme.bodyLarge), if ((b['address'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(b['address'])), const SizedBox(height: 10), Wrap(spacing: 8, children: [if (phone.isNotEmpty) OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse('tel:$phone')), icon: const Icon(Icons.call), label: const Text('Appeler')), if (whatsapp.isNotEmpty) OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse('https://wa.me/${_normalise(whatsapp)}'), mode: LaunchMode.externalApplication), icon: const Icon(Icons.chat), label: const Text('WhatsApp'))])]))),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('Produits disponibles', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))),
      SliverList(delegate: SliverChildBuilderDelegate((_, i) { final p = data.products[i]; final path = p['image_path']?.toString(); final image = path == null || path.isEmpty ? null : db.storage.from('apnbf-media').getPublicUrl(path); return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(contentPadding: const EdgeInsets.all(10), leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: image == null ? Container(width: 62, height: 62, color: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.inventory_2_outlined)) : Image.network(image, width: 62, height: 62, fit: BoxFit.cover)), title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${p['price']} F CFA • Stock ${p['quantity']}'), trailing: FilledButton(onPressed: () => _request(productId: p['id'], type: 'order', itemName: p['name']), child: const Text('Commander'))))); }, childCount: data.products.length)),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 22, 16, 4), child: Text('Services', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))),
      SliverList(delegate: SliverChildBuilderDelegate((_, i) { final s = data.services[i]; final image = s['image_url']?.toString(); return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Card(child: ListTile(contentPadding: const EdgeInsets.all(10), leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: image == null || image.isEmpty ? Container(width: 62, height: 62, color: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.handyman_outlined)) : Image.network(image, width: 62, height: 62, fit: BoxFit.cover)), title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(s['price_type'] == 'quote' ? 'Sur devis' : 'À partir de ${s['base_price']} F CFA'), trailing: FilledButton(onPressed: () => _request(serviceId: s['id'], type: 'quote', itemName: s['name']), child: const Text('Demander'))))); }, childCount: data.services.length)),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ]);
  }));
}
class _Catalog { final Map<String, dynamic> business; final List<Map<String, dynamic>> products; final List<Map<String, dynamic>> services; const _Catalog(this.business, this.products, this.services); }
