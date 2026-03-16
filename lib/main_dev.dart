import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:test_app/app.dart';
import 'package:test_app/core/config/app_config.dart';
import 'package:test_app/core/di/injection.dart';
import 'package:test_app/core/init/app_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.instance = const AppConfig(flavor: Flavor.dev);
  await initHive();
  tz.initializeTimeZones();
  setupDevDependencies();
  runApp(const TodoApp());
}
