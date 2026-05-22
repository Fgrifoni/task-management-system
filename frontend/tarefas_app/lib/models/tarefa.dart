import 'usuario_resumo.dart';

class Tarefa {
  final int id;
  final String titulo;
  final String descricao;
  final String status;
  final int criadorId;
  final String criadorNome;
  final String createdAt;
  final String updatedAt;

  Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.criadorId,
    required this.criadorNome,
    required this.createdAt,
    required this.updatedAt,
    required this.compartilhados,
  });

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      status: json['status'],
      criadorId: json['criadorId'],
      criadorNome: json['criadorNome'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      compartilhados: (json['compartilhados'] as List)
          .map((item) => UsuarioResumo.fromJson(item))
          .toList(),
    );
  }

  final List<UsuarioResumo> compartilhados;
}
