import 'dart:math';
import 'sunnah_model.dart';

class RecommendationEngine {
  /// Selects 1-3 sunnahs based on user level.
  /// Applies fair random selection and prevents repeating recent sunnahs or ones already selected today.
  /// If [todaySelectedIds] is not empty, it returns those specific sunnahs instead of regenerating.
  List<Sunnah> getTodaySunnahs(
    int level, 
    List<Sunnah> allSunnahs, 
    List<int> recentHistory, 
    Set<int> todayCompletedIds,
    List<int> todaySelectedIds,
  ) {
    // 0. If we already selected sunnahs for today, return them!
    if (todaySelectedIds.isNotEmpty) {
      return allSunnahs.where((s) => todaySelectedIds.contains(s.id)).toList();
    }

    // 1. Filter out recent and today's completed items
    List<Sunnah> available = allSunnahs.where((s) {
      return !recentHistory.contains(s.id) && !todayCompletedIds.contains(s.id);
    }).toList();

    // Fallback: If somehow the user has exhausted all sunnahs recently
    if (available.isEmpty) {
      available = List.from(allSunnahs);
      available.removeWhere((s) => todayCompletedIds.contains(s.id)); // still exclude what's completed today
      if (available.isEmpty) return []; // Truly nothing left
    }

    // Shuffle for random fairness
    available.shuffle();

    List<Sunnah> recommendations = [];
    
    // Group by difficulty
    var easyList = available.where((s) => s.difficulty == 'easy').toList();
    var mediumList = available.where((s) => s.difficulty == 'medium').toList();
    var hardList = available.where((s) => s.difficulty == 'hard').toList();

    // Pick function helper
    Sunnah? pickRandom(List<Sunnah> list) {
      if (list.isEmpty) return null;
      return list.removeAt(Random().nextInt(list.length));
    }

    if (level == 1) {
      // Beginner -> 1 easy
      final picked = pickRandom(easyList);
      if (picked != null) recommendations.add(picked);
    } else if (level == 2) {
      // Intermediate -> 2 mixed (easy, medium)
      final p1 = pickRandom(easyList) ?? pickRandom(mediumList);
      final p2 = pickRandom(mediumList) ?? pickRandom(easyList);
      if (p1 != null) recommendations.add(p1);
      if (p2 != null) recommendations.add(p2);
    } else {
      // Advanced -> 3 mixed (easy, medium, hard)
      final p1 = pickRandom(easyList) ?? pickRandom(mediumList);
      final p2 = pickRandom(mediumList) ?? pickRandom(hardList);
      final p3 = pickRandom(hardList) ?? pickRandom(mediumList) ?? pickRandom(easyList);
      if (p1 != null) recommendations.add(p1);
      if (p2 != null) recommendations.add(p2);
      if (p3 != null) recommendations.add(p3);
    }

    // If somehow recommendation is still empty due to strict difficulty mismatch, just take from available
    if (recommendations.isEmpty && available.isNotEmpty) {
      recommendations.add(available.first);
    }

    return recommendations;
  }
}
