import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:avault/app/app.dart';
import 'package:avault/core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await setupServiceLocator();

  runApp(
    const ProviderScope(
      child: AvaultApp(),
    ),
  );
}
