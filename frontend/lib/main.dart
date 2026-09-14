import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const BancoLegalApp());
}

class BancoLegalApp extends StatelessWidget {
  const BancoLegalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BancoLegal',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B7F5C),
          brightness: Brightness.light,
        ),
      ),
      home: const LoginPage(),
    );
  }
}