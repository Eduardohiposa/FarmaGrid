import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/recuperacao_senha_service.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key, this.emailInicial = ''});
  final String emailInicial;
  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  static const _verde = Color(0xFF4BA94B);
  static const _escuro = Color(0xFF355E3B);
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  final _digitos = List.generate(6, (_) => TextEditingController());
  final _focos = List.generate(6, (_) => FocusNode());
  int _etapa = 0;
  bool _ocupado = false, _verSenha = false, _verConfirmacao = false;
  String? _erro;
  String _emailSolicitado = '', _codigoValidado = '';
  Timer? _timer;
  DateTime? _liberarReenvio;
  int _segundos = 0;

  @override
  void initState() {
    super.initState();
    _email.text = widget.emailInicial;
  }

  void _limparCodigo() {
    for (final d in _digitos) {
      d.clear();
    }
    _codigoValidado = '';
  }

  // conta o tempo ate liberar o reenvio do codigo sem travar a tela
  void _iniciarIntervalo() {
    _timer?.cancel();
    _liberarReenvio = DateTime.now().add(const Duration(seconds: 60));
    _segundos = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final restante = _liberarReenvio!
          .difference(DateTime.now())
          .inMilliseconds;
      setState(() => _segundos = restante > 0 ? (restante / 1000).ceil() : 0);
      if (_segundos == 0) timer.cancel();
    });
  }

  Future<void> _continuar({bool reenviar = false}) async {
    if (_ocupado || (reenviar && _segundos > 0)) return;
    FocusScope.of(context).unfocus();
    setState(() => _erro = null);
    final etapa = _etapa;
    if (etapa == 0 &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim())) {
      setState(() => _erro = 'Informe um e-mail válido.');
      return;
    }
    final codigo = _digitos.map((d) => d.text).join();
    if (etapa == 1 && !reenviar && !RegExp(r'^\d{6}$').hasMatch(codigo)) {
      setState(() => _erro = 'Preencha os seis números do código.');
      return;
    }
    if (etapa == 2) {
      if (_senha.text.length < 6 || utf8.encode(_senha.text).length > 72) {
        setState(
          () => _erro =
              'Use uma senha de pelo menos 6 caracteres e até 72 bytes.',
        );
        return;
      }
      if (_senha.text != _confirmacao.text) {
        setState(() => _erro = 'As senhas não coincidem.');
        return;
      }
    }
    setState(() => _ocupado = true);
    try {
      if (etapa == 0 || reenviar) {
        final email = reenviar
            ? _emailSolicitado
            : _email.text.trim().toLowerCase();
        await RecuperacaoSenhaService.solicitar(email);
        if (!mounted) return;
        setState(() {
          _emailSolicitado = email;
          _limparCodigo();
          _etapa = 1;
          _iniciarIntervalo();
        });
        _focos.first.requestFocus();
        if (reenviar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Se o e-mail estiver cadastrado, você receberá um novo código.',
              ),
            ),
          );
        }
      } else if (etapa == 1) {
        await RecuperacaoSenhaService.validarCodigo(_emailSolicitado, codigo);
        if (!mounted) return;
        setState(() {
          _codigoValidado = codigo;
          _etapa = 2;
        });
      } else {
        await RecuperacaoSenhaService.redefinir(
          _emailSolicitado,
          _codigoValidado,
          _senha.text,
        );
        if (!mounted) return;
        _senha.clear();
        _confirmacao.clear();
        _limparCodigo();
        _timer?.cancel();
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          // desabilita o voltar enquanto essa etapa precisa ser concluida
          builder: (ctx) => PopScope(
            canPop: false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              icon: const Icon(
                Icons.check_circle_outline,
                color: _verde,
                size: 48,
              ),
              title: const Text('Senha redefinida com sucesso!'),
              content: const Text('Você já pode fazer login com a nova senha.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Voltar ao login'),
                ),
              ],
            ),
          ),
        );
        if (!mounted) return;
        Navigator.pop(context, _emailSolicitado);
      }
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro.toString();
        if (etapa == 2) {
          _senha.clear();
          _confirmacao.clear();
          _limparCodigo();
          _etapa = 1;
        }
      });
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _alterarEmail() {
    if (_ocupado) return;
    setState(() {
      _etapa = 0;
      _erro = null;
      _limparCodigo();
      _senha.clear();
      _confirmacao.clear();
    });
  }

  void _preencherCodigo(String texto, int indice) {
    final numeros = texto.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length > 1) {
      final inicio = numeros.length >= 6 ? 0 : indice;
      for (var i = inicio; i < 6; i++) {
        _digitos[i].text = i - inicio < numeros.length
            ? numeros[i - inicio]
            : '';
      }
      _focos[(inicio + numeros.length).clamp(0, 5)].requestFocus();
    } else if (numeros.isNotEmpty && indice < 5) {
      _focos[indice + 1].requestFocus();
    } else if (numeros.isEmpty && indice > 0) {
      _focos[indice - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_email, _senha, _confirmacao, ..._digitos]) {
      c.dispose();
    }
    for (final f in _focos) {
      f.dispose();
    }
    super.dispose();
  }

  InputDecoration _decoracao(String label, IconData? icon) => InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon, color: _escuro),
    filled: true,
    fillColor: const Color(0xFFF0F7F0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB9D8BB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB9D8BB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _verde, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const titulos = ['E-mail', 'Código', 'Nova senha'];
    const instrucoes = [
      'Informe o e-mail para o qual deseja redefinir sua senha.',
      'Digite o código que enviamos para você.',
      'Código confirmado! Escolha sua nova senha.',
    ];
    const botoes = ['Enviar código', 'Validar código', 'Redefinir senha'];
    // controla o voltar do aparelho durante o fluxo de recuperacao
    return PopScope(
      canPop: !_ocupado,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFCEE),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final largo = constraints.maxWidth >= 850;
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/senhaEsquecida.jpeg',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: largo ? .05 : .85),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            (constraints.maxHeight -
                                    MediaQuery.paddingOf(context).vertical -
                                    40)
                                .clamp(0, double.infinity),
                      ),
                      child: Align(
                        alignment: largo
                            ? Alignment.centerRight
                            : Alignment.center,
                        child: Container(
                          width: largo ? constraints.maxWidth * .46 : 480,
                          constraints: const BoxConstraints(maxWidth: 520),
                          padding: EdgeInsets.all(largo ? 30 : 22),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .96),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12355E3B),
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: AutofillGroup(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    tooltip: 'Voltar ao login',
                                    onPressed: _ocupado
                                        ? null
                                        : () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: _escuro,
                                    ),
                                  ),
                                ),
                                const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'FARMA',
                                        style: TextStyle(color: _escuro),
                                      ),
                                      TextSpan(
                                        text: 'GRID+',
                                        style: TextStyle(color: _verde),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Esqueceu sua senha?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF2E462E),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Não se preocupe. Nós podemos te ajudar!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF5C6C5C),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: List.generate(
                                    3,
                                    (index) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        child: Container(
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: index <= _etapa
                                                ? _verde
                                                : const Color(0xFFE1ECE2),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // descreve esse campo para leitores de tela
                                Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    'Etapa ${_etapa + 1} de 3 · ${titulos[_etapa]}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: _escuro,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  instrucoes[_etapa],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF5C6C5C),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (_etapa == 0)
                                  TextField(
                                    key: const ValueKey('email-recuperacao'),
                                    controller: _email,
                                    enabled: !_ocupado,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _continuar(),
                                    decoration: _decoracao(
                                      'E-mail',
                                      Icons.email_outlined,
                                    ),
                                  ),
                                if (_etapa == 1) ...[
                                  Text(
                                    'Se o e-mail $_emailSolicitado estiver cadastrado, você receberá um código.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF5C6C5C),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Código recebido por e-mail',
                                    style: TextStyle(
                                      color: _escuro,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: List.generate(
                                      6,
                                      (index) => Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: index == 5 ? 0 : 6,
                                          ),
                                          child: TextField(
                                            key: ValueKey('codigo-$index'),
                                            controller: _digitos[index],
                                            focusNode: _focos[index],
                                            enabled: !_ocupado,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                6,
                                              ),
                                            ],
                                            autofillHints: index == 0
                                                ? const [
                                                    AutofillHints.oneTimeCode,
                                                  ]
                                                : null,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: _escuro,
                                            ),
                                            decoration: _decoracao('', null)
                                                .copyWith(
                                                  labelText: null,
                                                  prefixIcon: null,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                ),
                                            onTap: () =>
                                                _digitos[index]
                                                    .selection = TextSelection(
                                                  baseOffset: 0,
                                                  extentOffset: _digitos[index]
                                                      .text
                                                      .length,
                                                ),
                                            onChanged: (value) =>
                                                _preencherCodigo(value, index),
                                            onSubmitted: (_) => _continuar(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'O código expira em 10 minutos. Confira também a pasta de spam.',
                                    style: TextStyle(
                                      color: Color(0xFF5C6C5C),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _ocupado || _segundos > 0
                                        ? null
                                        : () => _continuar(reenviar: true),
                                    child: Text(
                                      _segundos > 0
                                          ? 'Reenviar código em ${_segundos}s'
                                          : 'Solicitar outro código',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _ocupado ? null : _alterarEmail,
                                    child: const Text('Alterar e-mail'),
                                  ),
                                ],
                                if (_etapa == 2) ...[
                                  const Text(
                                    'Crie uma senha com pelo menos 6 caracteres.',
                                    style: TextStyle(color: Color(0xFF5C6C5C)),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    key: const ValueKey('nova-senha'),
                                    controller: _senha,
                                    enabled: !_ocupado,
                                    obscureText: !_verSenha,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    decoration:
                                        _decoracao(
                                          'Nova senha',
                                          Icons.lock_outline,
                                        ).copyWith(
                                          suffixIcon: IconButton(
                                            tooltip: _verSenha
                                                ? 'Ocultar senha'
                                                : 'Mostrar senha',
                                            onPressed: () => setState(
                                              () => _verSenha = !_verSenha,
                                            ),
                                            icon: Icon(
                                              _verSenha
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                            ),
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    key: const ValueKey('confirmar-senha'),
                                    controller: _confirmacao,
                                    enabled: !_ocupado,
                                    obscureText: !_verConfirmacao,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    onSubmitted: (_) => _continuar(),
                                    decoration:
                                        _decoracao(
                                          'Confirmar nova senha',
                                          Icons.lock_outline,
                                        ).copyWith(
                                          suffixIcon: IconButton(
                                            tooltip: _verConfirmacao
                                                ? 'Ocultar confirmação'
                                                : 'Mostrar confirmação',
                                            onPressed: () => setState(
                                              () => _verConfirmacao =
                                                  !_verConfirmacao,
                                            ),
                                            icon: Icon(
                                              _verConfirmacao
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                            ),
                                          ),
                                        ),
                                  ),
                                ],
                                if (_erro != null) ...[
                                  const SizedBox(height: 16),
                                  Semantics(
                                    liveRegion: true,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEEEE),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _erro!,
                                        style: const TextStyle(
                                          color: Color(0xFFA52D2D),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _verde,
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _ocupado ? null : _continuar,
                                  child: Text(
                                    botoes[_etapa],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _ocupado
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text(
                                    'Lembrou sua senha? Volte para o login!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: _escuro),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
