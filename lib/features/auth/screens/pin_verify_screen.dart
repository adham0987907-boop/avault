import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avault/features/auth/providers/auth_provider.dart';

class PinVerifyScreen extends ConsumerStatefulWidget {
  const PinVerifyScreen({super.key});

  @override
  ConsumerState<PinVerifyScreen> createState() => _PinVerifyScreenState();
}

class _PinVerifyScreenState extends ConsumerState<PinVerifyScreen> {
  final TextEditingController _verifyController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    // محاولة فتح التطبيق بالبصمة تلقائياً لو مدعومة في الجهاز
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).executeBiometricAuthenticationPass();
    });
  }

  void _verify() async {
    setState(() => _error = null);
    final success = await ref.read(authProvider.notifier).submitVerificationPin(_verifyController.text);
    if (!success) {
      setState(() => _error = "رمز الحماية الـ PIN غير صحيح");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.security_rounded, size: 80, color: Color(0xFF6750A4)),
              const SizedBox(height: 24),
              const Text(
                "الخزنة مغلقة، أدخل الـ PIN",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _verifyController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: "رمز الـ PIN الخاص بك",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _verify,
                style: FilledButton.styleFrom(padding: const EdgeInsets.vertical(16)),
                child: const Text("فتح قفل التطبيق"),
              ),
              if (authState.biometricCapable) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => ref.read(authProvider.notifier).executeBiometricAuthenticationPass(),
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text("استخدام بصمة الإصبع"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.vertical(16)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
