import 'package:flutter/material.dart';
import 'package:kal_rasol_allah/core/routes/notfound_screen.dart';
import 'package:kal_rasol_allah/features/history/history_page.dart';
import 'package:kal_rasol_allah/features/home/pages/home_page.dart';
import 'package:kal_rasol_allah/features/onboard/on_board_page.dart';
import 'package:kal_rasol_allah/features/setting/setting_page.dart';
import 'package:kal_rasol_allah/features/splash/splash_screen.dart';
import 'package:kal_rasol_allah/features/tools/tools_screen.dart';
import 'package:kal_rasol_allah/main_nav_bar.dart';

class Approuter {
  static const String splashScreen = '/';
  static const String notfoundscreen = '/notfound';
  static const String onboardScreen = '/onboardScreen';
  static const String homepage = '/homePage';
  static const String mainNavbar = '/mainNavbar';
  static const String historyPage = '/historyPage';
  static const String settingScreen = '/settingScreen';
  static const String toolsScreen = '/toolsScreen';

  static Route<dynamic> generateroute(RouteSettings setting) {
    switch (setting.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboardScreen:
        return MaterialPageRoute(builder: (_) => const OnboardScreen());
      case homepage:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case mainNavbar:
        return MaterialPageRoute(builder: (_) => const MainNavBar());
      case historyPage:
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case settingScreen:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case toolsScreen:
        return MaterialPageRoute(builder: (_) => const ToolsScreen());

      default:
        return MaterialPageRoute(builder: (_) => const NotfoundScreen());
    }
  }
}
