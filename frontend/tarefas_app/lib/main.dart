import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'storage/auth_storage.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthStorage.loadTokens();

  debugPrint('TOKEN SALVO: ${AuthStorage.accessToken}');

  runApp(const TarefasApp());
}

class TarefasApp extends StatelessWidget {
  const TarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas Compartilhadas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: AuthStorage.isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
