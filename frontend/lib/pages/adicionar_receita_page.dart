import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_service.dart';

class AdicionarReceitaPage extends StatefulWidget {
  final dynamic receita;

  const AdicionarReceitaPage({
    super.key,
    this.receita,
  });

  @override
  State<AdicionarReceitaPage> createState() => _AdicionarReceitaPageState();
}

class _AdicionarReceitaPageState extends State<AdicionarReceitaPage> {
  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final valorController = TextEditingController();

  final apiService = ApiService();
  final storage = const FlutterSecureStorage();

  bool carregando = false;

  bool get editando => widget.receita != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      descricaoController.text =
          widget.receita['descricao']?.toString() ?? '';

      final valor = (widget.receita['valor'] as num?)?.toDouble() ?? 0;
      valorController.text =
          (valor / 100).toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token não encontrado.');
      }

      final valorTexto = valorController.text
          .replaceAll('.', '')
          .replaceAll(',', '.');

      final valorReais = double.parse(valorTexto);
      final valorCentavos = (valorReais * 100).round();

      final hoje = DateTime.now();

      final data = editando
          ? widget.receita['data']?.toString().substring(0, 10)
          : '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-'
              '${hoje.day.toString().padLeft(2, '0')}';

      if (editando) {
        await apiService.editarReceita(
          id: widget.receita['id'],
          token: token,
          descricao: descricaoController.text.trim(),
          valor: valorCentavos,
          data: data!,
        );
      } else {
        await apiService.criarReceita(
          token: token,
          descricao: descricaoController.text.trim(),
          valor: valorCentavos,
          data: data!,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          editando ? 'Editar receita' : 'Adicionar receita',
          style: const TextStyle(
            color: Color(0xFF12372A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  editando ? 'Editar receita' : 'Nova receita',
                  style: const TextStyle(
                    color: Color(0xFF12372A),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  editando
                      ? 'Atualize os dados da receita.'
                      : 'Registre uma entrada de dinheiro.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: descricaoController,
                  enabled: !carregando,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Ex.: Salário',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite uma descrição.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: valorController,
                  enabled: !carregando,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    hintText: 'Ex.: 1500,00',
                    prefixText: 'R\$ ',
                    filled: true,
                    fillColor: Colors.white,
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
                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: carregando ? null : salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B7F5C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: carregando
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            editando
                                ? 'SALVAR ALTERAÇÕES'
                                : 'SALVAR RECEITA',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}