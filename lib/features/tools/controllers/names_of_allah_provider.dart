import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

class AllahName {
  final int id;
  final String name;
  final String meaning;
  final String description;

  AllahName({
    required this.id,
    required this.name,
    required this.meaning,
    required this.description,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      id: json['id'] as int,
      name: json['name'] as String,
      meaning: json['meaning'] as String,
      description: json['description'] as String,
    );
  }
}

class NamesOfAllahState {
  final bool isLoading;
  final String? errorMessage;
  final List<AllahName> allNames;
  final Set<int> favoriteIds;
  final bool showOnlyFavorites;

  const NamesOfAllahState({
    this.isLoading = false,
    this.errorMessage,
    required this.allNames,
    required this.favoriteIds,
    this.showOnlyFavorites = false,
  });

  NamesOfAllahState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<AllahName>? allNames,
    Set<int>? favoriteIds,
    bool? showOnlyFavorites,
  }) {
    return NamesOfAllahState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      allNames: allNames ?? this.allNames,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }
}

class NamesOfAllahNotifier extends StateNotifier<NamesOfAllahState> {
  NamesOfAllahNotifier()
    : super(
        const NamesOfAllahState(isLoading: true, allNames: [], favoriteIds: {}),
      ) {
    loadNames();
  }

  Future<void> loadNames() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/content/allah_names.json',
      );
      final List<dynamic> data = json.decode(response);
      final List<AllahName> names = data
          .map((json) => AllahName.fromJson(json))
          .toList();

      // ✅ Load saved favorites from Hive
      final box = Hive.box('favorites_box');
      final List<dynamic> savedIds = box.get('favorite_name_ids', defaultValue: <dynamic>[]);
      final Set<int> savedFavorites = savedIds.map((e) => e as int).toSet();

      state = state.copyWith(isLoading: false, allNames: names, favoriteIds: savedFavorites);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void toggleFavorite(int nameId) {
    final currentFavorites = Set<int>.from(state.favoriteIds);
    if (currentFavorites.contains(nameId)) {
      currentFavorites.remove(nameId);
    } else {
      currentFavorites.add(nameId);
    }
    state = state.copyWith(favoriteIds: currentFavorites);

    // ✅ Persist favorites to Hive so they survive app restarts
    final box = Hive.box('favorites_box');
    box.put('favorite_name_ids', currentFavorites.toList());
  }

  void toggleShowOnlyFavorites() {
    state = state.copyWith(showOnlyFavorites: !state.showOnlyFavorites);
  }
}

final namesOfAllahProvider =
    StateNotifierProvider<NamesOfAllahNotifier, NamesOfAllahState>((ref) {
      return NamesOfAllahNotifier();
    });
