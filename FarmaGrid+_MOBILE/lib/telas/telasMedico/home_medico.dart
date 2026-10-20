import 'package:farmagrid/telas/login.dart';
import 'package:flutter/material.dart';
import 'agenda_medico.dart';
import 'ia_insights.dart';
import 'prescrever_receita.dart';
import 'prontuarios.dart';
import 'relatorios.dart';
import 'parcerias.dart';
import 'configuracoesMedico.dart';
import 'package:farmagrid/telas/sobreNos.dart';
import '../../services/perfil_service.dart';
import '../../services/auth_service.dart';
import '../../services/medico_service.dart';
import '../../models/medico_models.dart';
import 'menuMedico.dart';

class TelaHomeMedico extends StatefulWidget {
  const TelaHomeMedico({super.key});

  @override
  _TelaHomeMedicoState createState() => _TelaHomeMedicoState();
}

class _TelaHomeMedicoState extends State<TelaHomeMedico> {
  final Color corVerdePrimario = const Color(0xFF59AA53);
  final Color corVerdeOliva = const Color(0xFF136A48);
  final Color corTealBotao = const Color(0xFF7FC6BB);

  Map<String, dynamic>? _perfil;
  List<ConsultaMedica> _consultasHoje = [];

  @override
  void initState() {
    super.initState();
    PerfilService.carregar(atualizar: true)
        .then((p) {
          if (mounted) setState(() => _perfil = p);
        })
        .catchError((Object erro) {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Não foi possível carregar o perfil: $erro'),
              ),
            );
        });
    MedicoService.listarAgenda()
        .then((lista) {
          final hoje = DateTime.now();
          final iso =
              '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';
          if (mounted) {
            setState(
              () => _consultasHoje = lista.where((c) => c.data == iso).toList(),
            );
          }
        })
        .catchError((_) {});
  }

  Color get corFundo => const Color.fromARGB(255, 245, 245, 245);
  Color get corCard => Colors.white;
  Color get corTexto => const Color(0xFF2E2E2E);

  void _abrirPerfil() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DrawerMedico(
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
                    "Agenda de Hoje",
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_consultasHoje.isEmpty)
                    const Text(
                      'Nenhuma consulta marcada para hoje.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _consultasHoje.length,
                      itemBuilder: (context, index) {
                        return _construirCardAgenda(
                          _consultasHoje[index].nomePaciente.isEmpty
                              ? 'Paciente'
                              : _consultasHoje[index].nomePaciente,
                          _consultasHoje[index].horario,
                          _consultasHoje[index].tipo.isEmpty
                              ? 'Consulta'
                              : _consultasHoje[index].tipo,
                          index == 0,
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                  Text(
                    "Ferramentas",
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _construirGridFerramentas(),
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
                  backgroundImage: PerfilService.foto(_perfil) == null
                      ? null
                      : MemoryImage(PerfilService.foto(_perfil)!),
                  child: PerfilService.foto(_perfil) == null
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
                    "Bem-vindo(a),",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    "Dr(a). ${PerfilService.nome(_perfil).isEmpty ? 'Médico' : PerfilService.nome(_perfil)}",
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
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: corVerdePrimario.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: corVerdeOliva,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Consultas hoje",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          Text(
                            "${_consultasHoje.length} agendada${_consultasHoje.length == 1 ? '' : 's'}",
                            style: TextStyle(
                              color: corVerdeOliva,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.grey.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: corTealBotao.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          color: corVerdeOliva,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Pacientes",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          Text(
                            "${_perfil?['totalPacientes'] ?? 0} cadastrado${(_perfil?['totalPacientes'] ?? 0) == 1 ? '' : 's'}",
                            style: TextStyle(
                              color: corVerdeOliva,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirCardAgenda(
    String nome,
    String hora,
    String tipo,
    bool iniciar,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 44,
            decoration: BoxDecoration(
              color: corTealBotao,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: corTexto,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tipo,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: corTealBotao.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hora,
                  style: TextStyle(
                    color: corVerdeOliva,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (iniciar) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: corVerdePrimario,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Iniciar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirGridFerramentas() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.95,
      children: [
        _itemFerramenta(
          "Agenda",
          Icons.calendar_today_outlined,
          corVerdePrimario,
        ),
        _itemFerramenta(
          "Apoio clínico",
          Icons.psychology_outlined,
          corVerdeOliva,
        ),
        _itemFerramenta("Prescrever", Icons.history_edu_outlined, corTealBotao),
        _itemFerramenta(
          "Prontuários",
          Icons.assignment_outlined,
          corVerdePrimario,
        ),
        _itemFerramenta("Relatórios", Icons.bar_chart_outlined, corVerdeOliva),
        _itemFerramenta("Parcerias", Icons.handshake_outlined, corTealBotao),
      ],
    );
  }

  Widget _itemFerramenta(String titulo, IconData icone, Color cor) {
    return GestureDetector(
      onTap: () {
        if (titulo == "Agenda")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaAgendaMedico()),
          );
        else if (titulo == "Apoio clínico")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaIndicadoresClinicos()),
          );
        else if (titulo == "Prescrever")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaPrescreverReceita()),
          );
        else if (titulo == "Prontuários")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaProntuarios()),
          );
        else if (titulo == "Relatórios")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaRelatorios()),
          );
        else if (titulo == "Parcerias")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaParcerias()),
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

