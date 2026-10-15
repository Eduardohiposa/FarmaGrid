import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class Carregamento extends ChangeNotifier {
  static final instancia = Carregamento();
  final Map<Object, String> _operacoes = {};
  bool get ativo => _operacoes.isNotEmpty;
  String get mensagem => ativo ? _operacoes.values.last : 'Carregando...';
  void _atualizar() => scheduleMicrotask(notifyListeners);
  static Future<T> executar<T>(
    String mensagem,
    Future<T> Function() acao,
  ) async {
    final chave = Object();
    instancia._operacoes[chave] = mensagem;
    instancia._atualizar();
    try {
      return await acao();
    } finally {
      instancia._operacoes.remove(chave);
      instancia._atualizar();
    }
  }
}

class CartaoCarregamento extends StatelessWidget {
  const CartaoCarregamento({super.key, this.mensagem = 'Carregando...'});
  final String mensagem;
  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      label: mensagem,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDCE6DE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x203C6549),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Color(0xFF386642),
                backgroundColor: Color(0xFFDCEADF),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF386642),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CamadaCarregamento extends StatelessWidget {
  const CamadaCarregamento({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Carregamento.instancia,
    builder: (context, _) {
      final controle = Carregamento.instancia;
      return PopScope(
        canPop: !controle.ativo,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              excluding: controle.ativo,
              child: ExcludeFocus(excluding: controle.ativo, child: child),
            ),
            if (controle.ativo) ...[
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: const ModalBarrier(
                    dismissible: false,
                    color: Color(0xBFFFFFFF),
                  ),
                ),
              ),
              Positioned.fill(
                child: CartaoCarregamento(mensagem: controle.mensagem),
              ),
            ],
          ],
        ),
      );
    },
  );
}
