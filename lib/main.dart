import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

void main() {
  runApp(ProviderScope(child: const KalRasoolAllah()));
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
        scaffoldBackgroundColor: const Color.fromARGB(255, 15, 15, 15),
        fontFamily: ArabicFont.cairo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      onGenerateRoute: Approuter.generateroute,
      initialRoute: Approuter.splashScreen,
      // home: MainNavBar(),
    );
  }
}
