import '../../models/medico_models.dart';
import 'package:farmagrid/widgets/carregamento.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../services/medico_service.dart';
import 'medico_visual.dart';

class TelaDetalhesPaciente extends StatefulWidget {
  final int idPaciente;
  final String nome, cpfMascarado, fotoPerfil;
  const TelaDetalhesPaciente({
    super.key,
    required this.idPaciente,
    required this.nome,
    required this.cpfMascarado,
    required this.fotoPerfil,
  });
  @override
  State<TelaDetalhesPaciente> createState() => _TelaDetalhesPacienteState();
}

class _TelaDetalhesPacienteState extends State<TelaDetalhesPaciente> {
  List<RegistroClinico> _registros = [];
  Map<String, dynamic> _perfilPaciente = {};
  bool _carregando = true;
  String? _erro;

  Uint8List? get _fotoPaciente {
    final foto = '${_perfilPaciente['fotoPerfil'] ?? widget.fotoPerfil}';
    if (foto.isEmpty) return null;
    try {
      return base64Decode(foto);
    } catch (_) {
      return null;
    }
  }

  String get _cpfPaciente {
    final cpf = '${_perfilPaciente['cpf'] ?? widget.cpfMascarado}';
    final digitos = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length != 11) {
      return cpf.isEmpty ? 'CPF não informado' : cpf;
    }
    return '${digitos.substring(0, 3)}.${digitos.substring(3, 6)}.${digitos.substring(6, 9)}-${digitos.substring(9)}';
  }

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
      final resultados = await Future.wait([
        MedicoService.listarProntuariosPaciente(widget.idPaciente),
        MedicoService.buscarPerfilPaciente(widget.idPaciente),
      ]);
      if (mounted) {
        setState(() {
          _registros = List<RegistroClinico>.from(
            (resultados[0] as List<Map<String, dynamic>>).map(
              (p) => RegistroClinico.fromJson(p),
            ),
          );
          _perfilPaciente = resultados[1] as Map<String, dynamic>;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoPaciente = _fotoPaciente;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          MedicoCabecalho(
            titulo: 'Prontuário',
            subtitulo: widget.nome,
            rodape: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withValues(alpha: .2),
                  backgroundImage: fotoPaciente == null
                      ? null
                      : MemoryImage(fotoPaciente),
                  child: fotoPaciente == null
                      ? const Icon(Icons.person_outline, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paciente',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      _cpfPaciente,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _conteudo()),
        ],
      ),
    );
  }

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
    final ultimo = _registros.isEmpty ? null : _registros.first;
    return RefreshIndicator(
      onRefresh: _carregar,
      color: medicoVerde,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 38),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MedicoTituloSecao(
                'Visão clínica',
                legenda: 'Últimas informações registradas',
              ),
              IconButton.filled(
                onPressed: () => _abrirFormulario(),
                style: IconButton.styleFrom(
                  backgroundColor: medicoVerde,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (ultimo == null)
            MedicoCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: medicoVerde.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.medical_information_outlined,
                      color: medicoVerdeEscuro,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Nenhum atendimento registrado',
                    style: TextStyle(
                      color: medicoTexto,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Adicione a primeira evolução clínica deste paciente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _abrirFormulario(),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo atendimento'),
                      style: _botaoPrimario(),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            _resumoClinico(ultimo),
            const SizedBox(height: 28),
            const MedicoTituloSecao(
              'Histórico de atendimentos',
              legenda: 'Evoluções clínicas salvas no banco',
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _registros.length,
              itemBuilder: (context, index) {
                return _registroCard(_registros[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _resumoClinico(RegistroClinico p) => MedicoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 43,
              decoration: BoxDecoration(
                color: medicoTeal,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textoSeguro(p.condicao, vazio: 'Atendimento clínico'),
                    style: const TextStyle(
                      color: medicoTexto,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${textoSeguro(p.ultimaVisita, vazio: 'Data não informada')}  •  CID ${textoSeguro(p.cid10, vazio: 'não informado')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _vital('PA', p.pa, Icons.favorite_border)),
            const SizedBox(width: 8),
            Expanded(
              child: _vital(
                'Temperatura',
                p.temperatura,
                Icons.thermostat_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _vital('SpO₂', p.spo2, Icons.air)),
          ],
        ),
      ],
    ),
  );

  Widget _vital(String label, dynamic value, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
    decoration: BoxDecoration(
      color: medicoFundo,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        Icon(icon, size: 18, color: medicoVerdeEscuro),
        const SizedBox(height: 6),
        Text(
          textoSeguro(value, vazio: '—'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: medicoTexto,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 9),
        ),
      ],
    ),
  );

  Widget _registroCard(RegistroClinico p) => MedicoCard(
    margin: const EdgeInsets.only(bottom: 14),
    padding: EdgeInsets.zero,
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(18, 8, 10, 8),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        leading: Container(
          width: 5,
          height: 43,
          decoration: BoxDecoration(
            color: medicoTeal,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(
          textoSeguro(p.condicao, vazio: 'Atendimento clínico'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: medicoTexto,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${textoSeguro(p.ultimaVisita, vazio: 'Sem data')}  •  CID ${textoSeguro(p.cid10, vazio: '—')}',
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: medicoVerde),
          tooltip: 'Editar registro',
          onPressed: () => _abrirFormulario(p.toJson()),
        ),
        children: [
          _secaoRegistro('Anamnese', p.anamnese, Icons.chat_bubble_outline),
          _secaoRegistro(
            'Exame físico',
            p.exameFisico,
            Icons.health_and_safety_outlined,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _vital('PA', p.pa, Icons.favorite_border)),
              const SizedBox(width: 7),
              Expanded(
                child: _vital(
                  'Temp.',
                  p.temperatura,
                  Icons.thermostat_outlined,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _vital('Peso', p.peso, Icons.monitor_weight_outlined),
              ),
              const SizedBox(width: 7),
              Expanded(child: _vital('SpO₂', p.spo2, Icons.air)),
            ],
          ),
          const SizedBox(height: 14),
          _secaoRegistro('Conduta', p.conduta, Icons.task_alt_outlined),
          if (textoSeguro(p.dataRetorno, vazio: '').isNotEmpty)
            _secaoRegistro(
              'Retorno',
              p.dataRetorno,
              Icons.event_repeat_outlined,
            ),
          if (textoSeguro(p.notas, vazio: '').isNotEmpty)
            _secaoRegistro('Observações', p.notas, Icons.notes_outlined),
        ],
      ),
    ),
  );

  Widget _secaoRegistro(String titulo, dynamic valor, IconData icone) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: medicoVerdeEscuro, size: 19),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: medicoTexto,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    textoSeguro(valor),
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Future<void> _abrirFormulario([Map<String, dynamic>? atual]) async {
    TextEditingController c(String campo) =>
        TextEditingController(text: '${atual?[campo] ?? ''}');
    final controllers = <String, TextEditingController>{
      for (final campo in [
        'condicao',
        'cid10',
        'anamnese',
        'exameFisico',
        'pa',
        'temperatura',
        'peso',
        'spo2',
        'conduta',
        'dataRetorno',
        'notas',
      ])
        campo: c(campo),
    };
    final salvar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: medicoFundo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .9,
          maxChildSize: .96,
          minChildSize: .6,
          builder: (_, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: medicoVerde.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.medical_information_outlined,
                      color: medicoVerdeEscuro,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atual == null
                              ? 'Novo atendimento'
                              : 'Editar atendimento',
                          style: const TextStyle(
                            color: medicoTexto,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.nome,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _grupoFormulario('Dados clínicos', Icons.description_outlined, [
                _campo(controllers['condicao']!, 'Diagnóstico ou condição'),
                _campo(controllers['cid10']!, 'CID-10'),
                _campo(controllers['anamnese']!, 'Anamnese', linhas: 4),
                _campo(controllers['exameFisico']!, 'Exame físico', linhas: 4),
              ]),
              const SizedBox(height: 15),
              _grupoFormulario('Sinais vitais', Icons.monitor_heart_outlined, [
                const Text(
                  'Preencha somente os valores medidos neste atendimento.',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _campo(controllers['pa']!, 'Pressão arterial'),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _campo(
                        controllers['temperatura']!,
                        'Temperatura °C',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _campo(controllers['peso']!, 'Peso kg')),
                    const SizedBox(width: 9),
                    Expanded(child: _campo(controllers['spo2']!, 'SpO₂ %')),
                  ],
                ),
              ]),
              const SizedBox(height: 15),
              _grupoFormulario('Plano de cuidado', Icons.task_alt_outlined, [
                _campo(controllers['conduta']!, 'Conduta', linhas: 4),
                _campo(
                  controllers['dataRetorno']!,
                  'Data de retorno (AAAA-MM-DD)',
                ),
                _campo(
                  controllers['notas']!,
                  'Observações adicionais',
                  linhas: 3,
                ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, true),
                  icon: const Icon(Icons.check),
                  label: const Text('Salvar no prontuário'),
                  style: _botaoPrimario(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (salvar != true) {
      for (final c in controllers.values) {
        c.dispose();
      }
      return;
    }
    final dados = <String, dynamic>{
      'idPaciente': widget.idPaciente,
      'nomePaciente': widget.nome,
      for (final e in controllers.entries) e.key: e.value.text.trim(),
      'ultimaVisita': textoSeguro(
        atual?['ultimaVisita'],
        vazio: DateTime.now().toIso8601String().substring(0, 10),
      ),
      'status': textoSeguro(atual?['status'], vazio: 'Ativo'),
      'tipo': textoSeguro(atual?['tipo'], vazio: 'Consulta'),
    };
    try {
      if (atual == null) {
        await MedicoService.salvarProntuario(dados);
      } else {
        await MedicoService.editarProntuario(
          (atual['id'] as num).toInt(),
          dados,
        );
      }
      await _carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prontuário salvo com sucesso.'),
            backgroundColor: medicoVerde,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Não foi possível salvar: $e')));
      }
    } finally {
      for (final c in controllers.values) {
        c.dispose();
      }
    }
  }

  Widget _grupoFormulario(String titulo, IconData icone, List<Widget> filhos) =>
      MedicoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: medicoVerdeEscuro, size: 21),
                const SizedBox(width: 9),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: medicoTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...filhos,
          ],
        ),
      );

  Widget _campo(
    TextEditingController controller,
    String label, {
    int linhas = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: TextField(
      controller: controller,
      maxLines: linhas,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: linhas > 1,
        filled: true,
        fillColor: medicoFundo,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: medicoVerde, width: 1.5),
        ),
      ),
    ),
  );

  ButtonStyle _botaoPrimario() => ElevatedButton.styleFrom(
    backgroundColor: medicoVerde,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );
}
