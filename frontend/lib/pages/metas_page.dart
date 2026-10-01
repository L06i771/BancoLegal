import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({super.key});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  final ApiService apiService = ApiService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool carregando = true;
  String? erro;
  List<dynamic> metas = [];

  @override
  void initState() {
    super.initState();
    carregarMetas();
  }

  Future<void> carregarMetas() async {
    try {
      setState(() {
        carregando = true;
        erro = null;
      });

      final token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticação não encontrado.');
      }

      final resultado = await apiService.buscarMetas(token);

      if (!mounted) {
        return;
      }

      setState(() {
        metas = resultado;
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

  Future<void> excluirMeta(dynamic meta) async {
    final nomeMeta = meta['nome']?.toString() ?? 'esta meta';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir meta?'),
          content: Text(
            'A meta "$nomeMeta" será excluída permanentemente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticação não encontrado.');
      }

      await apiService.excluirMeta(
        id: meta['id'],
        token: token,
      );

      await carregarMetas();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meta excluída com sucesso!'),
          backgroundColor: Color(0xFF1B7F5C),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao excluir meta: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> abrirFormularioMeta({dynamic meta}) async {
    final editando = meta != null;

    final formKey = GlobalKey<FormState>();

    final nomeController = TextEditingController(
      text: editando ? meta['nome']?.toString() ?? '' : '',
    );

    final valorInicial = editando
        ? ((meta['valor_desejado'] as num?)?.toInt() ?? 0) / 100
        : null;

    final valorController = TextEditingController(
      text: valorInicial != null
          ? valorInicial.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );

    DateTime? prazoSelecionado;

    if (editando && meta['prazo'] != null) {
      prazoSelecionado = DateTime.tryParse(
        meta['prazo'].toString(),
      );
    }

    bool salvando = false;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> escolherPrazo() async {
              final agora = DateTime.now();

              final data = await showDatePicker(
                context: context,
                initialDate: prazoSelecionado ?? agora,
                firstDate: agora,
                lastDate: DateTime(2100),
                helpText: 'Escolha o prazo da meta',
                cancelText: 'CANCELAR',
                confirmText: 'OK',
              );

              if (data != null) {
                setDialogState(() {
                  prazoSelecionado = data;
                });
              }
            }

            Future<void> salvarMeta() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              setDialogState(() {
                salvando = true;
              });

              try {
                final token = await storage.read(key: 'auth_token');

                if (token == null || token.isEmpty) {
                  throw Exception(
                    'Token de autenticação não encontrado.',
                  );
                }

                final valorTexto = valorController.text
                    .replaceAll('.', '')
                    .replaceAll(',', '.');

                final valorReais = double.parse(valorTexto);
                final valorCentavos = (valorReais * 100).round();

                String? prazo;

                if (prazoSelecionado != null) {
                  prazo =
                      '${prazoSelecionado!.year}-'
                      '${prazoSelecionado!.month.toString().padLeft(2, '0')}-'
                      '${prazoSelecionado!.day.toString().padLeft(2, '0')}';
                }

                if (editando) {
                  await apiService.editarMeta(
                    id: meta['id'],
                    token: token,
                    nome: nomeController.text.trim(),
                    valorDesejado: valorCentavos,
                    prazo: prazo,
                  );
                } else {
                  await apiService.criarMeta(
                    token: token,
                    nome: nomeController.text.trim(),
                    valorDesejado: valorCentavos,
                    prazo: prazo,
                  );
                }

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                if (!context.mounted) {
                  return;
                }

                setDialogState(() {
                  salvando = false;
                });

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Erro: '
                      '${e.toString().replaceFirst('Exception: ', '')}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              title: Text(
                editando ? 'Editar meta 🎯' : 'Nova meta 🎯',
                style: const TextStyle(
                  color: Color(0xFF12372A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nomeController,
                        enabled: !salvando,
                        textCapitalization:
                            TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Nome da meta',
                          hintText: 'Ex.: Celular novo',
                          filled: true,
                          fillColor: const Color(0xFFF6F8F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite um nome.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: valorController,
                        enabled: !salvando,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Valor desejado',
                          hintText: 'Ex.: 1500,00',
                          prefixText: 'R\$ ',
                          filled: true,
                          fillColor: const Color(0xFFF6F8F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite um valor.';
                          }

                          final texto = value
                              .replaceAll('.', '')
                              .replaceAll(',', '.');

                          final valor = double.tryParse(texto);

                          if (valor == null || valor <= 0) {
                            return 'Digite um valor válido.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              salvando ? null : escolherPrazo,
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                          ),
                          label: Text(
                            prazoSelecionado == null
                                ? 'Adicionar prazo (opcional)'
                                : 'Prazo: '
                                  '${prazoSelecionado!.day.toString().padLeft(2, '0')}/'
                                  '${prazoSelecionado!.month.toString().padLeft(2, '0')}/'
                                  '${prazoSelecionado!.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: salvando
                      ? null
                      : () =>
                          Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: salvando ? null : salvarMeta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B7F5C),
                    foregroundColor: Colors.white,
                  ),
                  child: salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(editando ? 'SALVAR ALTERAÇÕES' : 'SALVAR'),
                ),
              ],
            );
          },
        );
      },
    );

    nomeController.dispose();
    valorController.dispose();

    if (resultado == true && mounted) {
      await carregarMetas();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Meta atualizada com sucesso! 🎯'
                : 'Meta criada com sucesso! 🎯',
          ),
          backgroundColor: const Color(0xFF1B7F5C),
        ),
      );
    }
  }

  Future<void> abrirCriarMeta() async {
    await abrirFormularioMeta();
  }

  Future<void> abrirEditarMeta(dynamic meta) async {
    await abrirFormularioMeta(meta: meta);
  }

  String formatarMoeda(int centavos) {
    final valor = centavos / 100;

    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String formatarPrazo(String? prazo) {
    if (prazo == null || prazo.isEmpty) {
      return 'Sem prazo definido';
    }

    try {
      final data = DateTime.parse(prazo);

      return 'Prazo: ${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year}';
    } catch (_) {
      return 'Prazo: $prazo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Metas financeiras',
          style: TextStyle(
            color: Color(0xFF12372A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: carregando ? null : abrirCriarMeta,
        backgroundColor: const Color(0xFF1B7F5C),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarMetas,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Minhas metas 🎯',
                  style: TextStyle(
                    color: Color(0xFF12372A),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Acompanhe seus objetivos financeiros.',
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
                if (carregando)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (metas.isEmpty)
                  _estadoVazio()
                else
                  ...metas.map(
                    (meta) => _MetaCard(
                      meta: meta,
                      formatarMoeda: formatarMoeda,
                      formatarPrazo: formatarPrazo,
                      onEditar: () => abrirEditarMeta(meta),
                      onExcluir: () => excluirMeta(meta),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 14),
          Text(
            'Nenhuma meta criada ainda.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crie uma meta para começar a acompanhar seu objetivo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final dynamic meta;
  final String Function(int) formatarMoeda;
  final String Function(String?) formatarPrazo;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _MetaCard({
    required this.meta,
    required this.formatarMoeda,
    required this.formatarPrazo,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final int valorDesejado =
        (meta['valor_desejado'] as num?)?.toInt() ?? 0;

    final int progresso =
        (meta['progresso'] as num?)?.toInt() ?? 0;

    final double percentual = valorDesejado > 0
        ? (progresso / valorDesejado).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  meta['nome']?.toString() ?? 'Meta sem nome',
                  style: const TextStyle(
                    color: Color(0xFF12372A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (opcao) {
                  if (opcao == 'editar') {
                    onEditar();
                  }

                  if (opcao == 'excluir') {
                    onExcluir();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF1B7F5C),
                        ),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'excluir',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Excluir'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatarPrazo(meta['prazo']?.toString()),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: percentual,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF1B7F5C),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatarMoeda(progresso),
                style: const TextStyle(
                  color: Color(0xFF1B7F5C),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'de ${formatarMoeda(valorDesejado)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}