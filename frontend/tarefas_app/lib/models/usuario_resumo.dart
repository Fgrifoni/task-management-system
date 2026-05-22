class UsuarioResumo {
  final int id;
  final String nome;
  final String email;

  UsuarioResumo({required this.id, required this.nome, required this.email});

  factory UsuarioResumo.fromJson(Map<String, dynamic> json) {
    return UsuarioResumo(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
    );
  }
}
