import '../widgets/carregamento.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../models/usuario_logado.dart';

class TipoLogin {
  static const int medico = 1;
  static const int paciente = 3;
}

class ApiException implements Exception {
  final String mensagem;

  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class AuthService {
  // esse pacote guarda o token protegido no aparelho pra pessoa nao precisar entrar toda hora
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _chaveSessao = 'sessao_usuario';

  static UsuarioLogado? usuarioLogado;

  static Future<UsuarioLogado> login(
    String email,
    String senha,
    int tipo,
  ) async {
    return Carregamento.executar('Entrando...', () async {
      try {
        final resposta = await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'senha': senha, 'tipo': tipo}),
            )
            .timeout(const Duration(seconds: 30));

        if (resposta.statusCode != 200) {
          throw ApiException(_extrairMensagemErro(resposta));
        }

        final dynamic json = jsonDecode(resposta.body);

        if (json is! Map<String, dynamic>) {
          throw ApiException('Resposta inválida recebida do servidor.');
        }

        final usuario = UsuarioLogado.fromJson(json);

        usuarioLogado = usuario;

        await _storage.write(
          key: _chaveSessao,
          value: jsonEncode(usuario.toJson()),
        );

        return usuario;
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException(
          'Não foi possível conectar ao servidor. Verifique se a API está em execução em ${ApiConfig.baseUrl}.',
        );
      }
    });
  }

  static Future<void> cadastrarPaciente({
    required String email,
    required String senha,
    required String nome,
    required String cpf,
    required String dataNascimento,
    required String sexo,
    required String rua,
    required int? numCasa,
    required String bairro,
    required String cidade,
    required String estado,
    required String telefone,
    required String cep,
    required String tipoSanguineo,
    required String contatoEmergenciaNome,
    required String contatoEmergenciaTelefone,
  }) async {
    await _post('/auth/cadastro/paciente', {
      'email': email,
      'senha': senha,
      'nome': nome,
      'cpf': cpf.replaceAll(RegExp(r'[^0-9]'), ''),
      'dataNascimento': dataNascimento,
      'sexo': sexo,
      'rua': rua,
      'numCasa': numCasa,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'telefone': telefone,
      'cep': cep,
      'tipoSanguineo': tipoSanguineo,
      'contatoEmergenciaNome': contatoEmergenciaNome,
      'contatoEmergenciaTelefone': contatoEmergenciaTelefone,
    });
  }

  static Future<void> cadastrarMedico({
    required String email,
    required String senha,
    required String nome,
    required String crm,
    required String especialidade,
    required String clinica,
    required String enderecoClinica,
    required String telefone,
    required String endereco,
    required String dataNascimento,
    required String rqe,
    required String subespecialidades,
    required String horarioInicio,
    required String horarioTermino,
    required String tempoConsulta,
    required String valorConsulta,
    required String tipoAtendimento,
  }) async {
    await _post('/auth/cadastro/medico', {
      'email': email,
      'senha': senha,
      'nome': nome,
      'crm': crm,
      'especialidade': especialidade,
      'clinica': clinica,
      'enderecoClinica': enderecoClinica,
      'telefone': telefone,
      'endereco': endereco,
      'dataNascimento': dataNascimento,
      'rqe': rqe,
      'subespecialidades': subespecialidades,
      'horarioInicio': horarioInicio,
      'horarioTermino': horarioTermino,
      'tempoConsulta': tempoConsulta,
      'valorConsulta': valorConsulta,
      'tipoAtendimento': tipoAtendimento,
    });
  }

  static Future<void> _post(String path, Map<String, dynamic> body) async {
    return Carregamento.executar('Criando sua conta...', () async {
      try {
        final resposta = await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}$path'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));

        if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
          throw ApiException(_extrairMensagemErro(resposta));
        }
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException(
          'Não foi possível conectar ao servidor. Verifique se a API está em execução em ${ApiConfig.baseUrl}.',
        );
      }
    });
  }

  static Future<bool> restaurarSessao() async {
    try {
      final salvo = await _storage.read(key: _chaveSessao);

      if (salvo == null) {
        usuarioLogado = null;
        return false;
      }

      final dynamic json = jsonDecode(salvo);

      if (json is! Map<String, dynamic>) {
        throw Exception('Sessão inválida');
      }

      usuarioLogado = UsuarioLogado.fromJson(json);

      return true;
    } catch (_) {
      try {
        await _storage.delete(key: _chaveSessao);
      } catch (_) {
        // se essa plataforma nao aceitar o armazenamento seguro, o app continua sem restaurar a sessao
      }

      usuarioLogado = null;

      return false;
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: _chaveSessao);

    usuarioLogado = null;
  }

  static String _extrairMensagemErro(http.Response resposta) {
    try {
      final dynamic corpo = jsonDecode(resposta.body);

      if (corpo is Map) {
        final campoMensagem =
            corpo['message'] ??
            corpo['mensagem'] ??
            corpo['error'] ??
            corpo['erro'];
        if (campoMensagem != null) {
          return campoMensagem.toString();
        }
      }

      if (corpo is String && corpo.trim().isNotEmpty) {
        return corpo;
      }

      return resposta.body.isNotEmpty
          ? resposta.body
          : 'Erro inesperado ao conectar com o servidor.';
    } catch (_) {
      if (resposta.body.isNotEmpty) {
        return resposta.body;
      }

      return 'Erro inesperado ao conectar com o servidor.';
    }
  }
}
