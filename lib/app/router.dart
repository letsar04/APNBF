import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/home/presentation/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
  ],
);
