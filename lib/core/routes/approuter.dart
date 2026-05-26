// Updated Approuter with new route constants and cases
import 'package:flutter/material.dart';
import 'package:kal_rasol_allah/core/routes/notfound_screen.dart';
import 'package:kal_rasol_allah/features/history/history_page.dart';
import 'package:kal_rasol_allah/features/home/pages/home_page.dart';
import 'package:kal_rasol_allah/features/onboard/on_board_page.dart';
import 'package:kal_rasol_allah/features/setting/setting_page.dart';
import 'package:kal_rasol_allah/features/splash/splash_screen.dart';
import 'package:kal_rasol_allah/features/tools/screens/favorite_screen.dart';
import 'package:kal_rasol_allah/features/sebha/presentation/pages/sebha_screen.dart';
import 'package:kal_rasol_allah/features/dua/presentation/pages/duaa_screen.dart';
import 'package:kal_rasol_allah/features/tools/screens/names_of_allah_screen.dart';
import 'package:kal_rasol_allah/features/tools/screens/qibla_screen.dart';
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
  static const String favoriteScreen = '/favoriteScreen';
  // New routes
  static const String sebhaScreen = '/sebhaScreen';
  static const String duaaScreen = '/duaaScreen';
  static const String namesOfAllahScreen = '/namesOfAllahScreen';
  static const String qiblaScreen = '/qiblaScreen';

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
      case favoriteScreen:
        return MaterialPageRoute(builder: (_) => const FavoriteScreen());
      // New cases
      case sebhaScreen:
        return MaterialPageRoute(builder: (_) => const SebhaScreen());
      case duaaScreen:
        return MaterialPageRoute(builder: (_) => const DuaaScreen());
      case namesOfAllahScreen:
        return MaterialPageRoute(builder: (_) => const NamesOfAllahScreen());
      case qiblaScreen:
        return MaterialPageRoute(builder: (_) => const QiblaScreen());
      default:
        return MaterialPageRoute(builder: (_) => const NotfoundScreen());
    }
  }
}

