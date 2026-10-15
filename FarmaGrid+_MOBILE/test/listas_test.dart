import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:farmagrid/models/usuario_logado.dart';
import 'package:farmagrid/services/auth_service.dart';
import 'package:farmagrid/telas/telasPaciente/lojamedicamentos.dart';
import 'package:farmagrid/telas/telasPaciente/farmaciasprox.dart';
import 'package:farmagrid/widgets/carregamento.dart';

void main() {
  setUp(() {
    AuthService.usuarioLogado = UsuarioLogado.fromJson({
      'id': 1,
      'tipo': 3,
      'idPaciente': 1,
    });
  });
  tearDown(() => AuthService.usuarioLogado = null);

  Widget app(Widget tela) => MaterialApp(
    builder: (context, child) => CamadaCarregamento(child: child!),
    home: tela,
  );

  testWidgets(
    'farmácias exibem objetos e status desconhecido sem marcar fechada',
    (tester) async {
      await http.runWithClient(
        () async {
          await tester.pumpWidget(app(const TelaFarmaciasProximas()));
          await tester.pumpAndSettle();
          expect(find.text('Farmácia Teste'), findsOneWidget);
          expect(find.text('Horário não informado'), findsOneWidget);
          expect(find.text('Fechada agora'), findsNothing);
          expect(find.byType(ListView), findsWidgets);
          expect(tester.takeException(), isNull);
        },
        () => MockClient(
          (_) async => http.Response(
            jsonEncode([
              {
                'id': 'osm-node-1',
                'nome': 'Farmácia Teste',
                'endereco': 'Centro',
                'aberto': null,
                'fonte': 'OpenStreetMap',
                'distanciaMetros': 550,
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
    },
  );

  testWidgets(
    'loja apresenta erro e permite tentar novamente sem estoque fictício',
    (tester) async {
      var chamadas = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(app(const TelaMedicamentos()));
          await tester.pumpAndSettle();
          expect(
            find.text('Não foi possível carregar. Tentar novamente'),
            findsOneWidget,
          );
          expect(find.text('Paracetamol 750mg'), findsNothing);
          await tester.tap(
            find.text('Não foi possível carregar. Tentar novamente'),
          );
          await tester.pumpAndSettle();
          expect(chamadas, 2);
          expect(find.text('Medicamento real'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        () => MockClient((_) async {
          chamadas++;
          return http.Response(
            chamadas == 1
                ? '{"message":"Indisponível"}'
                : jsonEncode([
                    {
                      'id': 8,
                      'nome': 'Medicamento real',
                      'categoria': 'Genérico',
                      'preco': 12.5,
                      'quantidade': 8,
                      'tarjaPreta': false,
                    },
                  ]),
            chamadas == 1 ? 503 : 200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
    },
  );
}
