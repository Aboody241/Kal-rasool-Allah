import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> ahadith;
  final int currentIndex;
  final Set<int> favoriteHadithIds;

  HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.ahadith = const [],
    this.currentIndex = 0,
    this.favoriteHadithIds = const {},
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? ahadith,
    int? currentIndex,
    Set<int>? favoriteHadithIds,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      ahadith: ahadith ?? this.ahadith,
      currentIndex: currentIndex ?? this.currentIndex,
      favoriteHadithIds: favoriteHadithIds ?? this.favoriteHadithIds,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState()) {
    _loadFavoritesAndAhadith();
  }

  Future<void> _loadFavoritesAndAhadith() async {
    try {
      final box = Hive.box('favorites_box');
      final savedFavorites = box.get('favoriteHadithIds', defaultValue: <int>[]) as List;
      final favoriteIds = Set<int>.from(savedFavorites.cast<int>());
      state = state.copyWith(favoriteHadithIds: favoriteIds);
    } catch (e) {
      // Fallback in case of storage issue
    }
    await _loadAhadith();
  }

  Future<void> _loadAhadith() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final String data = await rootBundle.loadString('assets/content/ahadith.json');
      final List<dynamic> loadedAhadith = jsonDecode(data);
      
      if (loadedAhadith.isNotEmpty) {
        // حساب الحديث اليومي بناءً على رقم اليوم في السنة
        // عشان يفضل نفس الحديث طول اليوم حتى لو التطبيق اتقفل واتفتح
        final today = DateTime.now();
        final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
        final index = dayOfYear % loadedAhadith.length;

        state = state.copyWith(
          isLoading: false,
          ahadith: loadedAhadith,
          currentIndex: index,
        );
      } else {
         state = state.copyWith(
          isLoading: false,
          errorMessage: 'لا توجد أحاديث',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء تحميل الأحاديث',
      );
    }
  }

  // يمكن استخدامها لو حابين نغير الحديث يدوياً
  void nextHadith() {
    if (state.ahadith.isEmpty) return;
    
    final nextIndex = (state.currentIndex + 1) % state.ahadith.length;
    state = state.copyWith(currentIndex: nextIndex);
  }

  // حفظ وإلغاء حفظ الحديث من المفضلة
  void toggleFavorite(int hadithId) {
    final currentFavorites = Set<int>.from(state.favoriteHadithIds);
    if (currentFavorites.contains(hadithId)) {
      currentFavorites.remove(hadithId);
    } else {
      currentFavorites.add(hadithId);
    }
    state = state.copyWith(favoriteHadithIds: currentFavorites);
    
    // Save to Hive
    final box = Hive.box('favorites_box');
    box.put('favoriteHadithIds', currentFavorites.toList());
  }

  bool isFavorite(int hadithId) {
    return state.favoriteHadithIds.contains(hadithId);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
