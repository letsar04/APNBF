import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('APNBF', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Votre activité. Simplement suivie.', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              const Text('Application commerciale pensée pour les artisans et commerçants au Burkina Faso.'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(Icons.dashboard_outlined),
                  label: const Text('Ouvrir mon activité'),
                ),
              ),
              const Spacer(),
              const Center(child: Text('APNBF • Burkina Faso')),
            ],
          ),
        ),
      ),
    );
  }
}
