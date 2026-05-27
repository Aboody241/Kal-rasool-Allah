import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

class SebhaState {
  final int count;
  final int currentZikrIndex;
  final List<String> azkarList;
  final int rounds;

  SebhaState({
    required this.count,
    required this.currentZikrIndex,
    required this.azkarList,
    this.rounds = 0,
  });

  SebhaState copyWith({
    int? count,
    int? currentZikrIndex,
    List<String>? azkarList,
    int? rounds,
  }) {
    return SebhaState(
      count: count ?? this.count,
      currentZikrIndex: currentZikrIndex ?? this.currentZikrIndex,
      azkarList: azkarList ?? this.azkarList,
      rounds: rounds ?? this.rounds,
    );
  }
}

class SebhaNotifier extends StateNotifier<SebhaState> {
  static const List<String> defaultAzkar = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'استغفر الله',
    'سبحان الله وبحمده',
    'سبحان الله العظيم',
    'لا حول ولا قوة إلا بالله',
    'اللهم صلِّ على محمد',
  ];

  SebhaNotifier()
      : super(SebhaState(
          count: Hive.box('sebha_box').get('count', defaultValue: 0) as int,
          currentZikrIndex: Hive.box('sebha_box').get('currentZikrIndex', defaultValue: 0) as int,
          rounds: Hive.box('sebha_box').get('rounds', defaultValue: 0) as int,
          azkarList: List<String>.from(
            Hive.box('sebha_box').get('azkarList', defaultValue: defaultAzkar) as List,
          ),
        ));

  void _saveToHive() {
    final box = Hive.box('sebha_box');
    box.put('count', state.count);
    box.put('currentZikrIndex', state.currentZikrIndex);
    box.put('rounds', state.rounds);
    box.put('azkarList', state.azkarList);
  }

  void increment() {
    int newCount = state.count + 1;
    int newRounds = state.rounds;
    if (newCount > 33) {
      newCount = 1;
      newRounds += 1;
    }
    state = state.copyWith(count: newCount, rounds: newRounds);
    _saveToHive();
  }

  void reset() {
    state = state.copyWith(count: 0, rounds: 0);
    _saveToHive();
  }

  void selectZikr(int index) {
    state = state.copyWith(currentZikrIndex: index, count: 0, rounds: 0);
    _saveToHive();
  }

  void addCustomZikr(String newZikr) {
    final newList = List<String>.from(state.azkarList);
    newList.add(newZikr);
    
    // Select the newly added custom zikr immediately
    state = state.copyWith(
      azkarList: newList,
      currentZikrIndex: newList.length - 1,
      count: 0,
      rounds: 0,
    );
    _saveToHive();
  }

  void deleteZikr(int index) {
    if (state.azkarList.length <= 1) return; // Do not delete if only one remains

    final newList = List<String>.from(state.azkarList);
    newList.removeAt(index);

    int newIndex = state.currentZikrIndex;
    if (state.currentZikrIndex >= newList.length) {
      newIndex = newList.length - 1;
    } else if (state.currentZikrIndex == index) {
      newIndex = 0; // If deleted current item, reset select to first item
    } else if (state.currentZikrIndex > index) {
      newIndex = state.currentZikrIndex - 1; // Shift back index
    }

    state = state.copyWith(
      azkarList: newList,
      currentZikrIndex: newIndex,
      count: 0,
      rounds: 0,
    );
    _saveToHive();
  }

  void changeZikr() {
    int nextIndex = (state.currentZikrIndex + 1) % state.azkarList.length;
    state = state.copyWith(currentZikrIndex: nextIndex, count: 0, rounds: 0);
    _saveToHive();
  }
}

final sebhaProvider = StateNotifierProvider<SebhaNotifier, SebhaState>(
  (ref) => SebhaNotifier(),
);
