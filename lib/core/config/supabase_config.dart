import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration
///
/// IMPORTANT: Replace these with your actual Supabase credentials
/// You can find these in your Supabase project settings:
/// https://app.supabase.com/project/_/settings/api
class SupabaseConfig {
  SupabaseConfig._();

  /// Your Supabase project URL
  /// Format: https://[project-ref].supabase.co
  static const String url = 'YOUR_SUPABASE_URL';

  /// Your Supabase anonymous key (public)
  /// This is safe to use in client-side code
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Auth state changes stream
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

/// Environment-based configuration
/// Use this for different environments (dev, staging, prod)
class SupabaseEnvironment {
  static const bool isDevelopment = true;

  static String get url {
    if (isDevelopment) {
      return 'YOUR_DEV_SUPABASE_URL';
    }
    return 'YOUR_PROD_SUPABASE_URL';
  }

  static String get anonKey {
    if (isDevelopment) {
      return 'YOUR_DEV_ANON_KEY';
    }
    return 'YOUR_PROD_ANON_KEY';
  }
}
