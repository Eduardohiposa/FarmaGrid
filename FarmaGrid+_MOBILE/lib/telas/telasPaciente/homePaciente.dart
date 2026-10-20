import 'package:farmagrid/telas/telasPaciente/descontos.dart';
import 'package:farmagrid/telas/telasPaciente/exames.dart';
import 'package:farmagrid/telas/telasPaciente/farmaciasprox.dart';
import 'package:farmagrid/telas/telasPaciente/menuPaciente.dart';
import 'package:flutter/material.dart';
import 'receitas_prontuarios.dart';
import 'teleconsultas.dart';
import 'lojamedicamentos.dart';
import '../../models/medico_models.dart';
import '../../models/paciente_models.dart';
import '../../services/paciente_service.dart';
import '../../services/perfil_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class TelaHomePaciente extends StatefulWidget {
  @override
  _TelaHomePacienteState createState() => _TelaHomePacienteState();
}

class _TelaHomePacienteState extends State<TelaHomePaciente> {
  final Color corVerdePrimario = const Color(0xFF59AA53);
  final Color corVerdeOliva = const Color(0xFF136A48);
  final Color corTealBotao = const Color(0xFF7FC6BB);

  PacientePerfil? _perfil;
  ConsultaMedica? _proximaConsulta;

  @override
  void initState() {
    super.initState();
    _carregarResumo();
  }

  Future<void> _carregarResumo() async {
    try {
      final resultados = await Future.wait([
        PacienteService.buscarPerfil(),
        PacienteService.listarConsultas(),
        PerfilService.carregar(atualizar: true),
      ]);
      final consultas = resultados[1] as List<ConsultaMedica>;
      if (mounted)
        setState(() {
          _perfil = resultados[0] as PacientePerfil;
          _proximaConsulta = consultas.isEmpty ? null : consultas.first;
        });
    } catch (_) {
      // Os atalhos continuam disponíveis mesmo se o resumo não carregar.
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color get corFundo => const Color.fromARGB(255, 245, 245, 245);
  Color get corCard => Colors.white;
  Color get corTexto => const Color(0xFF2E2E2E);

  Future<void> _abrirPerfil() async {
    try {
      await PerfilService.carregar();
    } catch (_) {}
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DrawerPaciente(
        corVerde: corVerdePrimario,
        corOliva: corVerdeOliva,
        corTeal: corTealBotao,
        corCard: corCard,
        corTexto: corTexto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _construirCabecalho(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    "O que você precisa hoje?",
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _construirGridMenu(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCabecalho() {
    Uint8List? foto;
    try {
      if ((_perfil?.fotoPerfil ?? '').isNotEmpty)
        foto = base64Decode(_perfil!.fotoPerfil);
    } catch (_) {}
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 260,
          padding: const EdgeInsets.only(top: 60, left: 25, right: 25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF59AA53),
                const Color(0xFF89C6B1).withValues(alpha: 1.0),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _abrirPerfil,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: foto == null ? null : MemoryImage(foto),
                  child: foto == null
                      ? const Icon(
                          Icons.person,
                          size: 35,
                          color: Color(0xFF59AA53),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Olá,",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    _perfil?.nome ?? "Paciente",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 30,
          left: 25,
          right: 25,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: corCard,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: corVerdePrimario.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam_outlined,
                    color: corVerdeOliva,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _proximaConsulta == null ? "Agenda" : "Sua teleconsulta",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      _proximaConsulta == null
                          ? "Nenhuma consulta agendada"
                          : "${_proximaConsulta!.tipo.isEmpty ? 'Consulta' : _proximaConsulta!.tipo} - ${_proximaConsulta!.horario}",
                      style: TextStyle(
                        color: corVerdeOliva,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirGridMenu() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.95,
      children: [
        _itemMenu(
          "Receitas e Prontuários",
          Icons.history_edu_outlined,
          corVerdePrimario,
        ),
        _itemMenu("Teleconsultas", Icons.videocam_outlined, corVerdeOliva),
        _itemMenu(
          "Comprar Medicamentos",
          Icons.shopping_cart_outlined,
          corTealBotao,
        ),
        _itemMenu(
          "Farmácias Próximas",
          Icons.location_on_outlined,
          corVerdePrimario,
        ),
        _itemMenu("Descontos", Icons.sell_outlined, corVerdeOliva),
        _itemMenu(
          "Meus Exames",
          Icons.assignment_turned_in_outlined,
          corTealBotao,
        ),
      ],
    );
  }

  Widget _itemMenu(String titulo, IconData icone, Color cor) {
    return GestureDetector(
      onTap: () {
        if (titulo == "Receitas e Prontuários")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TelaReceitasProntuarios()),
          );
        else if (titulo == "Teleconsultas")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Teleconsultas()),
          );
        else if (titulo == "Comprar Medicamentos")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TelaMedicamentos()),
          );
        else if (titulo == "Descontos")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TelaDescontos()),
          );
        else if (titulo == "Farmácias Próximas")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TelaFarmaciasProximas()),
          );
        else if (titulo == "Meus Exames")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TelaExames()),
          );
      },
      child: Container(
        decoration: BoxDecoration(
          color: corCard,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icone, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: corTexto,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
