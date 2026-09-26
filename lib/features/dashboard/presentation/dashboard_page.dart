import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon activité')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _WelcomeCard(),
          SizedBox(height: 16),
          Row(children: [Expanded(child: _MetricCard(title: 'Ventes', value: '0 F')), SizedBox(width: 12), Expanded(child: _MetricCard(title: 'À recevoir', value: '0 F'))]),
          SizedBox(height: 12),
          Row(children: [Expanded(child: _MetricCard(title: 'Dépenses', value: '0 F')), SizedBox(width: 12), Expanded(child: _MetricCard(title: 'Commandes', value: '0'))]),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: const [
          CircleAvatar(radius: 26, child: Icon(Icons.storefront_outlined)),
          SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bienvenue sur APNBF', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Le tableau de bord sera connecté à Supabase dans la prochaine étape.'),
          ])),
        ]),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), const SizedBox(height: 8), Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))])));
  }
}
