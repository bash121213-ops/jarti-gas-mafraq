import 'package:shared_preferences/shared_preferences.dart';

/// Tiny persistence layer.
///
/// Writes go to [SharedPreferences] on device and to an in-memory map as well,
/// so the same code can be used in widget tests without a platform channel.
class LocalStore {
  LocalStore._(this._prefs, this._memory);

  factory LocalStore.memory() => LocalStore._(null, <String, String>{});

  static Future<LocalStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStore._(prefs, <String, String>{});
  }

  final SharedPreferences? _prefs;
  final Map<String, String> _memory;

  String? read(String key) => _prefs?.getString(key) ?? _memory[key];

  Future<void> write(String key, String value) async {
    _memory[key] = value;
    await _prefs?.setString(key, value);
  }

  Future<void> remove(String key) async {
    _memory.remove(key);
    await _prefs?.remove(key);
  }
}
