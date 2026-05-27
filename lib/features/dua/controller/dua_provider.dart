import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:kal_rasol_allah/features/dua/data/dua_model.dart';
import 'package:kal_rasol_allah/features/dua/data/dua_list.dart';

const _favoritesBoxName = 'favorites_box';
const _favoritesKey = 'favorite_dua_ids';

// ==========================================
// 1. State Class
// ==========================================
class DuaState {
  final bool isLoading;
  final String? errorMessage;
  final List<DuaModel> allDuas;
  final List<DuaModel> displayedDuas;
  final Set<int> favoriteDuaIds;
  final String selectedCategory;
  final List<String> categories;

  const DuaState({
    this.isLoading = false,
    this.errorMessage,
    required this.allDuas,
    required this.displayedDuas,
    required this.favoriteDuaIds,
    required this.selectedCategory,
    required this.categories,
  });

  DuaState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DuaModel>? allDuas,
    List<DuaModel>? displayedDuas,
    Set<int>? favoriteDuaIds,
    String? selectedCategory,
    List<String>? categories,
  }) {
    return DuaState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      allDuas: allDuas ?? this.allDuas,
      displayedDuas: displayedDuas ?? this.displayedDuas,
      favoriteDuaIds: favoriteDuaIds ?? this.favoriteDuaIds,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
    );
  }
}

// ==========================================
// 2. Controller / Notifier
// ==========================================
class DuaNotifier extends StateNotifier<DuaState> {
  DuaNotifier()
      : super(
          const DuaState(
            isLoading: true,
            allDuas: [],
            displayedDuas: [],
            favoriteDuaIds: {},
            selectedCategory: DuaCategories.all,
            categories: [DuaCategories.all],
          ),
        ) {
    loadDuas(); // Initialize by loading data
  }

  /// Load all Duas asynchronously from JSON file
  Future<void> loadDuas() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/content/dua.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      final List<DuaModel> duas = jsonList.map((json) => DuaModel.fromJson(json)).toList();
      
      // Extract unique categories directly from JSON and add "المفضلة" at the beginning right after "الكل"
      final Set<String> uniqueCategories = {DuaCategories.all, 'المفضلة'};
      for (var dua in duas) {
        uniqueCategories.add(dua.category);
      }

      // ✅ Load saved favorites from Hive
      final box = Hive.box(_favoritesBoxName);
      final List<dynamic> savedIds = box.get(_favoritesKey, defaultValue: <dynamic>[]);
      final Set<int> savedFavorites = savedIds.map((e) => e as int).toSet();

      state = state.copyWith(
        isLoading: false,
        allDuas: duas,
        categories: uniqueCategories.toList(),
        favoriteDuaIds: savedFavorites,
        displayedDuas: _applyFilter(duas, state.selectedCategory, favorites: savedFavorites),
      );
    } catch (e, stacktrace) {
      // Handle loading failure and save the error message
      print('Error loading duas: $e\n$stacktrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Toggle Favorite status using Dua ID
  void toggleFavorite(int duaId) {
    final currentFavorites = Set<int>.from(state.favoriteDuaIds);
    if (currentFavorites.contains(duaId)) {
      currentFavorites.remove(duaId);
    } else {
      currentFavorites.add(duaId);
    }
    
    state = state.copyWith(
      favoriteDuaIds: currentFavorites,
      displayedDuas: _applyFilter(state.allDuas, state.selectedCategory, favorites: currentFavorites),
    );

    // ✅ Persist favorites to Hive so they survive app restarts
    final box = Hive.box(_favoritesBoxName);
    box.put(_favoritesKey, currentFavorites.toList());
  }

  /// Filter Duas by Category
  void filterByCategory(String category) {
    state = state.copyWith(
      selectedCategory: category,
      displayedDuas: _applyFilter(state.allDuas, category),
    );
  }

  /// Get all Duas (resets the category filter)
  void getAllDuas() {
    filterByCategory(DuaCategories.all);
  }

  /// Helper: Check if a specific Dua is in favorites
  bool isFavorite(int duaId) {
    return state.favoriteDuaIds.contains(duaId);
  }

  /// Helper: Get a list of only the favorite Duas
  List<DuaModel> getFavoriteDuasList() {
    return state.allDuas
        .where((dua) => state.favoriteDuaIds.contains(dua.id))
        .toList();
  }

  /// Private Helper: Filter list logic
  List<DuaModel> _applyFilter(List<DuaModel> all, String category, {Set<int>? favorites}) {
    if (category == DuaCategories.all) {
      return all;
    }
    if (category == 'المفضلة') {
      final favs = favorites ?? state.favoriteDuaIds;
      return all.where((dua) => favs.contains(dua.id)).toList();
    }
    return all.where((dua) => dua.category == category).toList();
  }
}

// ==========================================
// 3. Provider
// ==========================================
final duaProvider = StateNotifierProvider<DuaNotifier, DuaState>((ref) {
  return DuaNotifier();
});
