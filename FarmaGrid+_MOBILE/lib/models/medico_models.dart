int _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

// organiza em objetos os dados de consulta, paciente e prontuario da api
class ConsultaMedica {
  final int id;
  final int idMedico;
  final int idPaciente;
  final String nomePaciente;
  final String data;
  final String horario;
  final String status;
  final String duracao;
  final String tipo;

  const ConsultaMedica({
    required this.id,
    required this.idMedico,
    required this.idPaciente,
    required this.nomePaciente,
    required this.data,
    required this.horario,
    required this.status,
    required this.duracao,
    required this.tipo,
  });

  factory ConsultaMedica.fromJson(Map<String, dynamic> json) => ConsultaMedica(
    id: _int(json['id']),
    idMedico: _int(json['idMedico'] ?? json['id_medico']),
    idPaciente: _int(json['idPaciente'] ?? json['id_paciente']),
    nomePaciente: '${json['nomePaciente'] ?? json['nome_paciente'] ?? ''}',
    data: '${json['data'] ?? ''}',
    horario: '${json['horario'] ?? ''}',
    status: '${json['status'] ?? ''}',
    duracao: '${json['duracao'] ?? ''}',
    tipo: '${json['tipo'] ?? ''}',
  );
}

class PacienteMedico {
  final int id;
  final String nome;
  final String cpf;
  final int? idade;
  final List<String> condicoes;
  final int totalConsultas;
  final int totalReceitas;
  final String ultimaVisita;
  final String status;
  final String fotoPerfil;

  const PacienteMedico({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.idade,
    required this.condicoes,
    required this.totalConsultas,
    required this.totalReceitas,
    required this.ultimaVisita,
    required this.status,
    required this.fotoPerfil,
  });

  factory PacienteMedico.fromJson(Map<String, dynamic> json) {
    final idadeValor = json['idade'];
    return PacienteMedico(
      id: _int(json['id']),
      nome: '${json['nome'] ?? json['nomePaciente'] ?? ''}',
      cpf: '${json['cpf'] ?? ''}',
      idade: idadeValor == null ? null : _int(idadeValor),
      condicoes: (json['condicoes'] as List? ?? const [])
          .map((item) => '$item')
          .where((item) => item.isNotEmpty)
          .toList(),
      totalConsultas: _int(json['totalConsultas']),
      totalReceitas: _int(json['totalReceitas']),
      ultimaVisita: '${json['ultimaVisita'] ?? ''}',
      status: '${json['status'] ?? 'Ativo'}',
      fotoPerfil: '${json['fotoPerfil'] ?? ''}',
    );
  }

  String get nomeComIdade => idade == null ? nome : '$nome, $idade anos';

  String get cpfMascarado {
    final digitos = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length != 11) return cpf.isEmpty ? 'CPF não informado' : cpf;
    return '***.***.${digitos.substring(6, 9)}-${digitos.substring(9)}';
  }

  String get cpfFormatado {
    final digitos = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length != 11) return cpf.isEmpty ? 'CPF não informado' : cpf;
    return '${digitos.substring(0, 3)}.${digitos.substring(3, 6)}.${digitos.substring(6, 9)}-${digitos.substring(9)}';
  }
}

class ReceitaMedica {
  final int id;
  final int idMedico;
  final int idPaciente;
  final String medicamento;
  final String concentracao;
  final String dosagem;
  final String frequencia;
  final String duracao;
  final String viaAdministracao;
  final String instrucoes;
  final String observacoes;
  final String dataPrescricao;
  final String status;

  const ReceitaMedica({
    this.id = 0,
    required this.idMedico,
    required this.idPaciente,
    required this.medicamento,
    this.concentracao = '',
    required this.dosagem,
    this.frequencia = '',
    required this.duracao,
    this.viaAdministracao = 'Oral',
    this.instrucoes = '',
    this.observacoes = '',
    this.dataPrescricao = '',
    this.status = 'Ativa',
  });

  Map<String, dynamic> toJson() => {
    'idMedico': idMedico,
    'idPaciente': idPaciente,
    'medicamento': medicamento,
    'concentracao': concentracao,
    'dosagem': dosagem,
    'frequencia': frequencia,
    'duracao': duracao,
    'viaAdministracao': viaAdministracao,
    'instrucoes': instrucoes,
    'observacoes': observacoes,
    'dataPrescricao': dataPrescricao,
    'status': status,
  };
}

class RegistroClinico {
  final int id;
  final String? condicao;
  final String? ultimaVisita;
  final String? cid10;
  final String? pa;
  final String? temperatura;
  final String? spo2;
  final String? anamnese;
  final String? exameFisico;
  final String? peso;
  final String? conduta;
  final String? dataRetorno;
  final String? notas;
  final String? status;
  final String? tipo;
  RegistroClinico.fromJson(Map<String, dynamic> json)
    : id = int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      condicao = json['condicao']?.toString(),
      ultimaVisita = json['ultimaVisita']?.toString(),
      cid10 = json['cid10']?.toString(),
      pa = json['pa']?.toString(),
      temperatura = json['temperatura']?.toString(),
      spo2 = json['spo2']?.toString(),
      anamnese = json['anamnese']?.toString(),
      exameFisico = json['exameFisico']?.toString(),
      peso = json['peso']?.toString(),
      conduta = json['conduta']?.toString(),
      dataRetorno = json['dataRetorno']?.toString(),
      notas = json['notas']?.toString(),
      status = json['status']?.toString(),
      tipo = json['tipo']?.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'condicao': condicao,
    'ultimaVisita': ultimaVisita,
    'cid10': cid10,
    'pa': pa,
    'temperatura': temperatura,
    'spo2': spo2,
    'anamnese': anamnese,
    'exameFisico': exameFisico,
    'peso': peso,
    'conduta': conduta,
    'dataRetorno': dataRetorno,
    'notas': notas,
    'status': status,
    'tipo': tipo,
  };
}
