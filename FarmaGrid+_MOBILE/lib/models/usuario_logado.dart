// converte os dados da sessao entre o formato json da api e objetos
class UsuarioLogado {
  final String token;
  final int id;
  final String email;
  final int tipo;
  final String perfil;

  final int? idMedico;
  final int? idPaciente;
  final int? idFarmacia;
  final int? idBalconista;
  final int? idCaixa;

  UsuarioLogado({
    required this.token,
    required this.id,
    required this.email,
    required this.tipo,
    required this.perfil,
    this.idMedico,
    this.idPaciente,
    this.idFarmacia,
    this.idBalconista,
    this.idCaixa,
  });

  factory UsuarioLogado.fromJson(Map<String, dynamic> json) {
    return UsuarioLogado(
      token: json['token']?.toString() ?? '',
      id: json['id'] as int,
      email: json['email']?.toString() ?? '',
      tipo: json['tipo'] as int,
      perfil: json['perfil']?.toString() ?? '',
      idMedico: json['idMedico'] as int?,
      idPaciente: json['idPaciente'] as int?,
      idFarmacia: json['idFarmacia'] as int?,
      idBalconista: json['idBalconista'] as int?,
      idCaixa: json['idCaixa'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'email': email,
      'tipo': tipo,
      'perfil': perfil,
      'idMedico': idMedico,
      'idPaciente': idPaciente,
      'idFarmacia': idFarmacia,
      'idBalconista': idBalconista,
      'idCaixa': idCaixa,
    };
  }
}
