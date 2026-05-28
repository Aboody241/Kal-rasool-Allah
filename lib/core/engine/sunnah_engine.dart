import 'dart:math';

import 'sunnah_model.dart';
import 'storage_interface.dart';
import 'daily_tracker.dart';
import 'streak_manager.dart';
import 'recommendation_engine.dart';

class SunnahEngine {
  late final Storage _storage;
  
  late final DailyTracker _dailyTracker;
  late final StreakManager _streakManager;
  late final RecommendationEngine _recommendationEngine;

  List<Sunnah> _allSunnahs = [];

  Future<void> init(Storage storage, List<dynamic> sunnahJsonList) async {
    _storage = storage;

    // Initialize sub-systems
    _dailyTracker = DailyTracker(_storage);
    _streakManager = StreakManager(_storage);
    _recommendationEngine = RecommendationEngine();

    await _dailyTracker.init();
    await _streakManager.init();

    // Parse data
    _allSunnahs = sunnahJsonList
        .map((json) => Sunnah.fromJson(json as Map<String, dynamic>))
        .toList();

    // Sync in-memory model state with tracked completed IDs
    for (var sunnah in _allSunnahs) {
      if (_dailyTracker.isCompletedToday(sunnah.id)) {
        sunnah.isCompleted = true;
      }
    }

    resetIfNewDay();
  }

  void resetIfNewDay() {
    bool isNewDay = _dailyTracker.checkAndResetIfNewDay();
    if (isNewDay) {
      _streakManager.checkMissedDays(_dailyTracker.lastActiveDate);

      // Reset model flags
      for (var sunnah in _allSunnahs) {
        sunnah.isCompleted = false;
      }
    }
  }

  /// Expose all sunnahs for favorites list mapping
  List<Sunnah> getAllSunnahs() => _allSunnahs;

  List<Sunnah> getTodaySunnahs() {
    // Level is always 1 — no points system
    const int level = 1;
    final sunnahs = _recommendationEngine.getTodaySunnahs(
      level,
      _allSunnahs,
      _dailyTracker.recentHistory,
      _dailyTracker.todayCompletedIds,
      _dailyTracker.todaySelectedIds,
    );

    // Cache the selection if we generated new ones
    if (_dailyTracker.todaySelectedIds.isEmpty && sunnahs.isNotEmpty) {
      _dailyTracker.saveTodaySelectedIds(sunnahs.map((s) => s.id).toList());
    }

    return sunnahs;
  }

  void completeSunnah(int id) {
    if (_dailyTracker.isCompletedToday(id)) {
      return; // Prevent duplicate
    }

    final sunnahIndex = _allSunnahs.indexWhere((s) => s.id == id);
    if (sunnahIndex == -1) return;

    final sunnah = _allSunnahs[sunnahIndex];
    sunnah.isCompleted = true;

    // Update Completion & Track if first
    bool isFirstCompletionToday = _dailyTracker.markSunnahCompleted(id);

    // Update Streak (Anti-Cheat: only affects streak once per day)
    if (isFirstCompletionToday) {
      _streakManager.incrementStreak();
      _dailyTracker.updateLastActiveDate();
    }
  }

  int getStreak() => _streakManager.currentStreak;

  Map<String, dynamic> getStats() {
    return {
      ..._streakManager.getStreakStats(),
      'completedTodayCount': _dailyTracker.todayCompletedIds.length,
      'hasCompletedToday': _dailyTracker.hasCompletedToday,
      'allCompletedDates': _dailyTracker.allCompletedDates,
    };
  }

  Sunnah? getRandomSunnah() {
    var uncompleted = _allSunnahs.where((s) => !_dailyTracker.isCompletedToday(s.id)).toList();
    if (uncompleted.isEmpty) return null;
    return uncompleted[Random().nextInt(uncompleted.length)];
  }
}
