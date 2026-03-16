import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tasker/app.dart';
import 'package:tasker/core/config/app_config.dart';
import 'package:tasker/core/di/injection.dart';
import 'package:tasker/core/init/app_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  AppConfig.instance = const AppConfig(
    flavor: Flavor.prod,
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  await initHive();
  tz.initializeTimeZones();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  setupProdDependencies();
  runApp(const TodoApp());
}
