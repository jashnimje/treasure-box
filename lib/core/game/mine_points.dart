import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lifetime mining points from the home-wall easter egg, persisted locally.
/// Purely cosmetic bragging rights - never touches the real inventory.
class MinePointsNotifier extends Notifier<int> {
  static const _prefsKey = 'mine_points_total';

  @override
  int build() {
    _load();
    return 0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_prefsKey) ?? 0;
    if (stored != state) state = stored;
  }

  Future<void> add(int points) async {
    state += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, state);
  }
}

final minePointsProvider =
    NotifierProvider<MinePointsNotifier, int>(MinePointsNotifier.new);
