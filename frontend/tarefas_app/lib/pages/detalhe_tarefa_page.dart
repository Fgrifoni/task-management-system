import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/tarefa_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class DetalheTarefaPage extends StatelessWidget {
  final Tarefa tarefa;

  const DetalheTarefaPage({super.key, required this.tarefa});

  String _formatarData(String data) {
    if (data.isEmpty) return '—';
    try {
      final dt = DateTime.parse(data);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Card principal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de status no topo
                StatusBadge(status: tarefa.status),

                const SizedBox(height: 14),

                // Título
                Text(
                  tarefa.titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),

                if (tarefa.descricao.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    tarefa.descricao,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Seção de metadados
          _SectionTitle(title: 'Informações'),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_rounded,
                  label: 'Criador',
                  value: tarefa.criadorNome,
                ),
                const Divider(height: 1, indent: 16),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Criada em',
                  value: _formatarData(tarefa.createdAt),
                ),
                const Divider(height: 1, indent: 16),
                _InfoRow(
                  icon: Icons.update_rounded,
                  label: 'Atualizada em',
                  value: _formatarData(tarefa.updatedAt),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Seção de compartilhamentos
          Row(
            children: [
              _SectionTitle(title: 'Compartilhada com'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${tarefa.compartilhados.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (tarefa.compartilhados.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 32,
                    color: AppTheme.textMuted,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nenhum usuário compartilhado',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: tarefa.compartilhados.mapIndexed((i, usuario) {
                  final isLast =
                      i == tarefa.compartilhados.length - 1;
                  return Column(
                    children: [
                      _CompartilhadoTile(
                        usuario: usuario,
                        tarefaId: tarefa.id,
                        onRemovido: () => Navigator.pop(context, true),
                      ),
                      if (!isLast) const Divider(height: 1, indent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompartilhadoTile extends StatelessWidget {
  final dynamic usuario;
  final int tarefaId;
  final VoidCallback onRemovido;

  const _CompartilhadoTile({
    required this.usuario,
    required this.tarefaId,
    required this.onRemovido,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Text(
              usuario.nome.isNotEmpty
                  ? usuario.nome[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  usuario.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.person_remove_rounded,
              size: 18,
              color: Color(0xFFDC2626),
            ),
            tooltip: 'Remover acesso',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Remover acesso'),
                  content: Text(
                    'Remover o acesso de ${usuario.nome} a esta tarefa?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Remover'),
                    ),
                  ],
                ),
              );

              if (confirmar != true) return;

              try {
                final service = TarefaService();
                await service.removerCompartilhamento(
                  tarefaId: tarefaId,
                  usuarioId: usuario.id,
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Acesso removido'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF059669),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );

                onRemovido();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Você não tem permissão para remover este acesso'),
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
            },
          ),
        ],
      ),
    );
  }
}

// Extensão utilitária para mapIndexed
extension IterableExtension<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) f) sync* {
    var index = 0;
    for (final item in this) {
      yield f(index++, item);
    }
  }
}
