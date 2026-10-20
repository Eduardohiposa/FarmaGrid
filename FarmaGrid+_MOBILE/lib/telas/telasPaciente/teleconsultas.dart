import '../../models/medico_models.dart';
import 'package:farmagrid/widgets/carregamento.dart';
import 'package:flutter/material.dart';
import '../../services/paciente_service.dart';
import 'paciente_visual.dart';
import '../../util/formatador_data.dart';

class Teleconsultas extends StatefulWidget {
  const Teleconsultas({super.key});
  @override
  State<Teleconsultas> createState() => _TeleconsultasState();
}

class _TeleconsultasState extends State<Teleconsultas> {
  List<ConsultaMedica> _consultas = [];
  List<Map<String, dynamic>> _medicos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      // busca consultas e medicos ao mesmo tempo porque uma consulta nao depende da outra
      final dados = await Future.wait([
        PacienteService.listarConsultas(),
        PacienteService.listarMedicos(),
      ]);
      if (!mounted) return;
      setState(() {
        _consultas = dados[0] as List<ConsultaMedica>;
        _medicos = dados[1] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      if (mounted) setState(() => _erro = '$e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Map<String, dynamic>? _medico(dynamic id) {
    for (final medico in _medicos) {
      if ('${medico['id']}' == '$id') return medico;
    }
    return null;
  }

  String _nomeMedico(dynamic id) {
    final medico = _medico(id);
    if (medico == null) return 'Médico';
    final nome = '${medico['nome'] ?? ''}'.trim();
    final sobrenome = '${medico['sobrenome'] ?? ''}'.trim();
    final completo =
        sobrenome.isEmpty ||
            nome.toLowerCase().endsWith(sobrenome.toLowerCase())
        ? nome
        : '$nome $sobrenome';
    return 'Dr(a). $completo';
  }

  bool _agendada(ConsultaMedica c) {
    final status = '${c.status}'.toLowerCase();
    return !status.contains('cancel') && !status.contains('conclu');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: Column(
      children: [
        PacienteCabecalho(
          titulo: 'Teleconsultas',
          subtitulo: 'Cuide da sua saúde de onde estiver',
          rodape: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _medicos.isEmpty ? null : _agendar,
              icon: const Icon(Icons.add, size: 19),
              label: const Text('Agendar teleconsulta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: pacienteVerdeEscuro,
                disabledBackgroundColor: Colors.white54,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        Expanded(child: _conteudo()),
      ],
    ),
  );

  Widget _conteudo() {
    if (_carregando) {
      return const CartaoCarregamento();
    }
    if (_erro != null) {
      return Center(
        child: TextButton.icon(
          onPressed: _carregar,
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar. Tentar novamente'),
        ),
      );
    }
    final agendadas = _consultas.where(_agendada).toList();
    final anteriores = _consultas.where((c) => !_agendada(c)).toList();
    return RefreshIndicator(
      onRefresh: _carregar,
      color: pacienteVerde,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 38),
        children: [
          const PacienteTituloSecao(
            'Próximos atendimentos',
            legenda: 'Consultas online vinculadas ao seu cadastro',
          ),
          const SizedBox(height: 15),
          if (agendadas.isEmpty)
            PacienteCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: pacienteVerde.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.videocam_outlined,
                      color: pacienteVerdeEscuro,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhuma teleconsulta agendada',
                    style: TextStyle(
                      color: pacienteTexto,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Escolha um médico, uma data e um horário para começar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: agendadas.length,
              itemBuilder: (context, index) {
                return _cardConsulta(agendadas[index], destaque: index == 0);
              },
            ),
          if (anteriores.isNotEmpty) ...[
            const SizedBox(height: 27),
            const PacienteTituloSecao('Histórico'),
            const SizedBox(height: 15),
            ListView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: anteriores.length,
              itemBuilder: (context, index) {
                return _cardConsulta(anteriores[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardConsulta(ConsultaMedica c, {bool destaque = false}) {
    final medico = _medico(c.idMedico);
    final especialidade = '${medico?['especialidade'] ?? 'Atendimento médico'}';
    final status = '${c.status}';
    return PacienteCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: pacienteVerde.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.videocam_outlined,
                  color: pacienteVerdeEscuro,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nomeMedico(c.idMedico),
                      style: const TextStyle(
                        color: pacienteTexto,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      especialidade,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _agendada(c)
                      ? pacienteVerde.withValues(alpha: .1)
                      : Colors.grey.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _agendada(c) ? pacienteVerdeEscuro : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 5,
                height: 35,
                decoration: BoxDecoration(
                  color: pacienteTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 11),
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 6),
              Text(
                formatarDataBrasileira('${c.data}'),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.access_time_outlined,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 5),
              Text(
                '${c.horario}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          if (destaque) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'A sala será liberada no horário da consulta.',
                    ),
                  ),
                ),
                icon: const Icon(Icons.videocam_outlined, size: 18),
                label: const Text('Entrar na consulta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pacienteVerde,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _agendar() async {
    if (_medicos.isEmpty) return;
    Map<String, dynamic>? medico = _medicos.first;
    DateTime data = DateTime.now().add(const Duration(days: 1));
    String hora = '09:00';
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: pacienteFundo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            14,
            24,
            MediaQuery.viewInsetsOf(ctx).bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Agendar teleconsulta',
                  style: TextStyle(
                    color: pacienteTexto,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Escolha o profissional e o melhor horário.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),
                PacienteCard(
                  child: Column(
                    children: [
                      DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: medico,
                        decoration: _decoracao('Médico', Icons.person_outline),
                        items: _medicos
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  '${m['nome']} • ${m['especialidade'] ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setLocal(() => medico = v),
                      ),
                      const SizedBox(height: 13),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: data,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 180),
                            ),
                          );
                          if (d != null) setLocal(() => data = d);
                        },
                        child: InputDecorator(
                          decoration: _decoracao(
                            'Data',
                            Icons.calendar_month_outlined,
                          ),
                          child: Text(
                            '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      DropdownButtonFormField<String>(
                        initialValue: hora,
                        decoration: _decoracao(
                          'Horário',
                          Icons.access_time_outlined,
                        ),
                        items:
                            [
                                  '08:00',
                                  '09:00',
                                  '10:00',
                                  '11:00',
                                  '14:00',
                                  '15:00',
                                  '16:00',
                                  '17:00',
                                ]
                                .map(
                                  (h) => DropdownMenuItem(
                                    value: h,
                                    child: Text(h),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => hora = v ?? hora,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar agendamento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pacienteVerde,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok != true || medico == null) return;
    final iso =
        '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    try {
      await PacienteService.agendarTeleconsulta({
        'idMedico': medico!['id'],
        'data': iso,
        'horario': hora,
        'status': 'Agendada',
        'duracao': '30 min',
        'tipo': 'Teleconsulta',
      });
      await _carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teleconsulta agendada com sucesso.'),
            backgroundColor: pacienteVerde,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Não foi possível agendar: $e')));
      }
    }
  }

  InputDecoration _decoracao(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: pacienteVerdeEscuro),
    filled: true,
    fillColor: pacienteFundo,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: pacienteVerde, width: 1.5),
    ),
  );
}
