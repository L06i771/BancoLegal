import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';
import 'adicionar_despesa_page.dart';
import 'adicionar_receita_page.dart';

class MovimentacoesPage extends StatefulWidget {
  const MovimentacoesPage({super.key});

  @override
  State<MovimentacoesPage> createState() => _MovimentacoesPageState();
}

class _MovimentacoesPageState extends State<MovimentacoesPage> {
  final ApiService apiService = ApiService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool carregando = true;

  List<dynamic> receitas = [];
  List<dynamic> despesas = [];

  @override
  void initState() {
    super.initState();
    carregarMovimentacoes();
  }

  Future<void> carregarMovimentacoes() async {
    setState(() {
      carregando = true;
    });

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Usuário não autenticado.');
      }

      final resultados = await Future.wait([
        apiService.buscarReceitas(token),
        apiService.buscarDespesas(token),
      ]);

      if (!mounted) return;

      setState(() {
        receitas = resultados[0];
        despesas = resultados[1];
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar movimentações: $e'),
        ),
      );
    }
  }

  double converterValor(dynamic valor) {
    if (valor is int) {
      return valor / 100;
    }

    if (valor is double) {
      return valor / 100;
    }

    return double.tryParse(valor.toString())! / 100;
  }

  String formatarMoeda(dynamic valor) {
    final numero = converterValor(valor);

    return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String formatarData(dynamic data) {
    if (data == null) {
      return '--/--/----';
    }

    final texto = data.toString();

    if (texto.length >= 10) {
      final partes = texto.substring(0, 10).split('-');

      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
    }

    return texto;
  }

  Future<void> editarReceita(dynamic receita) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarReceitaPage(
          receita: receita,
        ),
      ),
    );

    if (resultado == true) {
      await carregarMovimentacoes();
    }
  }

  Future<void> editarDespesa(dynamic despesa) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdicionarDespesaPage(
          despesa: despesa,
        ),
      ),
    );

    if (resultado == true) {
      await carregarMovimentacoes();
    }
  }

  Future<void> excluirReceita(dynamic receita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir receita?'),
          content: const Text(
            'Essa movimentação será excluída permanentemente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Usuário não autenticado.');
      }

      await apiService.excluirReceita(
        id: receita['id'],
        token: token,
      );

      await carregarMovimentacoes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita excluída com sucesso.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir receita: $e'),
        ),
      );
    }
  }

  Future<void> excluirDespesa(dynamic despesa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir despesa?'),
          content: const Text(
            'Essa movimentação será excluída permanentemente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Usuário não autenticado.');
      }

      await apiService.excluirDespesa(
        id: despesa['id'],
        token: token,
      );

      await carregarMovimentacoes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Despesa excluída com sucesso.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir despesa: $e'),
        ),
      );
    }
  }

  Widget construirReceita(dynamic receita) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.12),
          child: const Icon(
            Icons.arrow_downward_rounded,
            color: Colors.green,
          ),
        ),
        title: Text(
          receita['descricao']?.toString() ?? 'Receita',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          formatarData(receita['data']),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+ ${formatarMoeda(receita['valor'])}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (opcao) {
                if (opcao == 'editar') {
                  editarReceita(receita);
                }

                if (opcao == 'excluir') {
                  excluirReceita(receita);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'excluir',
                  child: Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget construirDespesa(dynamic despesa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.withValues(alpha: 0.12),
          child: const Icon(
            Icons.arrow_upward_rounded,
            color: Colors.red,
          ),
        ),
        title: Text(
          despesa['descricao']?.toString() ?? 'Despesa',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          formatarData(despesa['data']),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '- ${formatarMoeda(despesa['valor'])}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (opcao) {
                if (opcao == 'editar') {
                  editarDespesa(despesa);
                }

                if (opcao == 'excluir') {
                  excluirDespesa(despesa);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'excluir',
                  child: Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> juntarMovimentacoes() {
    final lista = <Map<String, dynamic>>[];

    for (final receita in receitas) {
      lista.add({
        'tipo': 'receita',
        'dados': receita,
      });
    }

    for (final despesa in despesas) {
      lista.add({
        'tipo': 'despesa',
        'dados': despesa,
      });
    }

    lista.sort((a, b) {
      final dataA = DateTime.tryParse(
            a['dados']['data']?.toString() ?? '',
          ) ??
          DateTime(1900);

      final dataB = DateTime.tryParse(
            b['dados']['data']?.toString() ?? '',
          ) ??
          DateTime(1900);

      return dataB.compareTo(dataA);
    });

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final movimentacoes = juntarMovimentacoes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentações'),
        actions: [
          IconButton(
            onPressed: carregarMovimentacoes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregarMovimentacoes,
        child: carregando
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : movimentacoes.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 150),
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Nenhuma movimentação encontrada.',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: movimentacoes.length,
                    itemBuilder: (context, index) {
                      final movimentacao = movimentacoes[index];

                      if (movimentacao['tipo'] == 'receita') {
                        return construirReceita(
                          movimentacao['dados'],
                        );
                      }

                      return construirDespesa(
                        movimentacao['dados'],
                      );
                    },
                  ),
      ),
    );
  }
}