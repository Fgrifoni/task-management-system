import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/tarefa_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class LixeiraPage extends StatefulWidget {
  const LixeiraPage({super.key});

  @override
  State<LixeiraPage> createState() => _LixeiraPageState();
}

class _LixeiraPageState extends State<LixeiraPage> {
  final tarefaService = TarefaService();
  late Future<List<Tarefa>> deletadasFuture;

  @override
  void initState() {
    super.initState();
    deletadasFuture = tarefaService.listarDeletadas();
  }

  void recarregar() {
    setState(() {
      deletadasFuture = tarefaService.listarDeletadas();
    });
  }

  Future<void> _restaurar(Tarefa tarefa) async {
    try {
      await tarefaService.restaurarTarefa(tarefa.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.restore_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Tarefa restaurada com sucesso'),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      recarregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Erro ao restaurar tarefa'),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, size: 22),
            SizedBox(width: 8),
            Text('Lixeira'),
          ],
        ),
      ),
      body: FutureBuilder<List<Tarefa>>(
        future: deletadasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro ao carregar lixeira',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: recarregar,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final tarefas = snapshot.data ?? [];

          if (tarefas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.delete_sweep_rounded,
                        size: 48,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Lixeira vazia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tarefas excluídas aparecem aqui\npara que você possa restaurá-las.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Banner informativo
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Restaure as tarefas que deseja recuperar.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de tarefas excluídas
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async => recarregar(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tarefas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tarefa = tarefas[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Row(
                            children: [
                              // Ícone de lixo
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Color(0xFFDC2626),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Título e status
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tarefa.titulo,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    StatusBadge(
                                      status: tarefa.status,
                                      small: true,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Botão restaurar
                              TextButton.icon(
                                onPressed: () => _restaurar(tarefa),
                                icon: const Icon(
                                  Icons.restore_rounded,
                                  size: 16,
                                ),
                                label: const Text('Restaurar'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
