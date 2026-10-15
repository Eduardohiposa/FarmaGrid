import 'package:farmagrid/widgets/carregamento.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'detalhes_paciente.dart';
import '../../models/medico_models.dart';
import '../../services/medico_service.dart';

class TelaProntuarios extends StatefulWidget {
  const TelaProntuarios({super.key});

  @override
  State<TelaProntuarios> createState() => _TelaProntuariosState();
}

class _TelaProntuariosState extends State<TelaProntuarios> {
  final Color corVerdePrimario = const Color(0xFF59AA53);
  final Color corVerdeOliva = const Color(0xFF136A48);
  final Color corTealBotao = const Color(0xFF7FC6BB);
  Color get corFundoSite => const Color(0xFFF5F5F5);
  Color get corCard => Colors.white;
  Color get corTexto => const Color(0xFF2E2E2E);
  Color get corCampo => Colors.white;

  final _buscaController = TextEditingController();

  List<PacienteMedico> _pacientes = const [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() => setState(() {}));
    _carregarPacientes();
  }

  Future<void> _carregarPacientes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final pacientes = await MedicoService.listarPacientes();
      if (mounted) setState(() => _pacientes = pacientes);
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<PacienteMedico> get _pacientesFiltrados {
    final busca = _buscaController.text.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9á-ú]'),
      '',
    );
    if (busca.isEmpty) return _pacientes;
    return _pacientes.where((p) {
      final nome = p.nome.toLowerCase().replaceAll(RegExp(r'[^a-z0-9á-ú]'), '');
      final cpf = p.cpf.replaceAll(RegExp(r'[^0-9]'), '');
      return nome.contains(busca) || cpf.contains(busca);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoSite,
      body: Column(
        children: [
          _construirCabecalho(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Meus Pacientes",
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (_carregando)
                    const CartaoCarregamento()
                  else if (_erro != null)
                    Center(
                      child: TextButton(
                        onPressed: _carregarPacientes,
                        child: Text('$_erro\nTentar novamente'),
                      ),
                    )
                  else if (_pacientesFiltrados.isEmpty)
                    Center(
                      child: Text(
                        'Nenhum paciente encontrado.',
                        style: TextStyle(color: corTexto),
                      ),
                    )
                  else
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pacientesFiltrados.length,
                      itemBuilder: (context, index) {
                        return _construirCardPaciente(
                          context,
                          _pacientesFiltrados[index],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCabecalho(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 25),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "Prontuários",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              hintText: "Buscar paciente pro nome ou CPF",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              filled: true,
              fillColor: corCampo,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCardPaciente(BuildContext context, PacienteMedico p) {
    Uint8List? foto;
    if (p.fotoPerfil.isNotEmpty) {
      try {
        foto = base64Decode(p.fotoPerfil);
      } catch (_) {}
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: corTealBotao.withValues(alpha: 0.2),
                backgroundImage: foto == null ? null : MemoryImage(foto),
                child: foto == null
                    ? Icon(Icons.person_outline, color: corVerdeOliva, size: 26)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nomeComIdade,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: corTexto,
                      ),
                    ),
                    Text(
                      p.cpfFormatado,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaDetalhesPaciente(
                        idPaciente: p.id,
                        nome: p.nomeComIdade,
                        cpfMascarado: p.cpfFormatado,
                        fotoPerfil: p.fotoPerfil,
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.remove_red_eye_outlined,
                  color: corVerdePrimario,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: p.condicoes
                .map(
                  (c) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: corVerdePrimario.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        color: corVerdeOliva,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statBox('${p.totalConsultas}', "Consultas"),
              const SizedBox(width: 10),
              _statBox('${p.totalReceitas}', "Receitas"),
              const SizedBox(width: 10),
              _statBox(p.ultimaVisita.isEmpty ? '—' : p.ultimaVisita, "Última"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String valor, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: corFundoSite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: corVerdePrimario.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                color: corVerdePrimario,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }
}
