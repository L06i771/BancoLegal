import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'pages/metas_page.dart';
import 'pages/movimentacoes_page.dart';
import 'pages/relatorios_page.dart';

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
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/metas': (context) => const MetasPage(),
        '/movimentacoes': (context) => const MovimentacoesPage(),
        '/relatorios': (context) => const RelatoriosPage(),
      },
    );
  }
}