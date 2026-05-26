import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/content/dua.json');
  if (!file.existsSync()) {
    print('Error: dua.json file not found at path: ${file.path}');
    return;
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> jsonList = jsonDecode(jsonString);

  String getSource(String text) {
    if (text.contains('رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً')) {
      return 'سورة البقرة: 201';
    }
    if (text.contains('رَبِّ اشْرَحْ لِي صَدْرِي')) {
      return 'سورة طه: 25-26';
    }
    if (text.contains('رَبِّ زِدْنِي عِلْمًا')) {
      return 'سورة طه: 114';
    }
    if (text.contains('لَا تُزِغْ قُلُوبَنَا')) {
      return 'سورة آل عمران: 8';
    }
    if (text.contains('هَبْ لَنَا مِنْ أَزْوَاجِنَا')) {
      return 'سورة الفرقان: 74';
    }
    if (text.contains('الهم والحزن')) {
      return 'صحيح البخاري';
    }
    if (text.contains('العفو والعافية')) {
      return 'سنن ابن ماجه';
    }
    if (text.contains('يا مقلب القلوب')) {
      return 'سنن الترمذي';
    }
    if (text.contains('زوال نعمتك')) {
      return 'صحيح مسلم';
    }
    if (text.contains('حسن الخاتمة')) {
      return 'مأثور';
    }
    if (text.contains('اغفر لي ولوالدي')) {
      return 'سورة نوح: 28';
    }
    if (text.contains('رزقًا طيبًا')) {
      return 'سنن ابن ماجه';
    }
    if (text.contains('أسألك الجنة')) {
      return 'سنن الترمذي';
    }
    if (text.contains('أصلح لي ديني')) {
      return 'صحيح مسلم';
    }
    if (text.contains('بارك لي في وقتي')) {
      return 'مأثور';
    }
    if (text.contains('أستغفر الله العظيم وأتوب إليه')) {
      return 'مأثور';
    }
    if (text.contains('اغفر لي ذنبي كله')) {
      return 'صحيح مسلم';
    }
    if (text.contains('الذي لا إله إلا هو')) {
      return 'سنن أبي داود';
    }
    if (text.contains('تب علي إنك أنت التواب')) {
      return 'سورة البقرة: 128';
    }
    if (text.contains('عدد خلقك')) {
      return 'صحيح مسلم';
    }
    if (text.contains('أصبحنا وأصبح الملك لله')) {
      return 'صحيح مسلم';
    }
    if (text.contains('بك أصبحنا وبك أمسينا')) {
      return 'سنن الترمذي';
    }
    if (text.contains('رضيت بالله ربًا')) {
      return 'سنن أبي داود';
    }
    if (text.contains('حسبي الله لا إله إلا هو')) {
      return 'سورة التوبة: 129';
    }
    if (text.contains('أسألك خير هذا اليوم')) {
      return 'سنن أبي داود';
    }
    if (text.contains('أمسينا وأمسى الملك لله')) {
      return 'صحيح مسلم';
    }
    if (text.contains('بك أمسينا وبك أصبحنا')) {
      return 'سنن الترمذي';
    }
    if (text.contains('أعوذ بكلمات الله التامات')) {
      return 'صحيح مسلم';
    }
    if (text.contains('احفظني من بين يدي')) {
      return 'سنن أبي داود';
    }
    if (text.contains('رزقًا حلالًا طيبًا')) {
      return 'مأثور';
    }
    if (text.contains('اكفني بحلالك')) {
      return 'سنن الترمذي';
    }
    if (text.contains('من حيث لا أحتسب')) {
      return 'سورة الطلاق: 3';
    }
    if (text.contains('بارك لي في رزقي')) {
      return 'مأثور';
    }
    if (text.contains('وسع علي رزقي')) {
      return 'مسند أحمد';
    }
    return 'مأثور';
  }

  int updatedCount = 0;
  for (final item in jsonList) {
    if (item is Map) {
      final text = item['text'] as String? ?? '';
      final oldSource = item['source'] as String? ?? '';
      final newSource = getSource(text);
      if (newSource != oldSource) {
        item['source'] = newSource;
        updatedCount++;
      }
    }
  }

  // Write back formatted with nice indentation
  final encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(jsonList));

  print('Success! Updated $updatedCount items in dua.json.');
}
