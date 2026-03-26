import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, Approuter.onboardScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Gap(200),
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(30),
              child: Image.asset(
                'assets/consts/logo.png',
                width: 170,
                height: 170,
              ),
            ),
            Gap(300),
            CircularProgressIndicator(
              backgroundColor: AppColors.darkGreen,
              color: AppColors.lightGreen,
              strokeWidth: 5,
            ),
          ],
        ),
      ),
    );
  }
}
