import 'widgets/carregamento.dart';
import 'package:farmagrid/telas/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/auth_service.dart';
import 'telas/telasMedico/home_medico.dart';
import 'telas/telasPaciente/homePaciente.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key, this.restaurarSessao});

  final Future<bool> Function()? restaurarSessao;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmaGrid+',
      theme: _criarTema(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) =>
          CamadaCarregamento(child: child ?? const SizedBox.shrink()),
      home: _TelaInicial(
        restaurarSessao: restaurarSessao ?? AuthService.restaurarSessao,
      ),
    );
  }

  ThemeData _criarTema() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF59AA53),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF9F9F9),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _TelaInicial extends StatefulWidget {
  const _TelaInicial({required this.restaurarSessao});

  final Future<bool> Function() restaurarSessao;

  @override
  State<_TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<_TelaInicial> {
  // esse futurebuilder espera a verificacao da sessao pra mandar direto pra tela certa
  late final Future<bool> _restauracao;

  @override
  void initState() {
    super.initState();
    _restauracao = widget.restaurarSessao();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _restauracao,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: CartaoCarregamento(mensagem: 'Preparando seu acesso...'),
          );
        }

        final usuario = AuthService.usuarioLogado;
        if (snapshot.data == true && usuario != null) {
          if (usuario.tipo == TipoLogin.paciente) {
            return TelaHomePaciente();
          }
          if (usuario.tipo == TipoLogin.medico) {
            return const TelaHomeMedico();
          }
        }

        return TelaLogin();
      },
    );
  }
}
