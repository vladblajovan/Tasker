enum Flavor { dev, prod }

class AppConfig {
  const AppConfig({
    required this.flavor,
    this.supabaseUrl,
    this.supabaseAnonKey,
  });

  final Flavor flavor;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  static late final AppConfig instance;

  bool get isProduction => flavor == Flavor.prod;
}
