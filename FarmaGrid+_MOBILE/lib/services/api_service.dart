import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../widgets/carregamento.dart';
import 'auth_service.dart';

class ApiService {
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if ((AuthService.usuarioLogado?.token ?? '').isNotEmpty)
      'Authorization': 'Bearer ${AuthService.usuarioLogado!.token}',
  };

  static Future<List<Map<String, dynamic>>> getList(String path) async {
    final value = await requisitar('GET', path);
    if (value is! List || value.any((item) => item is! Map)) {
      throw ApiException(
        'O servidor retornou uma lista inválida. Tente novamente.',
      );
    }
    return List<Map<String, dynamic>>.from(
      value.map((item) => Map<String, dynamic>.from(item as Map)),
    );
  }

  static Future<Map<String, dynamic>> getMap(String path) async =>
      _map(await requisitar('GET', path));

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async => _map(await requisitar('POST', path, body: body));
  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async => _map(await requisitar('PUT', path, body: body));
  static Future<void> delete(String path) async {
    await requisitar('DELETE', path);
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static String _mensagem(String method, String path) {
    if (method == 'GET') {
      return path.contains('farmacias-proximas')
          ? 'Buscando farmácias...'
          : 'Carregando...';
    }
    if (method == 'DELETE') return 'Removendo...';
    if (path.contains('resgatar')) return 'Resgatando cupom...';
    if (path.contains('/senha')) return 'Atualizando senha...';
    if (path.contains('/foto')) return 'Atualizando foto...';
    if (path.contains('/assinatura')) return 'Atualizando plano...';
    if (path.contains('/teleconsultas')) return 'Agendando consulta...';
    if (path.contains('/solicitacoes-exame')) return 'Enviando solicitação...';
    if (path.contains('/receitas')) return 'Gerando receita...';
    return 'Salvando...';
  }

  static Future<dynamic> requisitar(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) => Carregamento.executar(_mensagem(method, path), () async {
    final client = http.Client();
    try {
      final request = http.Request(
        method,
        Uri.parse('${ApiConfig.baseUrl}$path'),
      )..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final response = await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(
            Duration(seconds: path.contains('farmacias-proximas') ? 100 : 30),
          );
      final texto = utf8.decode(response.bodyBytes);
      dynamic value;
      try {
        value = texto.isEmpty ? null : jsonDecode(texto);
      } on FormatException {
        value = texto;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          value is Map
              ? '${value['message'] ?? value['mensagem'] ?? value['error'] ?? 'Erro HTTP ${response.statusCode}'}'
              : '${value ?? 'Erro HTTP ${response.statusCode}'}',
        );
      }
      return value;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'A operação demorou mais que o esperado. Tente novamente.',
      );
    } catch (_) {
      throw ApiException(
        'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.',
      );
    } finally {
      client.close();
    }
  });
}
