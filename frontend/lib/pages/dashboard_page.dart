import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';
import 'adicionar_despesa_page.dart';
import 'adicionar_receita_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService apiService = ApiService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool carregando = true;
  String? erro;

  double totalReceitas = 0;
  double totalDespesas = 0;

  List<dynamic> receitas = [];
  List<dynamic> despesas = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      setState(() {
        carregando = true;
        erro = null;
      });

      final token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticação não encontrado.');
      }

      final resultados = await Future.wait([
        apiService.buscarReceitas(token),
        apiService.buscarDespesas(token),
      ]);

      receitas = resultados[0];
      despesas = resultados[1];

      totalReceitas = receitas.fold<double>(
        0,
        (total, receita) =>
            total + ((receita['valor'] as num).toDouble() / 100),
      );

      totalDespesas = despesas.fold<double>(
        0,
        (total, despesa) =>
            total + ((despesa['valor'] as num).toDouble() / 100),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
        erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String formatarData(String? data) {
    if (data == null || data.isEmpty) {
      return '';
    }

    try {
      final dataConvertida = DateTime.parse(data).toLocal();

      return '${dataConvertida.day.toString().padLeft(2, '0')}/'
          '${dataConvertida.month.toString().padLeft(2, '0')}/'
          '${dataConvertida.year}';
    } catch (_) {
      return data;
    }
  }

  Future<void> abrirAdicionarReceita() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdicionarReceitaPage(),
      ),
    );

    if (resultado == true) {
      await carregarDados();
    }
  }

  Future<void> abrirAdicionarDespesa() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdicionarDespesaPage(),
      ),
    );

    if (resultado == true) {
      await carregarDados();
    }
  }

  Future<void> abrirMovimentacoes() async {
    await Navigator.pushNamed(
      context,
      '/movimentacoes',
    );

    if (!mounted) {
      return;
    }

    await carregarDados();
  }

  Future<void> sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text(
            'Tem certeza que deseja sair da sua conta?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF66736E),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B7F5C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await storage.delete(key: 'auth_token');

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final saldo = totalReceitas - totalDespesas;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BancoLegal',
          style: TextStyle(
            color: Color(0xFF12372A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF12372A),
            ),
          ),
          IconButton(
            onPressed: sair,
            tooltip: 'Sair',
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF12372A),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarDados,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Olá! 👋',
                  style: TextStyle(
                    color: Color(0xFF12372A),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aqui está o resumo das suas finanças.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                if (erro != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            erro!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B7F5C),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo disponível',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        carregando
                            ? 'Carregando...'
                            : formatarMoeda(saldo),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Seu saldo é calculado com base nas suas receitas e despesas.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _ResumoCard(
                        titulo: 'Receitas',
                        valor: carregando
                            ? 'Carregando...'
                            : formatarMoeda(totalReceitas),
                        icone: Icons.arrow_upward_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumoCard(
                        titulo: 'Despesas',
                        valor: carregando
                            ? 'Carregando...'
                            : formatarMoeda(totalDespesas),
                        icone: Icons.arrow_downward_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Acesso rápido',
                  style: TextStyle(
                    color: Color(0xFF12372A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _AcaoCard(
                        icone: Icons.add_circle_outline_rounded,
                        titulo: 'Adicionar receita',
                        onTap: abrirAdicionarReceita,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AcaoCard(
                        icone: Icons.remove_circle_outline_rounded,
                        titulo: 'Adicionar despesa',
                        onTap: abrirAdicionarDespesa,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _AcaoCard(
                  icone: Icons.receipt_long_rounded,
                  titulo: 'Todas as movimentações',
                  onTap: abrirMovimentacoes,
                ),

                const SizedBox(height: 12),

                _AcaoCard(
                  icone: Icons.flag_outlined,
                  titulo: 'Metas financeiras',
                  onTap: () async {
                    await Navigator.pushNamed(context, '/metas');
                  },
                ),

                const SizedBox(height: 12),

                _AcaoCard(
                  icone: Icons.bar_chart_rounded,
                  titulo: 'Relatórios',
                  onTap: () async {
                    await Navigator.pushNamed(context, '/relatorios');
                  },
                ),

                const SizedBox(height: 28),

                const Text(
                  'Últimas movimentações',
                  style: TextStyle(
                    color: Color(0xFF12372A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                _Movimentacoes(
                  receitas: receitas,
                  despesas: despesas,
                  carregando: carregando,
                  formatarData: formatarData,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            color: const Color(0xFF1B7F5C),
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: Color(0xFF12372A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcaoCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const _AcaoCard({
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              icone,
              color: const Color(0xFF1B7F5C),
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF12372A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Movimentacoes extends StatelessWidget {
  final List<dynamic> receitas;
  final List<dynamic> despesas;
  final bool carregando;
  final String Function(String?) formatarData;

  const _Movimentacoes({
    required this.receitas,
    required this.despesas,
    required this.carregando,
    required this.formatarData,
  });

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final movimentacoes = [
      ...receitas.map(
        (item) => {
          'tipo': 'receita',
          'descricao': item['descricao'],
          'valor': item['valor'],
          'data': item['data'],
        },
      ),
      ...despesas.map(
        (item) => {
          'tipo': 'despesa',
          'descricao': item['descricao'],
          'valor': item['valor'],
          'data': item['data'],
        },
      ),
    ];

    movimentacoes.sort((a, b) {
      final dataA = DateTime.tryParse(
        a['data']?.toString() ?? '',
      );
      final dataB = DateTime.tryParse(
        b['data']?.toString() ?? '',
      );

      if (dataA == null && dataB == null) {
        return 0;
      }

      if (dataA == null) {
        return 1;
      }

      if (dataB == null) {
        return -1;
      }

      return dataB.compareTo(dataA);
    });

    if (movimentacoes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma movimentação ainda.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Suas receitas e despesas aparecerão aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: movimentacoes.take(5).map((movimentacao) {
          final receita = movimentacao['tipo'] == 'receita';

          final valor =
              (movimentacao['valor'] as num).toDouble() / 100;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: receita
                  ? const Color(0xFFE8F4EF)
                  : Colors.red.shade50,
              child: Icon(
                receita
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: receita
                    ? const Color(0xFF1B7F5C)
                    : Colors.red.shade700,
              ),
            ),
            title: Text(
              movimentacao['descricao']?.toString() ?? 'Sem descrição',
              style: const TextStyle(
                color: Color(0xFF12372A),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              formatarData(
                movimentacao['data']?.toString(),
              ),
            ),
            trailing: Text(
              '${receita ? '+' : '-'} R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
              style: TextStyle(
                color: receita
                    ? const Color(0xFF1B7F5C)
                    : Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}