import 'api_service.dart';
import '../models/medico_models.dart';
import 'auth_service.dart';

class MedicoService {
  static int get _idMedico {
    final id = AuthService.usuarioLogado?.idMedico;
    if (id == null) {
      throw ApiException('Sessão médica inválida. Faça login novamente.');
    }
    return id;
  }

  static Future<List<ConsultaMedica>> listarAgenda() async {
    final json = await _get('/api/teleconsultas/medico/$_idMedico');
    return _lista(json).map(ConsultaMedica.fromJson).toList();
  }

  static Future<List<PacienteMedico>> listarPacientes() async {
    final json = await _get('/api/medicos/$_idMedico/pacientes');
    return _lista(json).map(PacienteMedico.fromJson).toList();
  }

  static Future<Map<String, dynamic>> buscarPerfilPaciente(
    int idPaciente,
  ) async {
    final json = await _get('/api/pacientes/$idPaciente/config');
    return json is Map ? Map<String, dynamic>.from(json) : {};
  }

  static Future<Map<String, dynamic>> buscarPainel() async {
    final json = await _get('/api/medicos/$_idMedico/painel');
    return json is Map ? Map<String, dynamic>.from(json) : {};
  }

  static Future<List<Map<String, dynamic>>> listarProntuariosPaciente(
    int idPaciente,
  ) async => _lista(await _get('/api/prontuarios/paciente/$idPaciente'));

  static Future<Map<String, dynamic>> salvarProntuario(
    Map<String, dynamic> dados,
  ) async {
    final json = await _send('POST', '/api/prontuarios', {
      ...dados,
      'idMedico': _idMedico,
    });
    return json is Map ? Map<String, dynamic>.from(json) : {};
  }

  static Future<Map<String, dynamic>> editarProntuario(
    int id,
    Map<String, dynamic> dados,
  ) async {
    final json = await _send('PUT', '/api/prontuarios/$id', {
      ...dados,
      'idMedico': _idMedico,
    });
    return json is Map ? Map<String, dynamic>.from(json) : {};
  }

  static Future<ReceitaMedica> criarReceita(ReceitaMedica receita) async {
    final json = await _send('POST', '/api/receitas', receita.toJson());
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return ReceitaMedica(
      id: _int(map['id']),
      idMedico: receita.idMedico,
      idPaciente: receita.idPaciente,
      medicamento: receita.medicamento,
      concentracao: receita.concentracao,
      dosagem: receita.dosagem,
      frequencia: receita.frequencia,
      duracao: receita.duracao,
      viaAdministracao: receita.viaAdministracao,
      instrucoes: receita.instrucoes,
      observacoes: receita.observacoes,
      dataPrescricao: '${map['dataPrescricao'] ?? receita.dataPrescricao}',
      status: '${map['status'] ?? receita.status}',
    );
  }

  static ReceitaMedica novaReceita({
    required int idPaciente,
    required String medicamento,
    required String dosagem,
    required String duracao,
    String instrucoes = '',
    String observacoes = '',
  }) => ReceitaMedica(
    idMedico: _idMedico,
    idPaciente: idPaciente,
    medicamento: medicamento,
    dosagem: dosagem,
    duracao: duracao,
    instrucoes: instrucoes,
    observacoes: observacoes,
  );

  static Future<dynamic> _get(String path) =>
      ApiService.requisitar('GET', path);
  static Future<dynamic> _send(
    String method,
    String path,
    Map<String, dynamic> body,
  ) => ApiService.requisitar(method, path, body: body);

  static List<Map<String, dynamic>> _lista(dynamic json) =>
      (json as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
