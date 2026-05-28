import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kal_rasol_allah/core/engine/engine_provider.dart';

class StreakState {
  final int currentStreak;
  final int longestStreak;
  final bool streakJustIncremented;
  final Set<DateTime> allCompletedDates;

  StreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.streakJustIncremented = false,
    this.allCompletedDates = const {},
  });

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    bool? streakJustIncremented,
    Set<DateTime>? allCompletedDates,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakJustIncremented: streakJustIncremented ?? this.streakJustIncremented,
      allCompletedDates: allCompletedDates ?? this.allCompletedDates,
    );
  }
}

class StreakNotifier extends StateNotifier<StreakState> {
  final Ref ref;
  
  StreakNotifier(this.ref) : super(StreakState()) {
    refreshStats();
  }

  void refreshStats({bool isFromUserAction = false}) {
    try {
      final engine = ref.read(engineProvider);
      final stats = engine.getStats();

      final currentStreak = stats['currentStreak'] as int;
      final longestStreak = stats['longestStreak'] as int;
      final hasCompletedToday = stats['hasCompletedToday'] as bool;
      final Set<String> datesStrs = stats['allCompletedDates'] as Set<String>? ?? {};
      final Set<DateTime> dates = datesStrs.map((s) => DateTime.parse(s)).toSet();

      bool streakJustIncremented = false;
      if (isFromUserAction && currentStreak > state.currentStreak && hasCompletedToday) {
        streakJustIncremented = true;
      }

      state = state.copyWith(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        streakJustIncremented: streakJustIncremented,
        allCompletedDates: dates,
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
