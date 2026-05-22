import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/home_page.dart';
import '../pages/cadastro_page.dart';
import '../storage/auth_storage.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final authService = AuthService();

  bool carregando = false;
  bool senhaVisivel = false;
  String? erro;

  Future<void> fazerLogin() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resposta = await authService.login(
        email: emailController.text,
        senha: senhaController.text,
      );

      setState(() => carregando = false);

      debugPrint('ACCESS TOKEN: ${resposta.accessToken}');
      debugPrint('REFRESH TOKEN: ${resposta.refreshToken}');

      await AuthStorage.saveTokens(
        access: resposta.accessToken,
        refresh: resposta.refreshToken,
      );

      debugPrint('TOKEN APÓS SALVAR: ${AuthStorage.accessToken}');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      setState(() {
        carregando = false;
        erro = 'Email ou senha inválidos. Tente novamente.';
      });
    }
  }

  void _irParaCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPage()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
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

          // Formulário de login
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
                        // Header
                        if (MediaQuery.of(context).size.width <= 800) ...[
                          const Icon(
                            Icons.task_alt_rounded,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                        ],

                        const Text(
                          'Bem-vindo de volta',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Entre com suas credenciais para continuar',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 36),

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
                          onSubmitted: (_) => fazerLogin(),
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
                          onSubmitted: (_) => fazerLogin(),
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

                        const SizedBox(height: 28),

                        // Botão de login
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: carregando ? null : fazerLogin,
                            child: carregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Link para cadastro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Não tem uma conta?',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: _irParaCadastro,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                              ),
                              child: const Text('Criar conta'),
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
