import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kal_rasol_allah/core/routes/notfound_screen.dart';
import 'package:kal_rasol_allah/features/onboard/onboard_screen.dart';
import 'package:kal_rasol_allah/features/splash/splash_screen.dart';

class Approuter {
  static const String splashScreen = '/';
  static const String notfoundscreen = '/notfound';
  static const String onboardScreen = '/onboardScreen';

  static Route<dynamic> generateroute(RouteSettings setting) {
    switch (setting.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case onboardScreen:
        return MaterialPageRoute(builder: (_) => OnboardScreen());

      default:
        return MaterialPageRoute(builder: (_) => NotfoundScreen());
    }
  }
}
