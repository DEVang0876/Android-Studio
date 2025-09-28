

const String kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String kSupabaseAnonKey = String.fromEnvironment('SUPABASE_KEY');

bool get supabaseKeysProvided => kSupabaseUrl.isNotEmpty && kSupabaseAnonKey.isNotEmpty;
