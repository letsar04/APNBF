import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class ApnbfApp extends StatelessWidget {
  const ApnbfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'APNBF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
