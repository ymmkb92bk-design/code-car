/// Supabase project config. The URL is public info (safe to default); the anon
/// key is meant for client apps too, but is still passed at build time rather
/// than hardcoded — run with:
///   flutter run --dart-define=SUPABASE_ANON_KEY=xxxx
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bflfuhgqhdognpnujvit.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => supabaseAnonKey.isNotEmpty;
}