class _DrawerMedico extends StatefulWidget {
  final Color corVerde, corOliva, corTeal, corCard, corTexto;

  const _DrawerMedico({
    required this.corVerde,
    required this.corOliva,
    required this.corTeal,
    required this.corCard,
    required this.corTexto,
  });

  @override
  State<_DrawerMedico> createState() => _DrawerMedicoState();
}

class _DrawerMedicoState extends State<_DrawerMedico> {
  void _irParaAba(int aba) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TelaConfiguracoesMedico(abaInicial: aba),
      ),
    );
  }

  void _irParaTela(Widget tela) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  void _dialogo(String titulo, String corpo) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(corpo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const subColor = Colors.grey;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: widget.corVerde.withValues(alpha: 0.15),
                    child: Icon(Icons.person, size: 50, color: widget.corVerde),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Dr(a). ${PerfilService.nome(PerfilService.atual.value).isEmpty ? 'Médico' : PerfilService.nome(PerfilService.atual.value)}",
                    style: TextStyle(
                      color: widget.corTexto,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ana.lanzoni@farmagrid.com",
                    style: TextStyle(color: subColor, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _badge("CRM/SP 123456", widget.corVerde, widget.corOliva),
                      const SizedBox(width: 8),
                      _badge(
                        "CRM Ativo",
                        Colors.green.shade100,
                        Colors.green.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.corVerde.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.corVerde.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dados Profissionais",
                    style: TextStyle(
                      color: widget.corOliva,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dadoProfissional(
                    Icons.badge_outlined,
                    "CRM",
                    "CRM/SP 123456",
                  ),
                  const SizedBox(height: 10),
                  _dadoProfissional(
                    Icons.local_hospital_outlined,
                    "Especialidade",
                    "Clínica Geral",
                  ),
                  const SizedBox(height: 10),
                  _dadoProfissional(
                    Icons.school_outlined,
                    "Formação",
                    "USP – Medicina 2012",
                  ),
                  const SizedBox(height: 10),
                  _dadoProfissional(
                    Icons.work_outline,
                    "Experiência",
                    "12 anos",
                  ),
                  const SizedBox(height: 10),
                  _dadoProfissional(
                    Icons.location_on_outlined,
                    "Consultório",
                    "Av. Paulista, 1000 - SP",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    "150",
                    "Pacientes",
                    Icons.people_outline,
                    widget.corVerde,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoCard(
                    "8",
                    "Hoje",
                    Icons.calendar_today_outlined,
                    widget.corTeal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoCard(
                    "4.9",
                    "Nota",
                    Icons.star_outline,
                    widget.corOliva,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _secao("Conta", subColor),
            _item(
              Icons.person_outline,
              "Meu Perfil",
              "Editar dados pessoais",
              widget.corVerde,
              () => _irParaAba(0),
            ),
            _item(
              Icons.work_outline,
              "Informações Profissionais",
              "Registro, especialidades e clínica",
              widget.corVerde,
              () => _irParaAba(1),
            ),
            _item(
              Icons.shield_outlined,
              "Segurança",
              "Alterar senha de acesso",
              widget.corVerde,
              () => _irParaAba(2),
            ),
            const SizedBox(height: 20),
            _secao("Preferências", subColor),

            _item(
              Icons.privacy_tip_outlined,
              "Privacidade",
              "Dados e permissões",
              widget.corVerde,
              () => _irParaAba(2),
            ),
            const SizedBox(height: 20),
            _secao("Suporte", subColor),
            _item(
              Icons.info_outline,
              "Sobre Nós",
              "Conheça a equipe",
              widget.corVerde,
              () => _irParaTela(const TelaSobreNos()),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                await AuthService.logout();
                PerfilService.limpar();
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => TelaLogin()),
                  (_) => false,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Sair da conta",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _badge(String texto, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texto,
      style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );

  Widget _dadoProfissional(
    IconData icone,
    String label,
    String valor,
  ) => Row(
    children: [
      Icon(icone, size: 18, color: corVerdePrimario),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              color: const Color(0xFF2E2E2E),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _secao(String titulo, Color cor) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      titulo,
      style: TextStyle(
        color: cor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _infoCard(
    String valor,
    String label,
    IconData icone,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: cor.withValues(alpha: 0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icone,
    String titulo,
    String sub,
    Color cor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, color: cor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: const Color(0xFF2E2E2E),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemSwitch(
    IconData icone,
    String titulo,
    String sub,
    Color cor,
    bool valor,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: const Color(0xFF2E2E2E),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                color: valor ? cor : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: valor ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
