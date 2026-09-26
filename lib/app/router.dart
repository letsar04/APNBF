import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_page.dart';
import '../features/clients/presentation/client_detail_page.dart';
import '../features/clients/presentation/clients_page.dart';
import '../features/credits/presentation/credits_page.dart';
import '../features/customer_requests/presentation/customer_requests_page.dart';
import '../features/customer_space/presentation/customer_space_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/finance/presentation/finance_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/products/presentation/products_page.dart';
import '../features/preorders/presentation/preorders_page.dart';
import '../features/services/presentation/services_page.dart';
import '../features/share/presentation/share_qr_page.dart';

final appRouter = GoRouter(initialLocation: '/', routes: [
  GoRoute(path: '/', builder: (context, state) => const HomePage()),
  GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
  GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
  GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
  GoRoute(path: '/clients', builder: (context, state) => const ClientsPage()),
  GoRoute(path: '/clients/:id', builder: (context, state) => ClientDetailPage(clientId: state.pathParameters['id']!)),
  GoRoute(path: '/products', builder: (context, state) => const ProductsPage()),
  GoRoute(path: '/services', builder: (context, state) => const ServicesPage()),
  GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
  GoRoute(path: '/preorders', builder: (context, state) => const PreordersPage()),
  GoRoute(path: '/credits', builder: (context, state) => const CreditsPage()),
  GoRoute(path: '/finance', builder: (context, state) => const FinancePage()),
  GoRoute(path: '/requests', builder: (context, state) => const CustomerRequestsPage()),
  GoRoute(path: '/share', builder: (context, state) => const ShareQrPage()),
  GoRoute(path: '/client-space/:businessId', builder: (context, state) => CustomerSpacePage(businessId: state.pathParameters['businessId']!)),
]);
