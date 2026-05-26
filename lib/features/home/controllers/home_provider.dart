import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> ahadith;
  final int currentIndex;

  HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.ahadith = const [],
    this.currentIndex = 0,
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? ahadith,
    int? currentIndex,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      ahadith: ahadith ?? this.ahadith,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState()) {
    _loadAhadith();
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
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
