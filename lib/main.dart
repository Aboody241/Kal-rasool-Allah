import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:kal_rasol_allah/core/engine/engine_provider.dart';
import 'package:kal_rasol_allah/core/engine/hive_storage.dart';
import 'package:kal_rasol_allah/core/engine/sunnah_engine.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('sebha_box');
  await Hive.openBox('favorites_box');
  await Hive.openBox('streak_box');
  
  // Initialize Sunnah Engine
  final engineBoxName = 'engine_box';
  await Hive.openBox(engineBoxName);
  
  final String sunnahData = await rootBundle.loadString('assets/content/sunnah.json');
  final List<dynamic> sunnahJsonList = jsonDecode(sunnahData);
  
  final sunnahEngine = SunnahEngine();
  final hiveStorage = HiveStorage(engineBoxName);
  await hiveStorage.init();
  await sunnahEngine.init(hiveStorage, sunnahJsonList);

  runApp(
    ProviderScope(
      overrides: [
        engineProvider.overrideWithValue(sunnahEngine),
      ],
      child: const KalRasoolAllah(),
    ),
  );
}

class KalRasoolAllah extends ConsumerWidget {
  const KalRasoolAllah({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ RTL + Arabic locale
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar')],
      locale: const Locale('ar'),

      theme: ThemeData(scaffoldBackgroundColor: AppColors.offWhite),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        fontFamily: ArabicFont.cairo,
        splashColor: Colors.black,
        dialogBackgroundColor: Colors.black,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      onGenerateRoute: Approuter.generateroute,
      initialRoute: Approuter.splashScreen,
      // home: MainNavBar(),
    );
  }
}
