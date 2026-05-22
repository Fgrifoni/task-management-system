import 'package:flutter/material.dart';

import '../services/tarefa_service.dart';
import '../theme/app_theme.dart';

class CriarTarefaPage extends StatefulWidget {
  const CriarTarefaPage({super.key});

  @override
  State<CriarTarefaPage> createState() => _CriarTarefaPageState();
}

class _CriarTarefaPageState extends State<CriarTarefaPage> {
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final tarefaService = TarefaService();

  bool carregando = false;
  String? erro;

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (tituloController.text.trim().isEmpty) {
      setState(() => erro = 'O título é obrigatório.');
      return;
    }

    if (descricaoController.text.trim().isEmpty) {
      setState(() => erro = 'A descrição é obrigatória.');
      return;
    }

    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      await tarefaService.criarTarefa(
        titulo: tituloController.text.trim(),
        descricao: descricaoController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        carregando = false;
        erro = 'Erro ao criar tarefa. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova tarefa'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da seção
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_task_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Preencha os dados da nova tarefa',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Campo título
            _CampoLabel(label: 'Título', obrigatorio: true),
            const SizedBox(height: 6),
            TextField(
              controller: tituloController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (erro != null) setState(() => erro = null);
              },
              decoration: const InputDecoration(
                hintText: 'Ex: Revisar relatório mensal',
                prefixIcon: Icon(Icons.title_rounded, size: 20),
              ),
            ),

            const SizedBox(height: 20),

            // Campo descrição
            _CampoLabel(label: 'Descrição', obrigatorio: true),
            const SizedBox(height: 6),
            TextField(
              controller: descricaoController,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Descreva os detalhes da tarefa',
                alignLabelWithHint: true,
              ),
            ),

            // Erro
            if (erro != null) ...[
              const SizedBox(height: 16),
              _ErrorBanner(mensagem: erro!),
            ],

            const SizedBox(height: 32),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: carregando ? null : salvar,
                icon: carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(carregando ? 'Criando...' : 'Criar tarefa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoLabel extends StatelessWidget {
  final String label;
  final bool obrigatorio;

  const _CampoLabel({required this.label, required this.obrigatorio});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        if (obrigatorio) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: Color(0xFFEF4444), fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String mensagem;
  const _ErrorBanner({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
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
              mensagem,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
