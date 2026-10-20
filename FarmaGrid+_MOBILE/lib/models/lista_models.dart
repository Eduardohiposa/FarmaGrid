// modelos menores pra transformar dados de dependentes e equipe recebidos em json
class DependentePaciente {
  final int id;
  final String nome, parentesco, cpf;
  DependentePaciente.fromJson(Map<String, dynamic> json)
    : id = int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      nome = (json['nome'] ?? '').toString(),
      parentesco = (json['parentesco'] ?? '').toString(),
      cpf = (json['cpf'] ?? '').toString();
}

class MembroEquipe {
  final String nome, curso, ra, descricao, imagemAsset, github, linkedin;
  MembroEquipe.fromJson(Map<String, dynamic> json)
    : nome = json['nome'] as String,
      curso = json['curso'] as String,
      ra = json['ra'] as String,
      descricao = json['descricao'] as String,
      imagemAsset = json['imagemAsset'] as String,
      github = json['github'] as String,
      linkedin = json['linkedin'] as String;
}
