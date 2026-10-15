import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:farmagrid/main.dart';
import 'package:farmagrid/telas/recuperar_senha.dart';
import 'package:farmagrid/services/recuperacao_senha_service.dart';
import 'package:farmagrid/services/auth_service.dart';
import 'package:farmagrid/widgets/carregamento.dart';

void main() {
  Future<void> tocar(WidgetTester tester, String texto) async {
    final alvo = find.text(texto).last;
    await tester.ensureVisible(alvo);
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'login recupera em três etapas com os mesmos contratos do desktop',
    (tester) async {
      final pedidos = <http.Request>[];
      await http.runWithClient(
        () async {
          await tester.pumpWidget(MyApp(restaurarSessao: () async => false));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.widgetWithText(TextFormField, 'E-mail'),
            'Pessoa@example.com',
          );
          await tocar(tester, 'Esqueceu sua senha?');
          expect(find.text('Etapa 1 de 3 · E-mail'), findsOneWidget);
          await tocar(tester, 'Enviar código');
          expect(find.text('Etapa 2 de 3 · Código'), findsOneWidget);
          expect(find.byIcon(Icons.numbers), findsNothing);
          final reenvio = tester.widget<TextButton>(
            find.widgetWithText(TextButton, 'Reenviar código em 60s'),
          );
          expect(reenvio.onPressed, isNull);
          await tester.enterText(
            find.byKey(const ValueKey('codigo-0')),
            '123456',
          );
          await tocar(tester, 'Validar código');
          expect(find.text('Etapa 3 de 3 · Nova senha'), findsOneWidget);
          await tester.enterText(
            find.byKey(const ValueKey('nova-senha')),
            'senhaNova123',
          );
          await tester.enterText(
            find.byKey(const ValueKey('confirmar-senha')),
            'diferente',
          );
          await tocar(tester, 'Redefinir senha');
          expect(find.text('As senhas não coincidem.'), findsOneWidget);
          expect(pedidos.length, 2);
          await tester.enterText(
            find.byKey(const ValueKey('confirmar-senha')),
            'senhaNova123',
          );
          await tocar(tester, 'Redefinir senha');
          expect(find.text('Senha redefinida com sucesso!'), findsOneWidget);
          expect(pedidos.map((r) => r.url.path), [
            '/auth/recuperacao/solicitar',
            '/auth/recuperacao/validar-codigo',
            '/auth/recuperacao/redefinir',
          ]);
          expect(jsonDecode(pedidos[0].body), {'email': 'pessoa@example.com'});
          expect(jsonDecode(pedidos[1].body), {
            'email': 'pessoa@example.com',
            'codigo': '123456',
          });
          expect(jsonDecode(pedidos[2].body), {
            'email': 'pessoa@example.com',
            'codigo': '123456',
            'novaSenha': 'senhaNova123',
          });
          await tocar(tester, 'Voltar ao login');
          expect(find.text('Entrar'), findsOneWidget);
          expect(find.text('pessoa@example.com'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        () => MockClient((request) async {
          pedidos.add(request);
          return http.Response('{"sucesso":true}', 200);
        }),
      );
    },
  );

  testWidgets(
    'erro do código mantém etapa e permite corrigir em tela estreita',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => CamadaCarregamento(child: child!),
              home: const TelaRecuperarSenha(
                emailInicial: 'pessoa@example.com',
              ),
            ),
          );
          await tocar(tester, 'Enviar código');
          await tester.enterText(
            find.byKey(const ValueKey('codigo-0')),
            '111111',
          );
          await tocar(tester, 'Validar código');
          expect(find.text('Código inválido ou expirado.'), findsOneWidget);
          expect(find.text('Etapa 2 de 3 · Código'), findsOneWidget);
          expect(Carregamento.instancia.ativo, isFalse);
          await tocar(tester, 'Alterar e-mail');
          expect(find.text('Etapa 1 de 3 · E-mail'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
        () => MockClient(
          (request) async => request.url.path.endsWith('validar-codigo')
              ? http.Response(
                  '{"message":"Código inválido ou expirado."}',
                  400,
                  headers: {'content-type': 'application/json; charset=utf-8'},
                )
              : http.Response('{"sucesso":true}', 200),
        ),
      );
    },
  );

  test(
    'resposta sem sucesso não é aceita como confirmação do código',
    () async {
      await http.runWithClient(
        () async {
          await expectLater(
            RecuperacaoSenhaService.validarCodigo(
              'pessoa@example.com',
              '123456',
            ),
            throwsA(isA<ApiException>()),
          );
          expect(Carregamento.instancia.ativo, isFalse);
        },
        () => MockClient(
          (_) async =>
              http.Response('{"sucesso":false,"erro":"Código inválido"}', 200),
        ),
      );
    },
  );
}
