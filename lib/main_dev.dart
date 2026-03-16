import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tasker/app.dart';
import 'package:tasker/core/config/app_config.dart';
import 'package:tasker/core/di/injection.dart';
import 'package:tasker/core/init/app_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.instance = const AppConfig(flavor: Flavor.dev);
  await initHive();
  tz.initializeTimeZones();
  await setupDevDependencies();
  runApp(const TodoApp());
}
