import 'api_service.dart';
import 'auth_service.dart';

/// Usa a mesma API do desktop. Credenciais Brevo ficam somente no servidor.
class RecuperacaoSenhaService {
  static Future<void> _enviar(String acao, Map<String, dynamic> dados) async {
    final resposta = await ApiService.post('/auth/recuperacao/$acao', dados);
    if (resposta['sucesso'] != true) {
      throw ApiException(
        (resposta['message'] ??
                resposta['erro'] ??
                'Não foi possível concluir a recuperação. Tente novamente.')
            .toString(),
      );
    }
  }

  static Future<void> solicitar(String email) =>
      _enviar('solicitar', {'email': email.trim().toLowerCase()});
  static Future<void> validarCodigo(String email, String codigo) => _enviar(
    'validar-codigo',
    {'email': email.trim().toLowerCase(), 'codigo': codigo},
  );
  static Future<void> redefinir(
    String email,
    String codigo,
    String novaSenha,
  ) => _enviar('redefinir', {
    'email': email.trim().toLowerCase(),
    'codigo': codigo,
    'novaSenha': novaSenha,
  });
}
