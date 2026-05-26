import 'package:kal_rasol_allah/features/dua/data/dua_model.dart';

/// All available dua categories.
/// Used for filtering and UI tabs.
class DuaCategories {
  static const String all = 'الكل';
  static const String morning = 'أذكار الصباح';
  static const String evening = 'أذكار المساء';
  static const String quran = 'أدعية قرآنية';
  static const String prophet = 'أدعية نبوية';
  static const String general = 'أدعية عامة';
  static const String forgiveness = 'استغفار';
  static const String rizq = 'رزق';

  /// Returns all categories (excluding "الكل") for iteration.
  static const List<String> values = [
    all,
    morning,
    evening,
    quran,
    prophet,
    general,
    forgiveness,
    rizq,
  ];
}

/// Static repository of all duas.
/// Separated from UI so it can easily be replaced with
/// an API call or local database later.
class DuaList {
  static const List<DuaModel> allDuas = [
    // ========== أدعية قرآنية ==========
    DuaModel(
      id: 1,
      text: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      category: DuaCategories.quran,
      source: 'سورة البقرة: 201',
    ),
    DuaModel(
      id: 2,
      text: 'رَبِّ اشْرَحْ لِي صَدْرِي ● وَيَسِّرْ لِي أَمْرِي',
      category: DuaCategories.quran,
      source: 'سورة طه: 25-26',
    ),
    DuaModel(
      id: 3,
      text: 'رَبِّ زِدْنِي عِلْمًا',
      category: DuaCategories.quran,
      source: 'سورة طه: 114',
    ),
    DuaModel(
      id: 4,
      text: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      category: DuaCategories.quran,
      source: 'سورة الفرقان: 74',
    ),
    DuaModel(
      id: 5,
      text: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً إِنَّكَ أَنتَ الْوَهَّابُ',
      category: DuaCategories.quran,
      source: 'سورة آل عمران: 8',
    ),

    // ========== أدعية نبوية ==========
    DuaModel(
      id: 6,
      text: 'اللهم إني أعوذ بك من الهم والحزن والعجز والكسل والبخل والجبن وضلع الدين وغلبة الرجال',
      category: DuaCategories.prophet,
      source: 'صحيح البخاري',
    ),
    DuaModel(
      id: 7,
      text: 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة',
      category: DuaCategories.prophet,
      source: 'سنن ابن ماجه',
    ),
    DuaModel(
      id: 8,
      text: 'اللهم إني أعوذ بك من زوال نعمتك وتحول عافيتك وفجاءة نقمتك وجميع سخطك',
      category: DuaCategories.prophet,
      source: 'صحيح مسلم',
    ),
    DuaModel(
      id: 9,
      text: 'يا مقلب القلوب ثبّت قلبي على دينك',
      category: DuaCategories.prophet,
      source: 'سنن الترمذي',
    ),

    // ========== استغفار ==========
    DuaModel(
      id: 10,
      text: 'أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه',
      category: DuaCategories.forgiveness,
      source: 'سنن أبي داود',
    ),
    DuaModel(
      id: 11,
      text: 'اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي، وأبوء بذنبي فاغفر لي فإنه لا يغفر الذنوب إلا أنت',
      category: DuaCategories.forgiveness,
      source: 'صحيح البخاري — سيد الاستغفار',
    ),

    // ========== أدعية عامة ==========
    DuaModel(
      id: 12,
      text: 'اللهم اغفر لي ولوالدي وارحمهما كما ربياني صغيرًا',
      category: DuaCategories.general,
    ),
    DuaModel(
      id: 13,
      text: 'اللهم ارزقني رزقًا طيبًا مباركًا',
      category: DuaCategories.rizq,
    ),
    DuaModel(
      id: 14,
      text: 'اللهم إني أسألك الجنة وأعوذ بك من النار',
      category: DuaCategories.general,
    ),
    DuaModel(
      id: 15,
      text: 'اللهم ارزقني علمًا نافعًا ورزقًا واسعًا وعملًا متقبلًا',
      category: DuaCategories.rizq,
      source: 'سنن ابن ماجه',
    ),

    // ========== أذكار الصباح ==========
    DuaModel(
      id: 16,
      text: 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
      category: DuaCategories.morning,
      source: 'صحيح مسلم',
    ),
    DuaModel(
      id: 17,
      text: 'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور',
      category: DuaCategories.morning,
      source: 'سنن الترمذي',
    ),

    // ========== أذكار المساء ==========
    DuaModel(
      id: 18,
      text: 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
      category: DuaCategories.evening,
      source: 'صحيح مسلم',
    ),
    DuaModel(
      id: 19,
      text: 'اللهم بك أمسينا وبك أصبحنا وبك نحيا وبك نموت وإليك المصير',
      category: DuaCategories.evening,
      source: 'سنن الترمذي',
    ),
    DuaModel(
      id: 20,
      text: 'اللهم ما أمسى بي من نعمة أو بأحد من خلقك فمنك وحدك لا شريك لك فلك الحمد ولك الشكر',
      category: DuaCategories.evening,
      source: 'سنن أبي داود',
    ),
  ];
}
