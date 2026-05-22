import 'package:flutter/material.dart';
import 'criar_tarefa_page.dart';
import '../models/tarefa.dart';
import '../models/tarefa_resumo.dart';
import '../services/tarefa_service.dart';
import '../pages/login_page.dart';
import '../storage/auth_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import '../widgets/tarefa_card.dart';
import 'editar_tarefa_page.dart';
import 'detalhe_tarefa_page.dart';
import 'lixeira_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tarefaService = TarefaService();
  String? filtroStatus;
  String textoBusca = '';
  final buscaController = TextEditingController();
  Timer? buscaDebounce;

  late Future<List<Tarefa>> tarefasFuture;
  late Future<TarefaResumo> resumoFuture;

  void carregarTarefas() {
    tarefasFuture = tarefaService.listarMinhasTarefas(
      status: filtroStatus,
      texto: textoBusca,
    );
    resumoFuture = tarefaService.buscarResumo();
  }

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  @override
  void dispose() {
    buscaDebounce?.cancel();
    buscaController.dispose();
    super.dispose();
  }

  void _onBuscaChanged(String valor) {
    buscaDebounce?.cancel();
    buscaDebounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        textoBusca = valor;
        carregarTarefas();
      });
    });
  }

  Future<bool?> _confirmarExclusao(Tarefa tarefa) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text(
          'A tarefa "${tarefa.titulo}" será movida para a lixeira.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirTarefa(Tarefa tarefa) async {
    try {
      await tarefaService.deletarTarefa(tarefa.id);
      setState(carregarTarefas);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        'Você não tem permissão para excluir esta tarefa',
        erro: true,
      );
    }
  }

  Future<void> _alterarStatus(Tarefa tarefa) async {
    final novoStatus = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StatusBottomSheet(statusAtual: tarefa.status),
    );

    if (novoStatus == null) return;
    await tarefaService.atualizarStatus(id: tarefa.id, status: novoStatus);
    setState(carregarTarefas);
  }

  Future<void> _compartilhar(Tarefa tarefa) async {
    final emailController = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Compartilhar tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${tarefa.titulo}"',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Email do usuário',
                hintText: 'usuario@email.com',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(context, emailController.text),
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    try {
      await tarefaService.compartilharTarefa(tarefaId: tarefa.id, email: email);
      if (!mounted) return;
      _showSnackBar('Tarefa compartilhada com sucesso!');
      setState(carregarTarefas);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao compartilhar tarefa', erro: true);
    }
  }

  void _showSnackBar(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              erro ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(mensagem),
          ],
        ),
        backgroundColor: erro
            ? const Color(0xFFDC2626)
            : const Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Minhas Tarefas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Lixeira',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LixeiraPage()),
              );
              setState(carregarTarefas);
            },
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFEEF2FF),
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: AppTheme.primary,
              ),
            ),
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 8),
                    Text('Sair', style: TextStyle(color: Color(0xFFDC2626))),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthStorage.clear();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: FutureBuilder<TarefaResumo>(
        future: resumoFuture,
        builder: (context, resumoSnapshot) {
          if (resumoSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (resumoSnapshot.hasError) {
            return _ErrorState(
              mensagem: 'Erro ao carregar dados',
              onRetry: () => setState(carregarTarefas),
            );
          }

          final resumo = resumoSnapshot.data!;

          return Column(
            children: [
              // Dashboard de resumo
              _DashboardResumo(resumo: resumo),

              // Barra de busca e filtros
              _FiltroBusca(
                buscaController: buscaController,
                filtroStatus: filtroStatus,
                onBuscaChanged: _onBuscaChanged,
                onFiltroChanged: (valor) {
                  setState(() {
                    filtroStatus = valor;
                    carregarTarefas();
                  });
                },
              ),

              // Lista de tarefas
              Expanded(
                child: FutureBuilder<List<Tarefa>>(
                  future: tarefasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _ErrorState(
                        mensagem: 'Erro ao carregar tarefas',
                        onRetry: () => setState(carregarTarefas),
                      );
                    }

                    final tarefas = snapshot.data ?? [];

                    if (tarefas.isEmpty) {
                      return _EmptyState(
                        filtroAtivo:
                            filtroStatus != null || textoBusca.isNotEmpty,
                      );
                    }

                    return RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: () async => setState(carregarTarefas),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: tarefas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tarefa = tarefas[index];

                          return TarefaCard(
                            tarefa: tarefa,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalheTarefaPage(tarefa: tarefa),
                                ),
                              );
                              setState(carregarTarefas);
                            },
                            onEdit: () async {
                              final editou = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditarTarefaPage(tarefa: tarefa),
                                ),
                              );
                              if (editou == true) setState(carregarTarefas);
                            },
                            onShare: () => _compartilhar(tarefa),
                            onChangeStatus: () => _alterarStatus(tarefa),
                            onDelete: () async {
                              final confirmou = await _confirmarExclusao(
                                tarefa,
                              );
                              if (confirmou != true) return false;
                              await _excluirTarefa(tarefa);
                              return true;
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final criou = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CriarTarefaPage()),
          );
          if (criou == true) setState(carregarTarefas);
        },
        tooltip: 'Nova tarefa',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ─── Widgets internos ────────────────────────────────────────────────────────

