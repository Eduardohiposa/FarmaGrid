import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmagrid/widgets/carregamento.dart';

void main() {
  test('encerra somente depois da última operação, mesmo com erro', () async {
    final primeira = Completer<void>();
    final segunda = Completer<void>();
    final a = Carregamento.executar('Carregando...', () => primeira.future);
    final b = Carregamento.executar('Salvando...', () => segunda.future);
    expect(Carregamento.instancia.ativo, isTrue);
    primeira.complete();
    await a;
    expect(Carregamento.instancia.ativo, isTrue);
    final erro = expectLater(b, throwsStateError);
    segunda.completeError(StateError('falha de rede'));
    await erro;
    expect(Carregamento.instancia.ativo, isFalse);
  });

  testWidgets('desfoca, bloqueia toques e libera a tela ao terminar', (
    tester,
  ) async {
    var toques = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => CamadaCarregamento(child: child!),
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => toques++,
              child: const Text('Salvar'),
            ),
          ),
        ),
      ),
    );
    final pendente = Completer<void>();
    final operacao = Carregamento.executar(
      'Salvando...',
      () => pendente.future,
    );
    await tester.pump();
    expect(find.text('Salvando...'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    await tester.tap(find.text('Salvar'), warnIfMissed: false);
    expect(toques, 0);
    pendente.complete();
    await operacao;
    await tester.pump();
    expect(find.text('Salvando...'), findsNothing);
    await tester.tap(find.text('Salvar'));
    expect(toques, 1);
    expect(tester.takeException(), isNull);
  });
}
