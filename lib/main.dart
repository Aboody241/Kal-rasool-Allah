import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';

void main() {
  runApp(const KalRasoolAllah()); // ✅ const
}

class KalRasoolAllah extends StatelessWidget {
  const KalRasoolAllah({super.key});

  @override
  Widget build(BuildContext context) {
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

      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 15, 15, 15),
        fontFamily: ArabicFont.cairo,
      ),
      onGenerateRoute: Approuter.generateroute,
      initialRoute: Approuter.splashScreen,
    );
  }
}
