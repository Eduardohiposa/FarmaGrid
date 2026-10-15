import '../models/medico_models.dart';
import '../models/paciente_models.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PacienteService {
  static int get idPaciente {
    final id = AuthService.usuarioLogado?.idPaciente;
    if (id == null) {
      throw ApiException('Sessão de paciente inválida. Faça login novamente.');
    }
    return id;
  }

  static Future<PacientePerfil> buscarPerfil() async => PacientePerfil.fromJson(
    await ApiService.getMap('/api/pacientes/$idPaciente/config'),
  );

  static Future<List<ConsultaMedica>> listarConsultas() async =>
      (await ApiService.getList(
        '/api/teleconsultas/paciente/$idPaciente',
      )).map(ConsultaMedica.fromJson).toList();

  static Future<List<ReceitaPaciente>> listarReceitas() async =>
      (await ApiService.getList(
        '/api/receitas/paciente/$idPaciente',
      )).map(ReceitaPaciente.fromJson).toList();

  static Future<List<ProntuarioPaciente>> listarProntuarios() async =>
      (await ApiService.getList(
        '/api/prontuarios/paciente/$idPaciente',
      )).map(ProntuarioPaciente.fromJson).toList();

  static Future<List<ProdutoPaciente>> listarProdutos() async =>
      (await ApiService.getList(
        '/api/produtos',
      )).map(ProdutoPaciente.fromJson).toList();

  static Future<List<CupomPaciente>> listarCupons() async {
    final itens = await ApiService.getList('/api/cupons/disponiveis');
    return itens
        .map((json) => CupomPaciente.fromJson({...json, 'resgatado': false}))
        .toList();
  }

  static Future<CupomPaciente> resgatarCupom(int idCupom) async =>
      CupomPaciente.fromJson(
        await ApiService.post(
          '/api/pacientes/$idPaciente/cupons/$idCupom/resgatar',
          const {},
        ),
      );

  static Future<List<Map<String, dynamic>>> listarDependentes() =>
      ApiService.getList('/api/pacientes/$idPaciente/dependentes');
  static Future<List<Map<String, dynamic>>> listarAlergias() =>
      ApiService.getList('/api/pacientes/$idPaciente/alergias');
  static Future<List<Map<String, dynamic>>> listarCartoes() =>
      ApiService.getList('/api/pacientes/$idPaciente/cartoes');
  static Future<List<Map<String, dynamic>>> listarExames() =>
      ApiService.getList('/api/relatorios/paciente/$idPaciente');
  static Future<List<Map<String, dynamic>>> listarSolicitacoesExame() =>
      ApiService.getList('/api/solicitacoes-exame/paciente/$idPaciente');
  static Future<Map<String, dynamic>> solicitarExame(
    String exame,
    String justificativa,
  ) => ApiService.post('/api/solicitacoes-exame', {
    'idPaciente': idPaciente,
    'exame': exame,
    'justificativa': justificativa,
  });
  static Future<List<Map<String, dynamic>>> listarMedicos() =>
      ApiService.getList('/api/medicos-disponiveis');
  static Future<Map<String, dynamic>> agendarTeleconsulta(
    Map<String, dynamic> dados,
  ) => ApiService.post('/api/teleconsultas', {
    ...dados,
    'idPaciente': idPaciente,
  });
  static Future<List<FarmaciaProxima>> listarFarmaciasProximas() async {
    final dados = await ApiService.getList(
      '/api/pacientes/$idPaciente/farmacias-proximas',
    );
    return List<FarmaciaProxima>.from(
      dados.map((f) => FarmaciaProxima.fromJson(f)),
    );
  }

  static Future<void> alterarAssinatura(
    bool premium, {
    String tipo = 'MENSAL',
  }) => ApiService.put('/api/pacientes/$idPaciente/assinatura', {
    'premium': premium,
    'tipo': tipo,
  });

  static Future<void> atualizarPerfil(Map<String, dynamic> dados) async =>
      ApiService.put('/api/pacientes/$idPaciente', dados);
  static Future<void> adicionarDependente(Map<String, dynamic> dados) async =>
      ApiService.post('/api/dependentes', {...dados, 'idPaciente': idPaciente});
  static Future<void> removerDependente(int id) =>
      ApiService.delete('/api/dependentes/$id');
  static Future<void> adicionarCartao(Map<String, dynamic> dados) async =>
      ApiService.post('/api/cartoes', {...dados, 'idPaciente': idPaciente});
  static Future<void> removerCartao(int id) =>
      ApiService.delete('/api/cartoes/$id');
}
