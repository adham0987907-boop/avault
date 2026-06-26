import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:avault/core/security/security_hooks.dart';
import 'package:avault/data/models/vault_item_model.dart';
import 'package:avault/features/auth/providers/auth_provider.dart';
import 'package:avault/features/auth/screens/pin_setup_screen.dart';
import 'package:avault/features/auth/screens/pin_verify_screen.dart';
import 'package:avault/features/dashboard/screens/dashboard_screen.dart';

void main() async {
  // التأكد من تهيئة الإطارات البرمجية الأساسية لرفرفة (Flutter) قبل تنفيذ أي سكريبت أمني
  WidgetsFlutterBinding.ensureInitialized();
  
  // تفعيل سياسات الحماية على مستوى نظام التشغيل أندرويد (منع تصوير الشاشة والـ Screen Recording)
  await SecurityLifecycleObserver.initializeOsShielding();

  // تهيئة محرك قاعدة البيانات المحلية المؤمنة وتثبيت المحول الخاص بهيكل البيانات
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(VaultItemModelAdapter());
  }
  
  // فتح صندوق البيانات (Box) المخصص لحفظ بيانات الملفات المشفرة محلياً 100%
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
    // ربط مراقب دورة حياة التطبيق بـ Riverpod لقفل الخزنة فوراً عند الخروج للخلفية
    _lifecycleObserver = SecurityLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    // إلغاء ربط مراقب دورة الحياة لمنع تسريب الذاكرة (Memory Leaks)
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة الأمان والتحقق عبر جهاز البث الخاص بنا
    final authState = ref.watch(authProvider);

    // إعداد نظام التوجيه الذكي والشامل (GoRouter) لإدارة شاشات التطبيق الأمنية بنجاح
    final GoRouter routerConfiguration = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // إذا كان التطبيق يفتح لأول مرة ولم يقم المستخدم بإنشاء PIN
        if (!authState.isInitialized) {
          return '/setup';
        }
        // إذا كان التطبيق مهيأ مسبقاً ولكن الخزنة مغلقة حالياً وتطلب PIN أو بصمة
        if (!authState.isAuthenticated) {
          return '/verify';
        }
        // إذا نجح التحقق وكان المستخدم في إحدى شاشات الدخول، يتم نقله تلقائياً للوحة التحكم
        if (state.matchedLocation == '/setup' || state.matchedLocation == '/verify') {
          return '/dashboard';
        }
        // في الحالات العادية، اترك التوجيه يسير كما هو مطلوب
        return null;
      },
      routes: [
        // شاشة التحميل الأساسية الفورية أثناء معالجة البيانات الأولية
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6750A4),
              ),
            ),
          ),
        ),
        // مسار شاشة إعداد الـ PIN الأولية للمستخدم الجديد
        GoRoute(
          path: '/setup',
          builder: (context, state) => const PinSetupScreen(),
        ),
        // مسار شاشة التحقق من الـ PIN والدخول البيومتري بالبصمة
        GoRoute(
          path: '/verify',
          builder: (context, state) => const PinVerifyScreen(),
        ),
        // مسار لوحة التحكم الرئيسية لإدارة واستيراد وتصفح الملفات المؤمنة
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );

    // بناء واجهة التطبيق الرئيسية مع دعم كامل لتصميم الـ Material 3 والنظام الداكن الافتراضي للأمان
    return MaterialApp.router(
      title: 'AVault',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6750A4),
        scaffoldBackgroundColor: const Color(0xFF141218),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF141218),
          elevation: 0,
        ),
      ),
      routerConfig: routerConfiguration,
    );
  }
}
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
