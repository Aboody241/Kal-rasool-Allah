import 'storage_interface.dart';

class DailyTracker {
  final Storage _storage;

  static const String _kLastActiveDate = 'engine_last_active_date';
  static const String _kTodayCompletedIds = 'engine_today_completed_ids';
  static const String _kRecentCompletedIds = 'engine_recent_completed_ids';
  static const String _kHasCompletedToday = 'engine_has_completed_today';
  static const String _kTodaySelectedIds = 'engine_today_selected_ids';
  static const String _kAllCompletedDates = 'engine_all_completed_dates';

  String _lastActiveDate = '';
  Set<int> _todayCompletedIds = {};
  List<int> _todaySelectedIds = [];
  List<int> _recentHistory = [];
  Set<String> _allCompletedDates = {};
  bool _hasCompletedToday = false;

  DailyTracker(this._storage);

  Future<void> init() async {
    _lastActiveDate = await _storage.read(_kLastActiveDate) ?? '';
    
    final todayIdsList = await _storage.read(_kTodayCompletedIds) ?? [];
    _todayCompletedIds = Set<int>.from(todayIdsList.cast<int>());
    
    final recentIdsList = await _storage.read(_kRecentCompletedIds) ?? [];
    _recentHistory = List<int>.from(recentIdsList.cast<int>());

    final selectedIdsList = await _storage.read(_kTodaySelectedIds) ?? [];
    _todaySelectedIds = List<int>.from(selectedIdsList.cast<int>());

    final allDatesList = await _storage.read(_kAllCompletedDates) ?? [];
    _allCompletedDates = Set<String>.from(allDatesList.cast<String>());

    _hasCompletedToday = await _storage.read(_kHasCompletedToday) ?? false;
  }

  /// Returns true if it's a new day, false otherwise.
  bool checkAndResetIfNewDay() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (_lastActiveDate != todayStr) {
      // It's a new day
      _archiveTodayToHistory();
      _todayCompletedIds.clear();
      _todaySelectedIds.clear(); // Clear cached selections for the new day
      _hasCompletedToday = false;
      
      _saveData(_kTodayCompletedIds, _todayCompletedIds.toList());
      _saveData(_kTodaySelectedIds, _todaySelectedIds);
      _saveData(_kHasCompletedToday, _hasCompletedToday);
      
      return true;
    }
    return false;
  }

  /// Archives today's completions into the recent history (max 20 items).
  void _archiveTodayToHistory() {
    _recentHistory.addAll(_todayCompletedIds);
    if (_recentHistory.length > 20) {
      _recentHistory = _recentHistory.sublist(_recentHistory.length - 20);
    }
    _saveData(_kRecentCompletedIds, _recentHistory);
  }

  /// Updates the last active date to today.
  void updateLastActiveDate() {
    final now = DateTime.now();
    _lastActiveDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _saveData(_kLastActiveDate, _lastActiveDate);
  }

  /// Marks a sunnah as completed today.
  /// Returns true if this was the very first completion today.
  bool markSunnahCompleted(int id) {
    if (_todayCompletedIds.contains(id)) return false;
    
    _todayCompletedIds.add(id);
    _saveData(_kTodayCompletedIds, _todayCompletedIds.toList());

    bool wasFirstCompletion = !_hasCompletedToday;
    if (!_hasCompletedToday) {
      _hasCompletedToday = true;
      _saveData(_kHasCompletedToday, _hasCompletedToday);

      // Track this date as a completed date
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      if (!_allCompletedDates.contains(todayStr)) {
        _allCompletedDates.add(todayStr);
        _saveData(_kAllCompletedDates, _allCompletedDates.toList());
      }
    }
    
    return wasFirstCompletion;
  }

  /// Force mark today as completed (e.g. via Athkar or daily dhikr goal)
  /// Returns true if this was the first completion today.
  bool forceCompleteToday() {
    if (_hasCompletedToday) return false;
    
    _hasCompletedToday = true;
    _saveData(_kHasCompletedToday, _hasCompletedToday);

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    if (!_allCompletedDates.contains(todayStr)) {
      _allCompletedDates.add(todayStr);
      _saveData(_kAllCompletedDates, _allCompletedDates.toList());
    }
    
    return true;
  }

  bool isCompletedToday(int id) => _todayCompletedIds.contains(id);
  
  bool get hasCompletedToday => _hasCompletedToday;
  
  String get lastActiveDate => _lastActiveDate;
  
  List<int> get recentHistory => _recentHistory;
  
  Set<int> get todayCompletedIds => _todayCompletedIds;

  List<int> get todaySelectedIds => _todaySelectedIds;

  Set<String> get allCompletedDates => _allCompletedDates;

  void saveTodaySelectedIds(List<int> ids) {
    _todaySelectedIds = ids;
    _saveData(_kTodaySelectedIds, _todaySelectedIds);
  }

  Future<void> _saveData(String key, dynamic value) async {
    await _storage.save(key, value);
  }
}
