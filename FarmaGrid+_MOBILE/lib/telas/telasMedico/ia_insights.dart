import 'package:farmagrid/widgets/carregamento.dart';
import 'package:flutter/material.dart';
import '../../services/medico_service.dart';
import 'medico_visual.dart';

class TelaIndicadoresClinicos extends StatefulWidget {
  const TelaIndicadoresClinicos({super.key});
  @override
  State<TelaIndicadoresClinicos> createState() =>
      _TelaIndicadoresClinicosState();
}

class _TelaIndicadoresClinicosState extends State<TelaIndicadoresClinicos> {
  Map<String, dynamic>? _painel;
  String? _erro;

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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: Column(
      children: [
        const MedicoCabecalho(
          titulo: 'Indicadores clínicos',
          subtitulo: 'Estatísticas dos atendimentos registrados',
        ),
        Expanded(child: _conteudo()),
      ],
    ),
  );

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
    final diagnosticos = Map<String, dynamic>.from(
      _painel?['diagnosticos'] ?? const {},
    );
    final ordenados = diagnosticos.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    final maior = ordenados.isEmpty
        ? 1.0
        : (ordenados.first.value as num).toDouble();
    final registros = diagnosticos.values.fold<num>(
      0,
      (s, v) => s + (v as num),
    );

    final diagnosticosVisiveis = ordenados.take(5).toList();
    return RefreshIndicator(
      onRefresh: _carregar,
      color: medicoVerde,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 36),
        children: [
          const MedicoTituloSecao(
            'Visão geral',
            legenda:
                'Indicadores calculados com os dados registrados no sistema',
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _metrica(
                  '${_painel!['totalPacientes'] ?? 0}',
                  'Pacientes',
                  Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metrica(
                  '${_painel!['consultasMes'] ?? 0}',
                  'Consultas no mês',
                  Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metrica(
                  '${_painel!['receitasMes'] ?? 0}',
                  'Receitas no mês',
                  Icons.description_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metrica(
                  '$registros',
                  'Registros clínicos',
                  Icons.monitor_heart_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const MedicoTituloSecao(
            'Diagnósticos recorrentes',
            legenda: 'Frequência encontrada nos prontuários dos seus pacientes',
          ),
          const SizedBox(height: 15),
          MedicoCard(
            child: ordenados.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Ainda não há diagnósticos registrados para gerar esta leitura.',
                      style: TextStyle(color: Colors.grey, height: 1.4),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: diagnosticosVisiveis.length,
                    itemBuilder: (context, index) {
                      final e = diagnosticosVisiveis[index];
                      final quantidade = (e.value as num).toDouble();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 17),
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
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      color: medicoTexto,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${e.value} registro${quantidade == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    color: medicoVerdeEscuro,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: quantidade / maior,
                                minHeight: 7,
                                backgroundColor: medicoFundo,
                                color: medicoVerde,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_outlined, color: medicoVerdeEscuro),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Origem confiável',
                        style: TextStyle(
                          color: medicoVerdeEscuro,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Os indicadores usam apenas consultas e prontuários vinculados ao seu login. Eles apoiam a leitura da rotina, mas não substituem avaliação clínica.',
                        style: TextStyle(color: Color(0xFF557068), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metrica(String valor, String label, IconData icon) => MedicoCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: medicoVerde.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: medicoVerdeEscuro, size: 22),
        ),
        const SizedBox(height: 12),
        Text(
          valor,
          style: const TextStyle(
            color: medicoTexto,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    ),
  );
}
