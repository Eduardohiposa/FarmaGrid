int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

class PacientePerfil {
  final int id;
  final String nome;
  final String cpf;
  final String telefone;
  final String dataNascimento;
  final String tipoSanguineo;
  final String fotoPerfil;

  const PacientePerfil({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.dataNascimento,
    required this.tipoSanguineo,
    required this.fotoPerfil,
  });

  factory PacientePerfil.fromJson(Map<String, dynamic> json) => PacientePerfil(
    id: _asInt(json['id']),
    nome: '${json['nome'] ?? ''}',
    cpf: '${json['cpf'] ?? ''}',
    telefone: '${json['telefone'] ?? ''}',
    dataNascimento: '${json['dataNascimento'] ?? ''}',
    tipoSanguineo: '${json['tipoSanguineo'] ?? ''}',
    fotoPerfil: '${json['fotoPerfil'] ?? ''}',
  );
}

class ReceitaPaciente {
  final int id;
  final String medicamento;
  final String dosagem;
  final String duracao;
  final String instrucoes;
  final String observacoes;
  final String dataPrescricao;
  final String status;

  const ReceitaPaciente({
    required this.id,
    required this.medicamento,
    required this.dosagem,
    required this.duracao,
    required this.instrucoes,
    required this.observacoes,
    required this.dataPrescricao,
    required this.status,
  });

  factory ReceitaPaciente.fromJson(Map<String, dynamic> json) =>
      ReceitaPaciente(
        id: _asInt(json['id']),
        medicamento: '${json['medicamento'] ?? ''}',
        dosagem: '${json['dosagem'] ?? ''}',
        duracao: '${json['duracao'] ?? ''}',
        instrucoes: '${json['instrucoes'] ?? ''}',
        observacoes: '${json['observacoes'] ?? ''}',
        dataPrescricao: '${json['dataPrescricao'] ?? ''}',
        status: '${json['status'] ?? ''}',
      );
}

class ProntuarioPaciente {
  final int id;
  final String tipo;
  final String data;
  final String diagnostico;
  final String cid10;
  final String anamnese;
  final String exameFisico;
  final String conduta;
  final String retorno;

  const ProntuarioPaciente({
    required this.id,
    required this.tipo,
    required this.data,
    required this.diagnostico,
    required this.cid10,
    required this.anamnese,
    required this.exameFisico,
    required this.conduta,
    required this.retorno,
  });

  factory ProntuarioPaciente.fromJson(Map<String, dynamic> json) =>
      ProntuarioPaciente(
        id: _asInt(json['id']),
        tipo: '${json['tipo'] ?? 'Consulta'}',
        data: '${json['ultimaVisita'] ?? ''}',
        diagnostico: '${json['condicao'] ?? ''}',
        cid10: '${json['cid10'] ?? ''}',
        anamnese: '${json['anamnese'] ?? ''}',
        exameFisico: '${json['exameFisico'] ?? ''}',
        conduta: '${json['conduta'] ?? json['notas'] ?? ''}',
        retorno: '${json['dataRetorno'] ?? ''}',
      );
}

class ProdutoPaciente {
  final int id;
  final String nome;
  final String categoria;
  final double preco;
  final int quantidade;
  final bool controlado;

  const ProdutoPaciente({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.quantidade,
    required this.controlado,
  });

  String get precoFormatado =>
      'R\$ ' + preco.toStringAsFixed(2).replaceAll('.', ',');
  factory ProdutoPaciente.fromJson(Map<String, dynamic> json) =>
      ProdutoPaciente(
        id: _asInt(json['id']),
        nome: '${json['nome'] ?? ''}',
        categoria: '${json['categoria'] ?? ''}',
        preco: _asDouble(json['preco']),
        quantidade: _asInt(json['quantidade']),
        controlado: json['tarjaPreta'] == true,
      );
}

class CupomPaciente {
  final int id;
  final String codigo;
  final String descricao;
  final String tipo;
  final double valor;
  final String validade;
  final String status;
  final bool resgatado;

  const CupomPaciente({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.tipo,
    required this.valor,
    required this.validade,
    required this.status,
    required this.resgatado,
  });

  factory CupomPaciente.fromJson(Map<String, dynamic> json) => CupomPaciente(
    id: _asInt(json['id']),
    codigo: '${json['codigo'] ?? ''}',
    descricao: '${json['descricao'] ?? ''}',
    tipo: '${json['tipo'] ?? ''}',
    valor: _asDouble(json['valor']),
    validade: '${json['validade'] ?? ''}',
    status: '${json['status'] ?? ''}',
    resgatado: json['resgatado'] == true,
  );
}

class FarmaciaProxima {
  final String id, nome, endereco, horario, fonte, googleMapsUri;
  final bool? aberto;
  final double? distanciaMetros;
  FarmaciaProxima.fromJson(Map<String, dynamic> json)
    : id = (json['id'] ?? '').toString(),
      nome = (json['nome'] ?? 'Farmácia').toString(),
      endereco = (json['endereco'] ?? '').toString(),
      horario = (json['horario'] ?? 'Horário não informado').toString(),
      fonte = (json['fonte'] ?? '').toString(),
      googleMapsUri = (json['googleMapsUri'] ?? '').toString(),
      aberto = json['aberto'] is bool ? json['aberto'] as bool : null,
      distanciaMetros = (json['distanciaMetros'] as num?)?.toDouble();
}

class SolicitacaoExame {
  final int id;
  final String? status;
  final String? justificativa;
  final String? exame;
  final String? solicitadoEm;
  SolicitacaoExame.fromJson(Map<String, dynamic> json)
    : id = int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      status = json['status']?.toString(),
      justificativa = json['justificativa']?.toString(),
      exame = json['exame']?.toString(),
      solicitadoEm = json['solicitadoEm']?.toString();
}

class ResultadoExame {
  final int id;
  final String? titulo;
  final String? tipo;
  final String? data;
  ResultadoExame.fromJson(Map<String, dynamic> json)
    : id = int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      titulo = json['titulo']?.toString(),
      tipo = json['tipo']?.toString(),
      data = json['data']?.toString();
}
