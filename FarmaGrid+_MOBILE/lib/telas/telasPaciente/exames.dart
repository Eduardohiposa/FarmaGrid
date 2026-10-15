import '../../models/paciente_models.dart';
import 'package:farmagrid/widgets/carregamento.dart';
import 'package:flutter/material.dart';
import '../../services/paciente_service.dart';
import 'paciente_visual.dart';

class TelaExames extends StatefulWidget {
  const TelaExames({super.key});
  @override
  State<TelaExames> createState() => _TelaExamesState();
}

class _TelaExamesState extends State<TelaExames> {
  List<ResultadoExame> _resultados = [];
  List<SolicitacaoExame> _solicitacoes = [];
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
      final dados = await Future.wait([
        PacienteService.listarExames(),
        PacienteService.listarSolicitacoesExame(),
      ]);
      if (mounted) {
        setState(() {
          _resultados = List<ResultadoExame>.from(
            dados[0].map((e) => ResultadoExame.fromJson(e)),
          );
          _solicitacoes = List<SolicitacaoExame>.from(
            dados[1].map((e) => SolicitacaoExame.fromJson(e)),
          );
        });
      }
    } catch (e) {
      if (mounted) setState(() => _erro = '$e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          PacienteCabecalho(
            titulo: 'Central de exames',
            subtitulo: 'Solicitações e resultados em um só lugar',
            rodape: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _solicitar,
                icon: const Icon(Icons.add, size: 19),
                label: const Text('Nova solicitação'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: pacienteVerdeEscuro,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: pacienteVerde,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(text: 'Solicitações (${_solicitacoes.length})'),
                  Tab(text: 'Resultados (${_resultados.length})'),
                ],
              ),
            ),
          ),
          Expanded(child: _corpo()),
        ],
      ),
    ),
  );

  Widget _corpo() {
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
    return TabBarView(children: [_listaSolicitacoes(), _listaResultados()]);
  }

  Widget _listaSolicitacoes() => RefreshIndicator(
    onRefresh: _carregar,
    color: pacienteVerde,
    child: _solicitacoes.isEmpty
        ? _vazio(
            Icons.assignment_outlined,
            'Nenhuma solicitação',
            'Envie um pedido e acompanhe o status por aqui.',
            acao: true,
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 38),
            children: [
              const PacienteTituloSecao(
                'Seus pedidos',
                legenda: 'Acompanhe o andamento das solicitações enviadas',
              ),
              const SizedBox(height: 15),
              ListView.builder(
                padding: EdgeInsets.zero,
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _solicitacoes.length,
                itemBuilder: (context, index) {
                  return _cardSolicitacao(_solicitacoes[index]);
                },
              ),
            ],
          ),
  );

  Widget _cardSolicitacao(SolicitacaoExame exame) {
    final status = '${exame.status ?? 'Solicitado'}';
    final statusNormalizado = status.toLowerCase();
    final concluido =
        statusNormalizado.contains('conclu') ||
        statusNormalizado.contains('dispon');
    final cor = concluido ? pacienteVerdeEscuro : const Color(0xFFB97827);
    final justificativa = '${exame.justificativa ?? ''}'.trim();
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
                  color: pacienteTeal.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.biotech_outlined,
                  color: pacienteVerdeEscuro,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${exame.exame ?? 'Exame'}',
                  style: const TextStyle(
                    color: pacienteTexto,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: cor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (justificativa.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: pacienteFundo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Motivo ou observações',
                    style: TextStyle(
                      color: pacienteTexto,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    justificativa,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 13),
          Row(
            children: [
              Container(
                width: 5,
                height: 28,
                decoration: BoxDecoration(
                  color: pacienteTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                'Solicitado em ${_texto(exame.solicitadoEm, vazio: 'data não informada')}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listaResultados() => RefreshIndicator(
    onRefresh: _carregar,
    color: pacienteVerde,
    child: _resultados.isEmpty
        ? _vazio(
            Icons.folder_open_outlined,
            'Nenhum resultado disponível',
            'Os laudos enviados pelo laboratório aparecerão aqui.',
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 38),
            children: [
              const PacienteTituloSecao(
                'Resultados disponíveis',
                legenda: 'Documentos armazenados no seu prontuário',
              ),
              const SizedBox(height: 15),
              ListView.builder(
                padding: EdgeInsets.zero,
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _resultados.length,
                itemBuilder: (context, index) {
                  return _cardResultado(_resultados[index]);
                },
              ),
            ],
          ),
  );

  Widget _cardResultado(ResultadoExame exame) => PacienteCard(
    margin: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      onTap: () => _detalharResultado(exame),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: pacienteVerde.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
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
                  '${exame.titulo ?? 'Exame'}',
                  style: const TextStyle(
                    color: pacienteTexto,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_texto(exame.tipo, vazio: 'Resultado')}  •  ${_texto(exame.data, vazio: 'Sem data')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: pacienteFundo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_right, color: pacienteVerdeEscuro),
          ),
        ],
      ),
    ),
  );

  Future<void> _solicitar() async {
    final exame = TextEditingController(), motivo = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: pacienteFundo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: pacienteVerde.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.biotech_outlined,
                      color: pacienteVerdeEscuro,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nova solicitação',
                          style: TextStyle(
                            color: pacienteTexto,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Informe o exame e o motivo do pedido.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
              const SizedBox(height: 20),
              PacienteCard(
                child: Column(
                  children: [
                    _campo(exame, 'Nome do exame', Icons.biotech_outlined),
                    const SizedBox(height: 13),
                    _campo(
                      motivo,
                      'Motivo ou observações',
                      Icons.notes_outlined,
                      linhas: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (exame.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Informe o nome do exame.'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Enviar solicitação'),
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
    );
    if (ok != true) {
      exame.dispose();
      motivo.dispose();
      return;
    }
    try {
      await PacienteService.solicitarExame(
        exame.text.trim(),
        motivo.text.trim(),
      );
      await _carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação enviada com sucesso.'),
            backgroundColor: pacienteVerde,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Não foi possível enviar: $e')));
      }
    } finally {
      exame.dispose();
      motivo.dispose();
    }
  }

  void _detalharResultado(ResultadoExame exame) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: pacienteFundo,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: pacienteVerde.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: pacienteVerdeEscuro,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${exame.titulo ?? 'Exame'}',
                  style: const TextStyle(
                    color: pacienteTexto,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PacienteCard(
            child: Column(
              children: [
                _linhaDetalhe(
                  'Tipo',
                  _texto(exame.tipo, vazio: 'Resultado'),
                  Icons.category_outlined,
                ),
                const Divider(height: 25, color: Color(0xFFECECEC)),
                _linhaDetalhe(
                  'Data',
                  _texto(exame.data, vazio: 'Não informada'),
                  Icons.calendar_today_outlined,
                ),
                const Divider(height: 25, color: Color(0xFFECECEC)),
                _linhaDetalhe(
                  'Armazenamento',
                  'Prontuário do paciente',
                  Icons.health_and_safety_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _campo(
    TextEditingController controller,
    String label,
    IconData icon, {
    int linhas = 1,
  }) => TextField(
    controller: controller,
    maxLines: linhas,
    decoration: InputDecoration(
      labelText: label,
      alignLabelWithHint: linhas > 1,
      prefixIcon: Padding(
        padding: EdgeInsets.only(bottom: linhas > 1 ? 68 : 0),
        child: Icon(icon, color: pacienteVerdeEscuro),
      ),
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
    ),
  );

  Widget _linhaDetalhe(String label, String valor, IconData icon) => Row(
    children: [
      Icon(icon, color: pacienteVerdeEscuro, size: 20),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: const TextStyle(
                color: pacienteTexto,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _vazio(
    IconData icon,
    String titulo,
    String texto, {
    bool acao = false,
  }) => ListView(
    children: [
      const SizedBox(height: 100),
      Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pacienteVerde.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Icon(icon, size: 35, color: pacienteVerdeEscuro),
        ),
      ),
      const SizedBox(height: 15),
      Text(
        titulo,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: pacienteTexto,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, height: 1.4),
        ),
      ),
      if (acao) ...[
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: _solicitar,
            icon: const Icon(Icons.add),
            label: const Text('Fazer solicitação'),
          ),
        ),
      ],
    ],
  );

  String _texto(dynamic valor, {required String vazio}) {
    final texto = '${valor ?? ''}'.trim();
    return texto.isEmpty || texto == 'null' ? vazio : texto;
  }
}
