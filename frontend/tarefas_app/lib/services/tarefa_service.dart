import 'dart:convert';

import '../models/tarefa.dart';
import '../storage/auth_storage.dart';
import 'api_service.dart';
import '../models/tarefa_resumo.dart';

class TarefaService {
  final ApiService _apiService = ApiService();

  Future<List<Tarefa>> listarMinhasTarefas({
    String? status,
    String? texto,
  }) async {
    final query = StringBuffer('/tarefas/minhas?page=0&size=20');

    if (status != null && status.isNotEmpty) {
      query.write('&status=$status');
    }

    if (texto != null && texto.isNotEmpty) {
      query.write('&texto=$texto');
    }

    final response = await _apiService.get(
      query.toString(),
      token: AuthStorage.accessToken,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List content = data['content'];

      return content.map((item) => Tarefa.fromJson(item)).toList();
    }

    throw Exception('Erro ao buscar tarefas');
  }

  Future<void> criarTarefa({
    required String titulo,
    required String descricao,
  }) async {
    final response = await _apiService.post(
      '/tarefas',
      token: AuthStorage.accessToken,
      body: {'titulo': titulo, 'descricao': descricao},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao criar tarefa');
    }
  }

  Future<void> atualizarStatus({
    required int id,
    required String status,
  }) async {
    final response = await _apiService.put(
      '/tarefas/$id/status?status=$status',
      token: AuthStorage.accessToken,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar status');
    }
  }

  Future<TarefaResumo> buscarResumo() async {
    final response = await _apiService.get(
      '/tarefas/minhas/resumo',
      token: AuthStorage.accessToken,
    );

    print('STATUS RESUMO: ${response.statusCode}');
    print('BODY RESUMO: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return TarefaResumo.fromJson(data);
    }

    throw Exception('Erro ao buscar resumo');
  }

  Future<void> deletarTarefa(int id) async {
    final response = await _apiService.delete(
      '/tarefas/$id',
      token: AuthStorage.accessToken,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar tarefa');
    }
  }

  Future<void> compartilharTarefa({
    required int tarefaId,
    required String email,
  }) async {
    final response = await _apiService.put(
      '/tarefas/$tarefaId/compartilhar?email=$email',
      token: AuthStorage.accessToken,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao compartilhar tarefa');
    }
  }

  Future<void> editarTarefa({
    required int id,
    required String titulo,
    required String descricao,
  }) async {
    final response = await _apiService.put(
      '/tarefas/$id',

      token: AuthStorage.accessToken,

      body: {'titulo': titulo, 'descricao': descricao},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao editar tarefa');
    }
  }

  Future<List<Tarefa>> listarDeletadas() async {
    final response = await _apiService.get(
      '/tarefas/deletadas?page=0&size=20',
      token: AuthStorage.accessToken,
    );
    print('STATUS LIXEIRA: ${response.statusCode}');
    print('BODY LIXEIRA: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List content = data['content'];

      return content.map((item) => Tarefa.fromJson(item)).toList();
    }

    throw Exception('Erro ao buscar tarefas deletadas');
  }

  Future<void> restaurarTarefa(int id) async {
    final response = await _apiService.put(
      '/tarefas/$id/restaurar',
      token: AuthStorage.accessToken,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao restaurar tarefa');
    }
  }

  Future<void> removerCompartilhamento({
    required int tarefaId,
    required int usuarioId,
  }) async {
    final response = await _apiService.delete(
      '/tarefas/$tarefaId/compartilhar/$usuarioId',
      token: AuthStorage.accessToken,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover compartilhamento');
    }
  }
}
