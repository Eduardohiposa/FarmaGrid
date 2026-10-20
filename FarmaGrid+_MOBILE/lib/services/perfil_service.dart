import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'auth_service.dart';

// centraliza o carregamento e a atualizacao dos dados de perfil
class PerfilService {
  static final ValueNotifier<Map<String, dynamic>?> atual = ValueNotifier(null);
  static int? _loginCarregado;

  static bool get isMedico =>
      AuthService.usuarioLogado?.tipo == TipoLogin.medico;
  static int get idEntidade => isMedico
      ? AuthService.usuarioLogado!.idMedico!
      : AuthService.usuarioLogado!.idPaciente!;

  static Future<Map<String, dynamic>> carregar({bool atualizar = false}) async {
    final loginAtual = AuthService.usuarioLogado?.id;
    if (_loginCarregado != loginAtual) {
      atual.value = null;
      _loginCarregado = loginAtual;
    }
    if (!atualizar && atual.value != null) return atual.value!;
    final caminho = isMedico
        ? '/api/medicos/$idEntidade/config'
        : '/api/pacientes/$idEntidade/config';
    final perfil = await ApiService.getMap(caminho);
    if (isMedico) {
      // busco os dados relacionados juntos pra evitar varias esperas em sequencia
      final listas = await Future.wait([
        ApiService.getList('/api/medicos/$idEntidade/pacientes'),
        ApiService.getList('/api/teleconsultas/medico/$idEntidade'),
        ApiService.getList('/api/receitas/medico/$idEntidade'),
      ]);
      perfil['totalPacientes'] = listas[0].length;
      perfil['totalConsultas'] = listas[1].length;
      perfil['totalReceitas'] = listas[2].length;
    } else {
      
      final listas = await Future.wait([
        ApiService.getList('/api/teleconsultas/paciente/$idEntidade'),
        ApiService.getList('/api/relatorios/paciente/$idEntidade'),
        ApiService.getList('/api/receitas/paciente/$idEntidade'),
      ]);
      perfil['totalConsultas'] = listas[0].length;
      perfil['totalExames'] = listas[1].length;
      perfil['totalReceitas'] = listas[2].length;
    }
    atual.value = perfil;
    return perfil;
  }

  static Future<void> salvarPerfil(Map<String, dynamic> dados) async {
    final caminho = isMedico
        ? '/api/medicos/$idEntidade'
        : '/api/pacientes/$idEntidade/config';
    await ApiService.put(caminho, dados);
    await carregar(atualizar: true);
  }

  static Future<void> salvarProfissional(Map<String, dynamic> dados) async {
    await ApiService.put('/api/medicos/$idEntidade/profissional', dados);
    await carregar(atualizar: true);
  }

  static Future<void> salvarFoto(Uint8List bytes) async {
    if (bytes.length > 5 * 1024 * 1024) {
      throw ApiException('A foto deve ter no máximo 5 MB.');
    }
    final caminho = isMedico
        ? '/api/medicos/$idEntidade/foto'
        : '/api/pacientes/$idEntidade/foto';
    // a api recebe a foto como texto, por isso converto os bytes pra base64
    await ApiService.put(caminho, {'foto': base64Encode(bytes)});
    await carregar(atualizar: true);
  }

  static Future<void> alterarSenha(String atual, String nova) => ApiService.put(
    '/api/logins/${AuthService.usuarioLogado!.id}/senha',
    {'senhaAtual': atual, 'novaSenha': nova},
  );

  static Uint8List? foto(Map<String, dynamic>? perfil) {
    final valor = perfil?['fotoPerfil'];
    if (valor is! String || valor.isEmpty) return null;
    try {
      return base64Decode(valor);
    } catch (_) {
      return null;
    }
  }

  static String nome(Map<String, dynamic>? perfil) {
    final nome = '${perfil?['nome'] ?? ''}'.trim();
    final sobrenome = '${perfil?['sobrenome'] ?? ''}'.trim();
    return [nome, sobrenome].where((v) => v.isNotEmpty).join(' ');
  }

  static void limpar() {
    atual.value = null;
    _loginCarregado = null;
  }
}
