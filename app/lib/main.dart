import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/storage/local_store.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The backend is optional for the prototype. When the two public values are
  // provided with --dart-define, Supabase starts; otherwise the local demo
  // repositories keep the app fully usable.
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  final store = await LocalStore.open();
  final state = AppState(store: store);
  await state.bootstrap();

  runApp(JartiApp(state: state));
}
