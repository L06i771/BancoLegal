import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final ApiService apiService = ApiService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool carregando = true;
  String? erro;

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

      if (!mounted) {
        return;
      }

      setState(() {
        receitas = resultados[0];
        despesas = resultados[1];
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

  int totalReceitas() {
    return receitas.fold<int>(
      0,
      (total, receita) =>
          total + ((receita['valor'] as num?)?.toInt() ?? 0),
    );
  }

  int totalDespesas() {
    return despesas.fold<int>(
      0,
      (total, despesa) =>
          total + ((despesa['valor'] as num?)?.toInt() ?? 0),
    );
  }

  int saldo() {
    return totalReceitas() - totalDespesas();
  }

  String formatarMoeda(int centavos) {
    final valor = centavos / 100;

    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final receitasTotal = totalReceitas();
    final despesasTotal = totalDespesas();
    final saldoTotal = saldo();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Relatórios',
          style: TextStyle(
            color: Color(0xFF12372A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarDados,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: carregando
                ? const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visão financeira 📊',
                        style: TextStyle(
                          color: Color(0xFF12372A),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Veja como está o movimento do seu dinheiro.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (erro != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            erro!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),

                      Row(
                        children: [
                          Expanded(
                            child: _ResumoCard(
                              titulo: 'Receitas',
                              valor: formatarMoeda(receitasTotal),
                              icone: Icons.arrow_downward_rounded,
                              cor: const Color(0xFF1B7F5C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ResumoCard(
                              titulo: 'Despesas',
                              valor: formatarMoeda(despesasTotal),
                              icone: Icons.arrow_upward_rounded,
                              cor: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _SaldoCard(
                        saldo: saldoTotal,
                        formatarMoeda: formatarMoeda,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Receitas x despesas',
                        style: TextStyle(
                          color: Color(0xFF12372A),
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _ComparacaoCard(
                        receitas: receitasTotal,
                        despesas: despesasTotal,
                        formatarMoeda: formatarMoeda,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Resumo das movimentações',
                        style: TextStyle(
                          color: Color(0xFF12372A),
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _MovimentacoesCard(
                        receitas: receitas.length,
                        despesas: despesas.length,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Maiores despesas',
                        style: TextStyle(
                          color: Color(0xFF12372A),
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _MaioresDespesas(
                        despesas: despesas,
                        formatarMoeda: formatarMoeda,
                      ),
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
  final Color cor;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
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
          CircleAvatar(
            radius: 18,
            backgroundColor: cor.withValues(alpha: 0.12),
            child: Icon(
              icone,
              color: cor,
              size: 20,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: TextStyle(
                color: cor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaldoCard extends StatelessWidget {
  final int saldo;
  final String Function(int) formatarMoeda;

  const _SaldoCard({
    required this.saldo,
    required this.formatarMoeda,
  });

  @override
  Widget build(BuildContext context) {
    final positivo = saldo >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12372A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundColor: Color(0x331B7F5C),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo calculado',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatarMoeda(saldo),
                  style: TextStyle(
                    color: positivo
                        ? const Color(0xFF7DE2B2)
                        : const Color(0xFFFF9A9A),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparacaoCard extends StatelessWidget {
  final int receitas;
  final int despesas;
  final String Function(int) formatarMoeda;

  const _ComparacaoCard({
    required this.receitas,
    required this.despesas,
    required this.formatarMoeda,
  });

  @override
  Widget build(BuildContext context) {
    final total = receitas + despesas;

    final percentualReceitas =
        total == 0 ? 0.0 : receitas / total;

    final percentualDespesas =
        total == 0 ? 0.0 : despesas / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legenda(
            titulo: 'Receitas',
            valor: formatarMoeda(receitas),
            percentual: percentualReceitas,
            cor: const Color(0xFF1B7F5C),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentualReceitas,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF1B7F5C),
          ),
          const SizedBox(height: 22),
          _Legenda(
            titulo: 'Despesas',
            valor: formatarMoeda(despesas),
            percentual: percentualDespesas,
            cor: Colors.red.shade600,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentualDespesas,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey.shade200,
            color: Colors.red.shade600,
          ),
        ],
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  final String titulo;
  final String valor;
  final double percentual;
  final Color cor;

  const _Legenda({
    required this.titulo,
    required this.valor,
    required this.percentual,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${(percentual * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          valor,
          style: TextStyle(
            color: cor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MovimentacoesCard extends StatelessWidget {
  final int receitas;
  final int despesas;

  const _MovimentacoesCard({
    required this.receitas,
    required this.despesas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Movimento(
              icone: Icons.south_west_rounded,
              titulo: 'Receitas',
              quantidade: receitas,
              cor: const Color(0xFF1B7F5C),
            ),
          ),
          Container(
            width: 1,
            height: 55,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _Movimento(
              icone: Icons.north_east_rounded,
              titulo: 'Despesas',
              quantidade: despesas,
              cor: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Movimento extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final int quantidade;
  final Color cor;

  const _Movimento({
    required this.icone,
    required this.titulo,
    required this.quantidade,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icone,
          color: cor,
          size: 24,
        ),
        const SizedBox(height: 7),
        Text(
          quantidade.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          titulo,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MaioresDespesas extends StatelessWidget {
  final List<dynamic> despesas;
  final String Function(int) formatarMoeda;

  const _MaioresDespesas({
    required this.despesas,
    required this.formatarMoeda,
  });

  @override
  Widget build(BuildContext context) {
    if (despesas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'Nenhuma despesa registrada.',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    final lista = List<dynamic>.from(despesas);

    lista.sort(
      (a, b) {
        final valorA = (a['valor'] as num?)?.toInt() ?? 0;
        final valorB = (b['valor'] as num?)?.toInt() ?? 0;

        return valorB.compareTo(valorA);
      },
    );

    final maiores = lista.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          ...maiores.map(
            (despesa) {
              final valor =
                  (despesa['valor'] as num?)?.toInt() ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade50,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                ),
                title: Text(
                  despesa['descricao']?.toString() ??
                      'Despesa',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  formatarMoeda(valor),
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}