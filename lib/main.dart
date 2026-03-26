import 'package:flutter/material.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';

void main() {
  runApp(KalRasoolAllah());
}

class KalRasoolAllah extends StatelessWidget {
  const KalRasoolAllah({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 15, 15, 15),
      ),
      onGenerateRoute: Approuter.generateroute,
    );
  }
}
