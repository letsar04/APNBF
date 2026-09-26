import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/brand/apnbf_logo.dart';
import '../../../core/session/app_session.dart';

class ShareQrPage extends StatefulWidget { const ShareQrPage({super.key}); @override State<ShareQrPage> createState() => _ShareQrPageState(); }
class _ShareQrPageState extends State<ShareQrPage> {
  final session = AppSession(); late Future<String> businessFuture;
  static const downloadUrl = 'https://github.com/letsar04/APNBF/releases/latest/download/APNBF.apk';
  @override void initState() { super.initState(); businessFuture = session.businessId(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('QR & partage')), body: FutureBuilder<String>(future: businessFuture, builder: (context, snapshot) {
    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
    final clientLink = 'apnbf://client-space/${snapshot.data!}';
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 32), children: [const Center(child: ApnbfLogo(height: 52)), const SizedBox(height: 16), Text('Fais connaître ton activité', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Un QR pour installer APNBF et un QR pour ouvrir ta vitrine client.', textAlign: TextAlign.center), const SizedBox(height: 20), _QrCard(title: 'Installer APNBF', subtitle: 'À imprimer sur tes affiches, cartes et factures.', data: downloadUrl, button: 'Télécharger'), const SizedBox(height: 14), _QrCard(title: 'Ouvrir ma vitrine client', subtitle: 'Depuis un téléphone où APNBF est installé.', data: clientLink, button: 'Ouvrir')]);
  });
}
class _QrCard extends StatelessWidget { const _QrCard({required this.title, required this.subtitle, required this.data, required this.button}); final String title, subtitle, data, button; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: data, size: 210, backgroundColor: Colors.white)), const SizedBox(height: 10), SelectableText(data, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 10), OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse(data), mode: LaunchMode.externalApplication), icon: const Icon(Icons.open_in_new), label: Text(button))]))); }
