import 'package:farmagrid/widgets/carregamento.dart';
import 'package:flutter/material.dart';
import '../../services/medico_service.dart';
import 'medico_visual.dart';

class TelaRelatorios extends StatefulWidget {
  const TelaRelatorios({super.key});
  @override
  State<TelaRelatorios> createState() => _TelaRelatoriosState();
}

class _TelaRelatoriosState extends State<TelaRelatorios> {
  Map<String, dynamic>? _painel;
  String? _erro;
  static const _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _erro = null);
    try {
      final painel = await MedicoService.buscarPainel();
      if (mounted) setState(() => _painel = painel);
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final periodo = '${_meses[agora.month - 1]} ${agora.year}';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          MedicoCabecalho(
            titulo: 'Relatório mensal',
            subtitulo: 'Desempenho consolidado do período',
            rodape: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      periodo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _conteudo()),
        ],
      ),
    );
  }

  Widget _conteudo() {
    if (_erro != null) {
      return Center(
        child: TextButton.icon(
          onPressed: _carregar,
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar. Tentar novamente'),
        ),
      );
    }
    if (_painel == null) {
      return const CartaoCarregamento();
    }
    final tipos = Map<String, dynamic>.from(
      _painel?['tiposConsulta'] ?? const {},
    );
    final totalTipos = tipos.values.fold<num>(0, (s, v) => s + (v as num));
    final tiposVisiveis = tipos.entries.toList();
    return RefreshIndicator(
      onRefresh: _carregar,
      color: medicoVerde,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 36),
        children: [
          const MedicoTituloSecao('Resumo do mês'),
          const SizedBox(height: 15),
          MedicoCard(
            child: Row(
              children: [
                Expanded(
                  child: _resumo(
                    '${_painel!['consultasMes'] ?? 0}',
                    'Consultas',
                    Icons.event_available_outlined,
                  ),
                ),
                Container(width: 1, height: 62, color: const Color(0xFFE8E8E8)),
                Expanded(
                  child: _resumo(
                    '${_painel!['receitasMes'] ?? 0}',
                    'Receitas',
                    Icons.description_outlined,
                  ),
                ),
                Container(width: 1, height: 62, color: const Color(0xFFE8E8E8)),
                Expanded(
                  child: _resumo(
                    '${_painel!['totalPacientes'] ?? 0}',
                    'Pacientes',
                    Icons.people_outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const MedicoTituloSecao(
            'Perfil dos atendimentos',
            legenda: 'Distribuição das consultas registradas por modalidade',
          ),
          const SizedBox(height: 15),
          MedicoCard(
            child: tipos.isEmpty
                ? const Text(
                    'Nenhuma consulta registrada neste período.',
                    style: TextStyle(color: Colors.grey),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tiposVisiveis.length,
                    itemBuilder: (context, index) {
                      final e = tiposVisiveis[index];
                      final qtd = e.value as num;
                      final percentual = totalTipos == 0
                          ? 0.0
                          : qtd / totalTipos;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: medicoTeal,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: medicoTexto,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$qtd',
                                  style: const TextStyle(
                                    color: medicoVerdeEscuro,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(percentual * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentual,
                                minHeight: 8,
                                color: medicoVerde,
                                backgroundColor: medicoFundo,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 18),
          const MedicoCard(
            color: Color(0xFFEAF5EF),
            child: Row(
              children: [
                Icon(Icons.storage_outlined, color: medicoVerdeEscuro),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Relatório atualizado com consultas, receitas e prontuários vinculados ao médico autenticado.',
                    style: TextStyle(color: Color(0xFF557068), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumo(String valor, String titulo, IconData icone) => Column(
    children: [
      Icon(icone, color: medicoVerdeEscuro, size: 22),
      const SizedBox(height: 8),
      Text(
        valor,
        style: const TextStyle(
          color: medicoTexto,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
    ],
  );
}
