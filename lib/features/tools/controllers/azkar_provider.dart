import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:kal_rasol_allah/features/dua/data/dua_model.dart';

class AzkarState {
  final bool isLoading;
  final String? errorMessage;
  final List<DuaModel> allAzkar;
  final List<String> categories;
  final Set<int> favoriteZikrIds; // Tracks favorited Zikr IDs

  const AzkarState({
    this.isLoading = false,
    this.errorMessage,
    required this.allAzkar,
    required this.categories,
    required this.favoriteZikrIds,
  });

  AzkarState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DuaModel>? allAzkar,
    List<String>? categories,
    Set<int>? favoriteZikrIds,
  }) {
    return AzkarState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      allAzkar: allAzkar ?? this.allAzkar,
      categories: categories ?? this.categories,
      favoriteZikrIds: favoriteZikrIds ?? this.favoriteZikrIds,
    );
  }
}

class AzkarNotifier extends StateNotifier<AzkarState> {
  AzkarNotifier()
      : super(const AzkarState(
          isLoading: true,
          allAzkar: [],
          categories: [],
          favoriteZikrIds: {},
        )) {
    loadAzkar();
  }

  Future<void> loadAzkar() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/content/azkar.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      final List<DuaModel> azkar = jsonList.map((json) => DuaModel.fromJson(json)).toList();
      
      // Filter only the categories that represent Azkar (and not general Duas)
      final List<String> azkarCategories = [
        'أذكار الصباح',
        'أذكار المساء',
        'أذكار النوم',
        'أذكار بعد الصلاة',
      ];

      // ✅ Load saved favorites from Hive
      final box = Hive.box('favorites_box');
      final List<dynamic> savedIds = box.get('favorite_zikr_ids', defaultValue: <dynamic>[]);
      final Set<int> savedFavorites = savedIds.map((e) => e as int).toSet();

      state = state.copyWith(
        isLoading: false,
        allAzkar: azkar,
        categories: azkarCategories,
        favoriteZikrIds: savedFavorites,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Toggles favorite status of an Azkar item
  void toggleFavorite(int zikrId) {
    final currentFavorites = Set<int>.from(state.favoriteZikrIds);
    if (currentFavorites.contains(zikrId)) {
      currentFavorites.remove(zikrId);
    } else {
      currentFavorites.add(zikrId);
    }
    state = state.copyWith(favoriteZikrIds: currentFavorites);

    // ✅ Persist favorites to Hive so they survive app restarts
    final box = Hive.box('favorites_box');
    box.put('favorite_zikr_ids', currentFavorites.toList());
  }

  // Check if Zikr is favorite
  bool isFavorite(int zikrId) {
    return state.favoriteZikrIds.contains(zikrId);
  }
}

final azkarProvider = StateNotifierProvider<AzkarNotifier, AzkarState>((ref) {
  return AzkarNotifier();
});
