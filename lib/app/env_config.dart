import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: "android/app/src/main/assets/.env");
  }

  // Supabase
  static String get supabaseUrl => dotenv.get('SUPABASE_URL');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');

  // App
  static String get appName => dotenv.get('APP_NAME');
  static bool get isDebug => dotenv.get('DEBUG_MODE') == 'true';
  static int get apiTimeout => int.parse(dotenv.get('API_TIMEOUT'));
}