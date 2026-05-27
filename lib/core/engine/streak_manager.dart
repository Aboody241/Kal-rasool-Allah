import 'storage_interface.dart';

class StreakManager {
  final Storage _storage;

  static const String _kCurrentStreak = 'engine_current_streak';
  static const String _kLongestStreak = 'engine_longest_streak';

  int _currentStreak = 0;
  int _longestStreak = 0;

  StreakManager(this._storage);

  Future<void> init() async {
    _currentStreak = await _storage.read(_kCurrentStreak) ?? 0;
    _longestStreak = await _storage.read(_kLongestStreak) ?? 0;
  }

  /// Evaluates if the streak should be reset based on missed days.
  void checkMissedDays(String lastActiveDateStr) {
    if (lastActiveDateStr.isEmpty) return;
    
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    final lastActiveDate = DateTime.parse(lastActiveDateStr);
    final todayDate = DateTime.parse(todayStr);
    
    final difference = todayDate.difference(lastActiveDate).inDays;
    
    if (difference > 1) {
      resetStreak();
    }
  }

  /// Increments the streak safely.
  void incrementStreak() {
    _currentStreak += 1;
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
      _saveData(_kLongestStreak, _longestStreak);
    }
    _saveData(_kCurrentStreak, _currentStreak);
  }

  /// Resets the current streak to zero.
  void resetStreak() {
    _currentStreak = 0;
    _saveData(_kCurrentStreak, _currentStreak);
  }

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  Map<String, dynamic> getStreakStats() {
    return {
      'currentStreak': _currentStreak,
      'longestStreak': _longestStreak,
    };
  }

  Future<void> _saveData(String key, dynamic value) async {
    await _storage.save(key, value);
  }
}
