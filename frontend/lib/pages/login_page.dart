import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool senhaVisivel = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void entrar() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Login preparado! A API será conectada depois.',
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B7F5C),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'BancoLegal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF12372A),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Organize seu dinheiro. Simplifique sua vida.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF66736E),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
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
                          const Text(
                            'Entrar',
                            style: TextStyle(
                              color: Color(0xFF12372A),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Acesse sua conta para continuar.',
                            style: TextStyle(
                              color: Color(0xFF66736E),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 28),

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
                            textInputAction: TextInputAction.done,
                            validator: validarSenha,
                            onFieldSubmitted: (_) => entrar(),
                            decoration: InputDecoration(
                              hintText: 'Digite sua senha',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
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

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Recuperação de senha será adicionada depois.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(
                                  color: Color(0xFF1B7F5C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: entrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B7F5C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'ENTRAR',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE1E6E3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'ou',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE1E6E3),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Não possui uma conta?',
                                style: TextStyle(
                                  color: Color(0xFF66736E),
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tela de cadastro será criada depois.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Cadastre-se',
                                  style: TextStyle(
                                    color: Color(0xFF1B7F5C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'BancoLegal • Organização de Gastos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9AA59F),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}