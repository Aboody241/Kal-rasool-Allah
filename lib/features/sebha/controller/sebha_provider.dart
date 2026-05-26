import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SebhaState {
  final int count;
  final int currentZikrIndex;

  SebhaState({required this.count, required this.currentZikrIndex});

  SebhaState copyWith({int? count, int? currentZikrIndex}) {
    return SebhaState(
      count: count ?? this.count,
      currentZikrIndex: currentZikrIndex ?? this.currentZikrIndex,
    );
  }
}

class SebhaNotifier extends StateNotifier<SebhaState> {
  SebhaNotifier() : super(SebhaState(count: 0, currentZikrIndex: 0));

  final List<String> azkar = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'استغفر الله',
    'سبحان الله وبحمده',
    'سبحان الله العظيم',
    'لا حول ولا قوة إلا بالله',
    'اللهم صلِّ على محمد',
    'أستغفر الله وأتوب إليه',
    'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
    'سبحان الله والحمد لله ولا إله إلا الله والله أكبر',
    'حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم',
    'اللهم اغفر لي ولوالدي',
    'اللهم ارزقني رزقًا طيبًا مباركًا',
    'اللهم إني أسألك العفو والعافية',
    'رب اغفر لي وتب علي إنك أنت التواب الرحيم',
    'اللهم آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار',
    'اللهم إني أسألك الجنة وأعوذ بك من النار',
    'اللهم اشرح لي صدري ويسر لي أمري',
    'اللهم ارزقني علمًا نافعًا ورزقًا واسعًا وعملًا متقبلًا',
  ];

  void increment() {
    state = state.copyWith(count: state.count + 1);
  }

  void reset() {
    state = state.copyWith(count: 0);
  }

  void changeZikr() {
    int nextIndex = (state.currentZikrIndex + 1) % azkar.length;
    state = state.copyWith(currentZikrIndex: nextIndex, count: 0);
  }
}

final sebhaProvider = StateNotifierProvider<SebhaNotifier, SebhaState>(
  (ref) => SebhaNotifier(),
);
