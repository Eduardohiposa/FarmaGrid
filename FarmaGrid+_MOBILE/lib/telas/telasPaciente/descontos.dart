import 'package:farmagrid/widgets/carregamento.dart';
import 'package:farmagrid/telas/login.dart';
import 'package:flutter/material.dart';
import '../../models/paciente_models.dart';
import '../../services/paciente_service.dart';
import '../../services/perfil_service.dart';
import 'configuracoesPaciente.dart';

class TelaDescontos extends StatefulWidget {
  const TelaDescontos({super.key});

  @override
  State<TelaDescontos> createState() => _TelaDescontosState();
}

class _TelaDescontosState extends State<TelaDescontos> {
  final Color corVerdePrimario = const Color(0xFF59AA53);
  final Color corFundoSite = const Color(0xFFF5F5F5);
  final Color corBegeCard = const Color(0xFFFDFCF4);
  final Color corTeal = Color(0xFF7FC6BB);
  List<CupomPaciente> _cupons = const [];
  bool _premium = false;
  bool _carregandoCupons = true;
  String? _erroCupons;
  final Set<int> _resgatando = {};

  @override
  void initState() {
    super.initState();
    _carregarCupons();
    PerfilService.carregar(atualizar: true)
        .then((p) {
          if (mounted) {
            setState(
              () => _premium =
                  p['planoPremium'] == true && p['assinaturaStatus'] == 'ATIVA',
            );
          }
        })
        .catchError((_) {});
  }

  Future<void> _carregarCupons() async {
    try {
      final cupons = await PacienteService.listarCupons();
      if (!mounted) return;
      setState(() {
        _cupons = cupons;
        _erroCupons = null;
        _carregandoCupons = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _erroCupons = erro.toString();
        _carregandoCupons = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoSite,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Descontos Disponíveis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF436B5E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_carregandoCupons)
                    const CartaoCarregamento()
                  else if (_erroCupons != null)
                    Center(
                      child: Text(
                        'Não foi possível carregar os descontos.\n$_erroCupons',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (_cupons.isEmpty)
                    const Center(child: Text('Nenhum desconto disponível.'))
                  else
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cupons.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildCardDesconto(_cupons[index]),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF89C6B1).withValues(alpha: 1.0),
            const Color(0xFF59AA53),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Clube FarmaGrid+",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _premium
                              ? "Você é membro Premium!"
                              : "Conheça o FarmaGrid Premium",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _premium
                              ? "Aproveite descontos exclusivos"
                              : "Assine para liberar os benefícios",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.stars, color: corVerdePrimario, size: 40),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corVerdePrimario,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!_premium) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TelaConfiguracoesPaciente(abaInicial: 3),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TelaClube()),
                      );
                    }
                  },
                  child: Text(
                    _premium ? "Mostrar comprovante" : "Assinar Premium",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDesconto(CupomPaciente cupom) {
    final porcentagem = cupom.tipo.toLowerCase().contains('percent')
        ? '${cupom.valor.toStringAsFixed(0)}%'
        : 'R\$ ${cupom.valor.toStringAsFixed(2)}';
    final processando = _resgatando.contains(cupom.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: corVerdePrimario.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/medicamentos.png',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 15,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      porcentagem,
                      style: TextStyle(
                        color: corVerdePrimario,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cupom.codigo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.local_offer, size: 14, color: corVerdePrimario),
                    const SizedBox(width: 5),
                    Text(
                      cupom.descricao,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      "Válido até ${cupom.validade}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corVerdePrimario.withValues(alpha: 0.2),
                    foregroundColor: corVerdePrimario,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 40),
                    shape: StadiumBorder(),
                  ),
                  onPressed: cupom.resgatado || processando
                      ? null
                      : () => _resgatar(cupom),
                  child: processando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          cupom.resgatado
                              ? "Desconto ativado"
                              : "Ativar desconto",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resgatar(CupomPaciente cupom) async {
    setState(() => _resgatando.add(cupom.id));
    try {
      final atualizado = await PacienteService.resgatarCupom(cupom.id);
      if (!mounted) return;
      setState(() {
        final indice = _cupons.indexWhere((c) => c.id == cupom.id);
        if (indice >= 0) _cupons = [..._cupons]..[indice] = atualizado;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cupom ${cupom.codigo} ativado com sucesso.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _resgatando.remove(cupom.id));
    }
  }
}

class TelaClube extends StatefulWidget {
  const TelaClube({super.key});

  @override
  State<TelaClube> createState() => _TelaClubeState();
}

class _TelaClubeState extends State<TelaClube> {
  final Color corVerdePrimario = const Color(0xFF59AA53);
  Map<String, dynamic>? _perfil;

  @override
  void initState() {
    super.initState();
    PerfilService.carregar(atualizar: true).then((p) {
      if (mounted) setState(() => _perfil = p);
    });
  }

  String _dataBr(String? data) {
    if (data == null || data.isEmpty) return '—';
    final partes = data.split('-');
    return partes.length == 3 ? '${partes[2]}/${partes[1]}/${partes[0]}' : data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [corTeal, corVerdePrimario],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    "Voltar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: corVerdePrimario.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.verified,
                        color: corVerdePrimario,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Clube FarmaGrid+",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      "Membro Premium",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: corVerdePrimario.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "ID do Membro",
                            style: TextStyle(
                              color: corVerdePrimario,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_perfil?['assinaturaComprovanteId'] ?? 'Carregando...'}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _perfil?['assinaturaTipo'] == 'PERMANENTE'
                                ? 'Acesso permanente'
                                : 'Válido até ${_dataBr(_perfil?['assinaturaValidade']?.toString())}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildRegra(
                      Icons.check_circle,
                      "Descontos exclusivos até 40%",
                    ),
                    const SizedBox(height: 10),
                    _buildRegra(
                      Icons.check_circle,
                      "Entrega grátis em pedidos",
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegra(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, color: corVerdePrimario, size: 20),
        const SizedBox(width: 10),
        Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF436B5E),
          ),
        ),
      ],
    );
  }
}
