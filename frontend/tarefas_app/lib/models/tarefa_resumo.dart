class TarefaResumo {
  final int pendentes;
  final int emAndamento;
  final int concluidas;

  TarefaResumo({
    required this.pendentes,
    required this.emAndamento,
    required this.concluidas,
  });

  factory TarefaResumo.fromJson(Map<String, dynamic> json) {
    return TarefaResumo(
      pendentes: json['pendentes'],
      emAndamento: json['emAndamento'],
      concluidas: json['concluidas'],
    );
  }
}
