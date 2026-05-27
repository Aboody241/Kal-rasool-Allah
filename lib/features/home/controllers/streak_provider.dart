import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kal_rasol_allah/core/engine/engine_provider.dart';

class StreakState {
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;
  final int dailyPoints;
  final Map<String, dynamic> levelInfo;
  final bool streakJustIncremented;

  StreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalPoints = 0,
    this.dailyPoints = 0,
    this.levelInfo = const {'level': 1, 'progress': 0.0},
    this.streakJustIncremented = false,
  });

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalPoints,
    int? dailyPoints,
    Map<String, dynamic>? levelInfo,
    bool? streakJustIncremented,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      dailyPoints: dailyPoints ?? this.dailyPoints,
      levelInfo: levelInfo ?? this.levelInfo,
      streakJustIncremented: streakJustIncremented ?? this.streakJustIncremented,
    );
  }
}

class StreakNotifier extends StateNotifier<StreakState> {
  final Ref ref;
  
  StreakNotifier(this.ref) : super(StreakState()) {
    refreshStats();
  }

  void refreshStats() {
    try {
      final engine = ref.read(engineProvider);
      final stats = engine.getStats();
      
      final currentStreak = stats['currentStreak'] as int;
      final longestStreak = stats['longestStreak'] as int;
      final hasCompletedToday = stats['hasCompletedToday'] as bool;
      
      // The streakJustIncremented logic: if streak > 0 and hasCompletedToday is true,
      // we check if currentStreak increased from our previous state.
      // Or simply, trigger animation if currentStreak > previous currentStreak
      bool streakJustIncremented = false;
      if (currentStreak > state.currentStreak && hasCompletedToday) {
        streakJustIncremented = true;
      }
      
      state = state.copyWith(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        totalPoints: stats['totalPoints'] as int,
        dailyPoints: stats['dailyPoints'] as int,
        levelInfo: stats['levelInfo'] as Map<String, dynamic>,
        streakJustIncremented: streakJustIncremented,
      );
    } catch (e) {
      // Fallback
    }
  }

  void markAnimationPlayed() {
    state = state.copyWith(streakJustIncremented: false);
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier(ref);
});