class _DashboardResumo extends StatelessWidget {
  final TarefaResumo resumo;
  const _DashboardResumo({required this.resumo});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _ResumoCard(
            label: 'Pendentes',
            valor: resumo.pendentes,
            cor: AppTheme.statusPendente,
            icone: Icons.radio_button_unchecked_rounded,
          ),
          const SizedBox(width: 10),
          _ResumoCard(
            label: 'Andamento',
            valor: resumo.emAndamento,
            cor: AppTheme.statusAndamento,
            icone: Icons.timelapse_rounded,
          ),
          const SizedBox(width: 10),
          _ResumoCard(
            label: 'Concluídas',
            valor: resumo.concluidas,
            cor: AppTheme.statusConcluida,
            icone: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String label;
  final int valor;
  final Color cor;
  final IconData icone;

  const _ResumoCard({
    required this.label,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 16, color: cor),
                const Spacer(),
                Text(
                  '$valor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: cor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltroBusca extends StatelessWidget {
  final TextEditingController buscaController;
  final String? filtroStatus;
  final ValueChanged<String> onBuscaChanged;
  final ValueChanged<String?> onFiltroChanged;

  const _FiltroBusca({
    required this.buscaController,
    required this.filtroStatus,
    required this.onBuscaChanged,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 14),
          // Campo de busca
          TextField(
            controller: buscaController,
            onChanged: onBuscaChanged,
            decoration: const InputDecoration(
              hintText: 'Buscar tarefas...',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todos',
                  selecionado: filtroStatus == null,
                  onTap: () => onFiltroChanged(null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pendentes',
                  selecionado: filtroStatus == 'PENDENTE',
                  cor: AppTheme.statusPendente,
                  onTap: () => onFiltroChanged('PENDENTE'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Em andamento',
                  selecionado: filtroStatus == 'EM_ANDAMENTO',
                  cor: AppTheme.statusAndamento,
                  onTap: () => onFiltroChanged('EM_ANDAMENTO'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Concluídas',
                  selecionado: filtroStatus == 'CONCLUIDA',
                  cor: AppTheme.statusConcluida,
                  onTap: () => onFiltroChanged('CONCLUIDA'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selecionado;
  final Color? cor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selecionado,
    this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final corEfetiva = cor ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selecionado ? corEfetiva : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado ? corEfetiva : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selecionado ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StatusBottomSheet extends StatelessWidget {
  final String statusAtual;
  const _StatusBottomSheet({required this.statusAtual});

  @override
  Widget build(BuildContext context) {
    final opcoes = [
      (
        'PENDENTE',
        'Pendente',
        AppTheme.statusPendente,
        Icons.radio_button_unchecked_rounded,
      ),
      (
        'EM_ANDAMENTO',
        'Em andamento',
        AppTheme.statusAndamento,
        Icons.timelapse_rounded,
      ),
      (
        'CONCLUIDA',
        'Concluída',
        AppTheme.statusConcluida,
        Icons.check_circle_rounded,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Alterar status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            ...opcoes.map((opcao) {
              final (valor, texto, cor, icone) = opcao;
              final selecionado = statusAtual == valor;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icone, color: cor, size: 20),
                ),
                title: Text(
                  texto,
                  style: TextStyle(
                    fontWeight: selecionado
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: selecionado ? cor : AppTheme.textPrimary,
                  ),
                ),
                trailing: selecionado
                    ? Icon(Icons.check_rounded, color: cor)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: selecionado
                    ? cor.withOpacity(0.06)
                    : Colors.transparent,
                onTap: () => Navigator.pop(context, valor),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool filtroAtivo;
  const _EmptyState({required this.filtroAtivo});

  @override
  Widget build(BuildContext context) {
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
              child: Icon(
                filtroAtivo ? Icons.search_off_rounded : Icons.task_outlined,
                size: 48,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filtroAtivo
                  ? 'Nenhuma tarefa encontrada'
                  : 'Nenhuma tarefa ainda',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filtroAtivo
                  ? 'Tente ajustar os filtros ou o texto de busca.'
                  : 'Clique no botão abaixo para criar sua primeira tarefa.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _ErrorState({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
          Text(mensagem, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
