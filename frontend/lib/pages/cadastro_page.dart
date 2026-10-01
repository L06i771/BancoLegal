import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController =
      TextEditingController();

  final ApiService apiService = ApiService();

  bool senhaVisivel = false;
  bool confirmarSenhaVisivel = false;
  bool carregando = false;

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  String? validarNome(String? value) {
    final nome = value?.trim() ?? '';

    if (nome.isEmpty) {
      return 'Digite seu nome.';
    }

    if (nome.length < 2) {
      return 'Digite um nome válido.';
    }

    return null;
  }

  String? validarEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Digite seu e-mail.';
    }

    final emailValido = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!emailValido) {
      return 'Digite um e-mail válido.';
    }

    return null;
  }

  String? validarSenha(String? value) {
    final senha = value ?? '';

    if (senha.isEmpty) {
      return 'Digite sua senha.';
    }

    if (senha.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }

    return null;
  }

  String? validarConfirmacaoSenha(String? value) {
    final confirmacao = value ?? '';
    final senha = senhaController.text;

    if (confirmacao.isEmpty) {
      return 'Confirme sua senha.';
    }

    if (confirmacao != senha) {
      return 'As senhas não coincidem.';
    }

    return null;
  }

  Future<void> cadastrar() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    final senha = senhaController.text;
    final confirmacao = confirmarSenhaController.text;

    if (senha != confirmacao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'As senhas não coincidem.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      await apiService.cadastrarUsuario(
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
        senha: senha,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastro realizado com sucesso!',
          ),
          backgroundColor: Color(0xFF1B7F5C),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao cadastrar: ${e.toString().replaceFirst('Exception: ', '')}',
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
        backgroundColor: const Color(0xFFF6F8F7),
        elevation: 0,
        leading: IconButton(
          onPressed: carregando
              ? null
              : () {
                  Navigator.pop(context);
                },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF12372A),
          ),
        ),
        title: const Text(
          'Criar conta',
          style: TextStyle(
            color: Color(0xFF12372A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Color(0xFF1B7F5C),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bem-vindo ao BancoLegal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF12372A),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crie sua conta para começar a organizar suas finanças.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF66736E),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'Nome',
                        style: TextStyle(
                          color: Color(0xFF26332E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nomeController,
                        textInputAction: TextInputAction.next,
                        validator: validarNome,
                        enabled: !carregando,
                        decoration: InputDecoration(
                          hintText: 'Digite seu nome',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F8F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF1B7F5C),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'E-mail',
                        style: TextStyle(
                          color: Color(0xFF26332E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: validarEmail,
                        enabled: !carregando,
                        decoration: InputDecoration(
                          hintText: 'seuemail@exemplo.com',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F8F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF1B7F5C),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Senha',
                        style: TextStyle(
                          color: Color(0xFF26332E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: senhaController,
                        obscureText: !senhaVisivel,
                        textInputAction: TextInputAction.next,
                        validator: validarSenha,
                        enabled: !carregando,
                        autofillHints: const [],
                        decoration: InputDecoration(
                          hintText: 'Digite sua senha',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            onPressed: carregando
                                ? null
                                : () {
                                    setState(() {
                                      senhaVisivel = !senhaVisivel;
                                    });
                                  },
                            icon: Icon(
                              senhaVisivel
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F8F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF1B7F5C),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Confirmar senha',
                        style: TextStyle(
                          color: Color(0xFF26332E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: confirmarSenhaController,
                        obscureText: !confirmarSenhaVisivel,
                        textInputAction: TextInputAction.done,
                        validator: validarConfirmacaoSenha,
                        enabled: !carregando,
                        autofillHints: const [],
                        onFieldSubmitted: (_) => cadastrar(),
                        decoration: InputDecoration(
                          hintText: 'Digite a senha novamente',
                          prefixIcon: const Icon(
                            Icons.lock_reset_rounded,
                          ),
                          suffixIcon: IconButton(
                            onPressed: carregando
                                ? null
                                : () {
                                    setState(() {
                                      confirmarSenhaVisivel =
                                          !confirmarSenhaVisivel;
                                    });
                                  },
                            icon: Icon(
                              confirmarSenhaVisivel
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F8F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF1B7F5C),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: carregando ? null : cadastrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B7F5C),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFF9DB9AD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: carregando
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'CRIAR CONTA',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: carregando
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: const Text(
                          'Já possui uma conta? Entrar',
                          style: TextStyle(
                            color: Color(0xFF1B7F5C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}