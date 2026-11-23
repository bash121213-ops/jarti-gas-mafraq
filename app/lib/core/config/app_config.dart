/// App-wide configuration.
///
/// Secrets never live in this file. Supabase credentials are supplied at build
/// time with `--dart-define` (see README) and read from the environment.
class AppConfig {
  AppConfig._();

  static const String appName = 'جَرّتي';
  static const String cityName = 'المفرق';

  /// Demo verification code used by the local auth repository until the
  /// Supabase phone/OTP provider is connected.
  static const String demoOtpCode = '123456';

  /// ETA shown while the delivery is on its way (demo value).
  static const int defaultEtaMinutes = 15;

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// True only when both public Supabase values were provided at build time.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
