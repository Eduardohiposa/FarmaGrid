import '../../models/paciente_models.dart';
import 'package:farmagrid/widgets/carregamento.dart';
import 'package:flutter/material.dart';
import '../../services/paciente_service.dart';
import 'paciente_visual.dart';

class TelaFarmaciasProximas extends StatefulWidget {
  const TelaFarmaciasProximas({super.key});
  @override
  State<TelaFarmaciasProximas> createState() => _TelaFarmaciasProximasState();
}

class _TelaFarmaciasProximasState extends State<TelaFarmaciasProximas> {
  final _busca = TextEditingController();
  List<FarmaciaProxima> _farmacias = [];
  bool _carregando = true;
  String? _erro;
  String _filtro = 'todas';

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
      final lista = await PacienteService.listarFarmaciasProximas();
      if (mounted) setState(() => _farmacias = lista);
    } catch (e) {
      if (mounted) setState(() => _erro = '$e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<FarmaciaProxima> get _filtradas => _farmacias.where((f) {
    final buscaOk = '${f.nome} ${f.endereco}'.toLowerCase().contains(
      _busca.text.trim().toLowerCase(),
    );
    final aberto = f.aberto;
    return buscaOk &&
        (_filtro == 'todas' ||
            (_filtro == 'abertas' && aberto == true) ||
            (_filtro == 'fechadas' && aberto == false));
  }).toList();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: Column(
      children: [
        PacienteCabecalho(
          titulo: 'Farmácias próximas',
          subtitulo: 'Busca na região do CEP e endereço cadastrado',
          rodape: TextField(
            controller: _busca,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: pacienteVerdeEscuro),
              suffixIcon: _busca.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _busca.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close, size: 19),
                    ),
              hintText: 'Buscar farmácia ou endereço',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        Expanded(child: _conteudo()),
      ],
    ),
  );

  Widget _conteudo() => RefreshIndicator(
    onRefresh: _carregar,
    color: pacienteVerde,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 38),
      children: [
        _filtros(),
        const SizedBox(height: 24),
        if (_carregando)
          const Padding(
            padding: EdgeInsets.only(top: 120),
            child: CartaoCarregamento(),
          )
        else if (_erro != null)
          _mensagem(
            Icons.location_off_outlined,
            _mensagemErro(_erro!),
            botao: true,
          )
        else if (_filtradas.isEmpty)
          _mensagem(
            Icons.local_pharmacy_outlined,
            'Nenhuma farmácia encontrada com estes filtros.',
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const PacienteTituloSecao('Perto de você'),
              Text(
                '${_filtradas.length} resultado${_filtradas.length == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.builder(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filtradas.length,
            itemBuilder: (context, index) {
              return _cardFarmacia(_filtradas[index]);
            },
          ),
          const SizedBox(height: 5),
          _fonteDados(),
        ],
      ],
    ),
  );

  Widget _filtros() => Row(
    children: [
      _filtroChip('todas', 'Todas'),
      const SizedBox(width: 8),
      _filtroChip('abertas', 'Abertas agora'),
      const SizedBox(width: 8),
      _filtroChip('fechadas', 'Fechadas'),
    ],
  );

  Widget _filtroChip(String valor, String texto) {
    final ativo = _filtro == valor;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filtro = valor),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
            color: ativo ? pacienteVerde : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: ativo
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ativo ? Colors.white : Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardFarmacia(FarmaciaProxima farmacia) {
    final aberto = farmacia.aberto;
    final Color statusCor = aberto == true
        ? pacienteVerdeEscuro
        : aberto == false
        ? const Color(0xFFD2693A)
        : Colors.grey;
    final String status = aberto == true
        ? 'Aberta agora'
        : aberto == false
        ? 'Fechada agora'
        : '${farmacia.horario}';
    final String fonte = '${farmacia.fonte}';
    return PacienteCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: pacienteVerde.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_pharmacy_outlined,
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
                      '${farmacia.nome}',
                      style: const TextStyle(
                        color: pacienteTexto,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${farmacia.endereco}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (farmacia.distanciaMetros != null) ...[
            const SizedBox(height: 10),
            Text(
              'Aproximadamente ' +
                  (farmacia.distanciaMetros! / 1000)
                      .toStringAsFixed(1)
                      .replaceAll('.', ',') +
                  ' km da região do cadastro',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 5,
                height: 30,
                decoration: BoxDecoration(
                  color: pacienteTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                aberto == true
                    ? Icons.check_circle_outline
                    : aberto == false
                    ? Icons.schedule_outlined
                    : Icons.info_outline,
                color: statusCor,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusCor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (fonte.isNotEmpty)
                Text(
                  fonte,
                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fonteDados() {
    final osm = _farmacias.any((f) => f.fonte == 'OpenStreetMap');
    return PacienteCard(
      color: const Color(0xFFEAF5EF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: pacienteVerdeEscuro,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              osm
                  ? '© OpenStreetMap contributors (ODbL). Busca em até 10 km do endereço cadastrado. Horários podem não estar disponíveis.'
                  : 'Resultados e horários consultados pelo Google Places.',
              style: const TextStyle(
                color: Color(0xFF557068),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _mensagemErro(String erro) {
    if (erro.toLowerCase().contains('endere')) {
      return 'Não foi possível localizar seu endereço. Confira cidade, CEP, bairro e rua nas configurações.';
    }
    return erro;
  }

  Widget _mensagem(IconData icon, String texto, {bool botao = false}) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(15, 90, 15, 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: pacienteVerde.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 34, color: pacienteVerdeEscuro),
            ),
            const SizedBox(height: 14),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
            if (botao) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _carregar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      );
}
