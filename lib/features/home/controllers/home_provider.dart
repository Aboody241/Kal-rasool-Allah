import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:kal_rasol_allah/core/engine/engine_provider.dart';
import 'package:kal_rasol_allah/core/engine/sunnah_model.dart';
import 'package:kal_rasol_allah/features/home/controllers/streak_provider.dart';

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final List<Sunnah> todaySunnahs;
  final List<Sunnah> allSunnahs;
  final int currentIndex;
  final Set<int> favoriteHadithIds;

  HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.todaySunnahs = const [],
    this.allSunnahs = const [],
    this.currentIndex = 0,
    this.favoriteHadithIds = const {},
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Sunnah>? todaySunnahs,
    List<Sunnah>? allSunnahs,
    int? currentIndex,
    Set<int>? favoriteHadithIds,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      todaySunnahs: todaySunnahs ?? this.todaySunnahs,
      allSunnahs: allSunnahs ?? this.allSunnahs,
      currentIndex: currentIndex ?? this.currentIndex,
      favoriteHadithIds: favoriteHadithIds ?? this.favoriteHadithIds,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref ref;

  HomeNotifier(this.ref) : super(HomeState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final box = Hive.box('favorites_box');
      final savedFavorites =
          box.get('favoriteHadithIds', defaultValue: <int>[]) as List;
      final favoriteIds = Set<int>.from(savedFavorites.cast<int>());
      state = state.copyWith(favoriteHadithIds: favoriteIds);
    } catch (e) {
      // Fallback
    }

    _loadSunnahsFromEngine();
  }

  void _loadSunnahsFromEngine() {
    try {
      final engine = ref.read(engineProvider);
      final sunnahs = engine.getTodaySunnahs();
      final all = engine.getAllSunnahs();
      
      state = state.copyWith(
        isLoading: false,
        todaySunnahs: sunnahs,
        allSunnahs: all,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء تحميل السنن',
      );
    }
  }

  void completeCurrentSunnah() {
    if (state.todaySunnahs.isEmpty) return;
    
    final currentSunnah = state.todaySunnahs[state.currentIndex];
    if (currentSunnah.isCompleted) return;

    final engine = ref.read(engineProvider);
    engine.completeSunnah(currentSunnah.id);
    
    // Refresh engine state in Riverpod (to update streak and stats)
    ref.read(streakProvider.notifier).refreshStats(isFromUserAction: true);

    // Reload sunnahs so the UI reflects the completion status
    _loadSunnahsFromEngine();
  }

  void nextSunnah() {
    if (state.todaySunnahs.isEmpty) return;

    final nextIndex = (state.currentIndex + 1) % state.todaySunnahs.length;
    state = state.copyWith(currentIndex: nextIndex);
  }

  void previousSunnah() {
    if (state.todaySunnahs.isEmpty) return;

    final prevIndex = (state.currentIndex - 1) < 0 
        ? state.todaySunnahs.length - 1 
        : state.currentIndex - 1;
    state = state.copyWith(currentIndex: prevIndex);
  }

  void toggleFavorite(int id) {
    final currentFavorites = Set<int>.from(state.favoriteHadithIds);
    if (currentFavorites.contains(id)) {
      currentFavorites.remove(id);
    } else {
      currentFavorites.add(id);
    }
    state = state.copyWith(favoriteHadithIds: currentFavorites);

    final box = Hive.box('favorites_box');
    box.put('favoriteHadithIds', currentFavorites.toList());
  }

  bool isFavorite(int id) {
    return state.favoriteHadithIds.contains(id);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
