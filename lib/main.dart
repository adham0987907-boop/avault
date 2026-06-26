import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:avault/core/security/security_hooks.dart';
import 'package:avault/data/models/vault_item_model.dart';
import 'package:avault/features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SecurityLifecycleObserver.initializeOsShielding();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(VaultItemModelAdapter());
  }
  await Hive.openBox<VaultItemModel>('vault_metadata_box');

  runApp(
    const ProviderScope(
      child: AVaultEngineRoot(),
    ),
  );
}

class AVaultEngineRoot extends ConsumerStatefulWidget {
  const AVaultEngineRoot({super.key});

  @override
  ConsumerState<AVaultEngineRoot> createState() => _AVaultEngineRootState();
}

class _AVaultEngineRootState extends ConsumerState<AVaultEngineRoot> {
  late SecurityLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = SecurityLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final GoRouter routerConfiguration = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        if (!authState.isInitialized) {
          return '/setup';
        }
        if (!authState.isAuthenticated) {
          return '/verify';
        }
        if (state.matchedLocation == '/setup' || state.matchedLocation == '/verify') {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
        GoRoute(
          path: '/setup',
          builder: (context, state) => const Scaffold(body: Center(child: Text("تسجيل الـ PIN الجديد"))),
        ),
        GoRoute(
          path: '/verify',
          builder: (context, state) => const Scaffold(body: Center(child: Text("تأكيد الـ PIN والدخول"))),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const Scaffold(body: Center(child: Text("لوحة التحكم التفاعلية"))),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'AVault',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6750A4),
        scaffoldBackgroundColor: const Color(0xFF141218),
      ),
      routerConfig: routerConfiguration,
    );
  }
}
