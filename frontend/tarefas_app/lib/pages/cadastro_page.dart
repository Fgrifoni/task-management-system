import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../pages/login_page.dart';
import '../theme/app_theme.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;
  bool senhaVisivel = false;
  bool confirmarSenhaVisivel = false;
  String? erro;
  String? sucesso;

  Future<void> cadastrar() async {
    // Validações locais
    if (nomeController.text.trim().isEmpty) {
      setState(() => erro = 'O nome é obrigatório.');
      return;
    }
    if (emailController.text.trim().isEmpty) {
      setState(() => erro = 'O e-mail é obrigatório.');
      return;
    }
    if (senhaController.text.length < 6) {
      setState(() => erro = 'A senha deve ter pelo menos 6 caracteres.');
      return;
    }
    if (senhaController.text != confirmarSenhaController.text) {
      setState(() => erro = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      carregando = true;
      erro = null;
      sucesso = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nomeController.text.trim(),
          'email': emailController.text.trim(),
          'senha': senhaController.text,
        }),
      );

      setState(() => carregando = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          sucesso = 'Conta criada com sucesso! Faça login para continuar.';
        });

        // Aguarda 2 segundos e redireciona para login
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        _irParaLogin();
      } else {
        final body = jsonDecode(response.body);
        final mensagem = body['message'] ?? body['erro'] ?? body.toString();
        setState(() => erro = mensagem);
      }
    } catch (e) {
      setState(() {
        carregando = false;
        erro = 'Erro de conexão. Verifique sua internet e tente novamente.';
      });
    }
  }

  void _irParaLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Painel esquerdo decorativo (visível em telas largas)
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Tarefas\nCompartilhadas',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Organize, colabore e\nacompanhe tudo em um só lugar.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Formulário de cadastro
          Expanded(
            child: Container(
              color: AppTheme.surface,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header mobile
                        if (MediaQuery.of(context).size.width <= 800) ...[
                          const Icon(
                            Icons.task_alt_rounded,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                        ],

                        const Text(
                          'Criar conta',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Preencha os dados abaixo para se cadastrar',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Campo nome
                        const Text(
                          'Nome',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: nomeController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Seu nome completo',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Campo email
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'seu@email.com',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Campo senha
                        const Text(
                          'Senha',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: senhaController,
                          obscureText: !senhaVisivel,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                senhaVisivel
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () =>
                                  setState(() => senhaVisivel = !senhaVisivel),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Campo confirmar senha
                        const Text(
                          'Confirmar senha',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmarSenhaController,
                          obscureText: !confirmarSenhaVisivel,
                          onSubmitted: (_) => cadastrar(),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                confirmarSenhaVisivel
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () => setState(
                                () => confirmarSenhaVisivel =
                                    !confirmarSenhaVisivel,
                              ),
                            ),
                          ),
                        ),

                        // Mensagem de erro
                        if (erro != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    erro!,
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Mensagem de sucesso
                        if (sucesso != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    sucesso!,
                                    style: const TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Botão de cadastro
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: carregando ? null : cadastrar,
                            child: carregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Criar conta'),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Link para login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Já tem uma conta?',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: _irParaLogin,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                              ),
                              child: const Text('Entrar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
