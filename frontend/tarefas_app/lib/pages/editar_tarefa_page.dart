import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/tarefa_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class EditarTarefaPage extends StatefulWidget {
  final Tarefa tarefa;

  const EditarTarefaPage({super.key, required this.tarefa});

  @override
  State<EditarTarefaPage> createState() => _EditarTarefaPageState();
}

class _EditarTarefaPageState extends State<EditarTarefaPage> {
  final tarefaService = TarefaService();

  late TextEditingController tituloController;
  late TextEditingController descricaoController;

  bool carregando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: widget.tarefa.titulo);
    descricaoController =
        TextEditingController(text: widget.tarefa.descricao);
  }

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
      await tarefaService.editarTarefa(
        id: widget.tarefa.id,
        titulo: tituloController.text.trim(),
        descricao: descricaoController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        carregando = false;
        erro = 'Você não tem permissão para editar esta tarefa.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar tarefa'),
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
            // Info da tarefa original
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Editando: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.tarefa.titulo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: widget.tarefa.status, small: true),
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
                hintText: 'Título da tarefa',
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
                hintText: 'Descreva os detalhes da tarefa...',
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
                label: Text(carregando ? 'Salvando...' : 'Salvar alterações'),
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
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
