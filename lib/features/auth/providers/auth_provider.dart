import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:avault/core/security/crypto_engine.dart';

class AuthState {
  final bool isInitialized;
  final bool isAuthenticated;
  final bool biometricCapable;
  final List<int>? runtimeMasterKey;

  AuthState({
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.biometricCapable = false,
    this.runtimeMasterKey,
  });

  AuthState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    bool? biometricCapable,
    List<int>? runtimeMasterKey,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      biometricCapable: biometricCapable ?? this.biometricCapable,
      runtimeMasterKey: runtimeMasterKey ?? this.runtimeMasterKey,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthNotifier() : super(AuthState()) {
    verifyDeviceEnvironmentState();
  }

  Future<void> verifyDeviceEnvironmentState() async {
    final pinExists = await _storage.containsKey(key: 'vault_pin_hash');
    final hardwareBiometricCapable = await _localAuth.canCheckBiometrics;
    state = AuthState(
      isInitialized: pinExists,
      isAuthenticated: false,
      biometricCapable: hardwareBiometricCapable,
    );
  }

  Future<bool> registerNewUserVaultPin(String rawPin) async {
    try {
      final enc.Key structuralKey = CryptoEngine.deriveKeyFromPin(rawPin);
      await _storage.write(key: 'vault_pin_hash', value: structuralKey.base64);
      state = state.copyWith(
        isInitialized: true,
        isAuthenticated: true,
        runtimeMasterKey: structuralKey.bytes,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  void lockVault() {
    state = state.copyWith(
      isAuthenticated: false,
      runtimeMasterKey: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
