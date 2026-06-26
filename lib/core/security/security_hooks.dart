import 'package:flutter/widgets.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avault/features/auth/providers/auth_provider.dart';

class SecurityLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;

  SecurityLifecycleObserver(this.ref);

  static Future<void> initializeOsShielding() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ref.read(authProvider.notifier).lockVault();
    }
  }
}
