import '../../models/lista_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:farmagrid/app_theme.dart';
import '../../services/perfil_service.dart';
import '../../services/paciente_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class TelaConfiguracoesPaciente extends StatefulWidget {
  final int abaInicial;
  const TelaConfiguracoesPaciente({super.key, this.abaInicial = 0});

  @override
  State<TelaConfiguracoesPaciente> createState() =>
      _TelaConfiguracoesPacienteState();
}

class _TelaConfiguracoesPacienteState extends State<TelaConfiguracoesPaciente> {
  final _themeCtrl = AppThemeController();
  int _abaSelecionada = 0;
  bool _modoEdicao = false;
  Map<String, dynamic> _perfil = {};
  Uint8List? _foto;

  static const Map<String, String> _dadosUsuario = {
    'nome': 'Ana Carolina',
    'sobrenome': 'Lanzoni',
    'email': 'ana.lanzoni@email.com',
    'telefone': '(11) 99999-0000',
    'nascimento': '15/03/2000',
    'rua': 'Av. Paulista',
    'numero': '1000',
    'bairro': 'Bela Vista',
    'cidade': 'São Paulo',
    'cep': '01310-100',
  };

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _sobrenomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _nascimentoCtrl;
  late final TextEditingController _ruaCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _bairroCtrl;
  late final TextEditingController _cidadeCtrl;
  late final TextEditingController _cepCtrl;
  final _estadoCtrl = TextEditingController();
  final _planoCtrl = TextEditingController();
  final _contatoEmerNomeCtrl = TextEditingController();
  final _contatoEmerTelCtrl = TextEditingController();
  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  final _confirmSenhaCtrl = TextEditingController();
  final _numeroCartaoCtrl = TextEditingController();
  final _titularCtrl = TextEditingController();
  final _validadeCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  final List<String> _alergias = [];
  List<Map<String, dynamic>> _cartoes = [];

  bool _verSenhaAtual = false;
  bool _verNovaSenha = false;
  bool _verConfirm = false;
  bool _notifConsultas = true;
  bool _notifReceitas = true;
  bool _notifDescontos = false;
  String _idioma = 'Português (BR)';
  String _tipoSanguineo = 'O+';
  String _planoAssinatura = 'Plano Básico';
  String _tipoAssinatura = 'MENSAL';

  final List<DependentePaciente> _dependentes = [];

  final List<Map<String, dynamic>> _abas = [
    {'titulo': 'Perfil pessoal', 'icone': Icons.person_outline},
    {'titulo': 'Saúde', 'icone': Icons.health_and_safety_outlined},
    {'titulo': 'Segurança', 'icone': Icons.shield_outlined},
    {'titulo': 'Pagamento', 'icone': Icons.credit_card_outlined},
    {'titulo': 'Dependentes', 'icone': Icons.people_outline},
  ];

  bool get _isDark => _themeCtrl.darkMode;
  Color get _corFundo =>
      _isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  Color get _corCard => _isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _corTexto => _isDark ? Colors.white : const Color(0xFF2E2E2E);
  Color get _corSubtexto => _isDark ? Colors.white60 : Colors.grey;
  Color get _corBorda =>
      _isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE);
  Color get _corCampo =>
      _isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9F9F9);
  Color get _corBordaCampo =>
      _isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD);

  static const Color _verde = Color(0xFF59AA53);
  static const Color _oliva = Color(0xFF136A48);
  static const Color _teal = Color(0xFF7FC6BB);

  @override
  void initState() {
    super.initState();
    _abaSelecionada = widget.abaInicial;

    _nomeCtrl = TextEditingController();
    _sobrenomeCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _telefoneCtrl = TextEditingController();
    _nascimentoCtrl = TextEditingController();
    _ruaCtrl = TextEditingController();
    _numeroCtrl = TextEditingController();
    _bairroCtrl = TextEditingController();
    _cidadeCtrl = TextEditingController();
    _cepCtrl = TextEditingController();
    _numeroCartaoCtrl.addListener(_atualizarCartaoVisual);
    _dependentes.clear();
    _carregarDados();
  }

  void _atualizarCartaoVisual() {
    if (mounted) setState(() {});
  }

  String get _numeroCartao =>
      _numeroCartaoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

  String get _bandeiraCartao {
    final numero = _numeroCartao;
    if (numero.isEmpty) return 'Bandeira';

    const eloPrefixos = [
      '401178',
      '401179',
      '431274',
      '438935',
      '451416',
      '457393',
      '457631',
      '457632',
      '504175',
      '506699',
      '506700',
      '506701',
      '506702',
      '506703',
      '506704',
      '506705',
      '506706',
      '506707',
      '506708',
      '506709',
      '506710',
      '506711',
      '506712',
      '506713',
      '506714',
      '506715',
      '506716',
      '506717',
      '506718',
      '506719',
      '506720',
      '506721',
      '506722',
      '506723',
      '506724',
      '506725',
      '506726',
      '506727',
      '506728',
      '506729',
      '506730',
      '506731',
      '506732',
      '506733',
      '506734',
      '506735',
      '506736',
      '506737',
      '506738',
      '506739',
      '506740',
      '506741',
      '506742',
      '506743',
      '506744',
      '506745',
      '506746',
      '506747',
      '506748',
      '506749',
      '506750',
      '506751',
      '506752',
      '506753',
      '506754',
      '506755',
      '506756',
      '506757',
      '506758',
      '506759',
      '506760',
      '506761',
      '506762',
      '506763',
      '506764',
      '506765',
      '506766',
      '506767',
      '509000',
      '627780',
      '636297',
      '636368',
      '650031',
      '650033',
      '650035',
      '650051',
      '650405',
      '650439',
      '650485',
      '650487',
      '650901',
      '650920',
      '651652',
      '651679',
      '655000',
      '655019',
    ];
    if (eloPrefixos.any(numero.startsWith)) return 'Elo';
    if (numero.startsWith('606282') || numero.startsWith('3841')) {
      return 'Hipercard';
    }
    if (numero.startsWith('34') || numero.startsWith('37')) return 'Amex';
    if (numero.startsWith('4')) return 'Visa';
    if (numero.length >= 2) {
      final dois = int.tryParse(numero.substring(0, 2)) ?? 0;
      if (dois >= 51 && dois <= 55) return 'Mastercard';
    }
    if (numero.length >= 4) {
      final quatro = int.tryParse(numero.substring(0, 4)) ?? 0;
      if (quatro >= 2221 && quatro <= 2720) return 'Mastercard';
      if (quatro >= 3528 && quatro <= 3589) return 'JCB';
    }
    if (numero.startsWith('6011') ||
        numero.startsWith('64') ||
        numero.startsWith('65')) {
      return 'Discover';
    }
    return 'Desconhecida';
  }

  Future<void> _carregarDados() async {
    try {
      final resultados = await Future.wait([
        PerfilService.carregar(atualizar: true),
        PacienteService.listarDependentes(),
        PacienteService.listarAlergias(),
        PacienteService.listarCartoes(),
      ]);
      if (!mounted) return;
      _perfil = resultados[0] as Map<String, dynamic>;
      final partes = '${_perfil['nome'] ?? ''}'.trim().split(RegExp(r'\s+'));
      _nomeCtrl.text = partes.isEmpty ? '' : partes.first;
      _sobrenomeCtrl.text = partes.length < 2 ? '' : partes.skip(1).join(' ');
      _emailCtrl.text = '${_perfil['email'] ?? ''}';
      _telefoneCtrl.text = '${_perfil['telefone'] ?? ''}';
      _nascimentoCtrl.text = '${_perfil['dataNascimento'] ?? ''}';
      _ruaCtrl.text = '${_perfil['rua'] ?? ''}';
      _numeroCtrl.text = '${_perfil['numCasa'] ?? ''}';
      _bairroCtrl.text = '${_perfil['bairro'] ?? ''}';
      _cidadeCtrl.text = '${_perfil['cidade'] ?? ''}';
      _estadoCtrl.text = (_perfil['estado'] ?? '').toString();
      _cepCtrl.text = '${_perfil['cep'] ?? ''}';
      _planoCtrl.text = '${_perfil['planoSaude'] ?? ''}';
      _contatoEmerNomeCtrl.text = '${_perfil['contatoEmergenciaNome'] ?? ''}';
      _contatoEmerTelCtrl.text =
          '${_perfil['contatoEmergenciaTelefone'] ?? ''}';
      _tipoSanguineo = '${_perfil['tipoSanguineo'] ?? 'Não informado'}';
      _planoAssinatura = _perfil['planoPremium'] == true
          ? 'Clube FarmaGrid+'
          : 'Plano Básico';
      _tipoAssinatura = '${_perfil['assinaturaTipo'] ?? 'MENSAL'}';
      _foto = PerfilService.foto(_perfil);
      _dependentes
        ..clear()
        ..addAll(
          (resultados[1] as List<Map<String, dynamic>>).map(
            (d) => DependentePaciente.fromJson(d),
          ),
        );
      _alergias
        ..clear()
        ..addAll(
          (resultados[2] as List<Map<String, dynamic>>)
              .map((a) => '${a['alergia'] ?? a['nome'] ?? ''}')
              .where((a) => a.isNotEmpty),
        );
      _cartoes = resultados[3] as List<Map<String, dynamic>>;
      setState(() {});
    } catch (e) {
      if (mounted) _snack('$e');
    }
  }

  Future<void> _salvarDados() async {
    try {
      await PerfilService.salvarPerfil({
        'nome': [
          _nomeCtrl.text.trim(),
          _sobrenomeCtrl.text.trim(),
        ].where((v) => v.isNotEmpty).join(' '),
        'email': _emailCtrl.text.trim(),
        'cpf': _perfil['cpf'],
        'dataNascimento': _nascimentoCtrl.text.trim(),
        'sexo': _perfil['sexo'],
        'telefone': _telefoneCtrl.text.trim(),
        'rua': _ruaCtrl.text.trim(),
        'numCasa': int.tryParse(_numeroCtrl.text),
        'bairro': _bairroCtrl.text.trim(),
        'cidade': _cidadeCtrl.text.trim(),
        'estado': _estadoCtrl.text.trim().toUpperCase(),
        'cep': _cepCtrl.text.trim(),
        'tipoSanguineo': _tipoSanguineo,
        'planoSaude': _planoCtrl.text.trim(),
        'contatoEmergenciaNome': _contatoEmerNomeCtrl.text.trim(),
        'contatoEmergenciaTelefone': _contatoEmerTelCtrl.text.trim(),
      });
      if (mounted) setState(() => _modoEdicao = false);
      _snack('Informações salvas no banco de dados!');
    } catch (erro) {
      if (mounted) _snack('Não foi possível concluir: $erro');
    }
  }

  Future<void> _selecionarFoto() async {
    try {
      final arquivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );
      if (arquivo == null) return;
      final bytes = await arquivo.readAsBytes();
      await PerfilService.salvarFoto(bytes);
      if (mounted) setState(() => _foto = bytes);
      _snack('Foto atualizada no banco de dados!');
    } catch (erro) {
      if (mounted) _snack('Não foi possível concluir: $erro');
    }
  }

  Future<void> _alterarSenha() async {
    try {
      if (_novaSenhaCtrl.text != _confirmSenhaCtrl.text) {
        _snack('As novas senhas não coincidem.');
        return;
      }
      await PerfilService.alterarSenha(
        _senhaAtualCtrl.text,
        _novaSenhaCtrl.text,
      );
      _senhaAtualCtrl.clear();
      _novaSenhaCtrl.clear();
      _confirmSenhaCtrl.clear();
      _snack('Senha atualizada no banco de dados!');
    } catch (erro) {
      if (mounted) _snack('Não foi possível concluir: $erro');
    }
  }

  Future<bool> _salvarCartao() async {
    try {
      final numero = _numeroCartaoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (numero.length < 13 ||
          _titularCtrl.text.trim().isEmpty ||
          _validadeCtrl.text.trim().length != 5 ||
          !RegExp(r'^\d{3,4}$').hasMatch(_cvvCtrl.text)) {
        _snack('Preencha número, titular, validade e CVV corretamente.');
        return false;
      }
      await PacienteService.adicionarCartao({
        'numero': numero,
        'nomeTitular': _titularCtrl.text.trim(),
        'validade': _validadeCtrl.text.trim(),
        'bandeira': _bandeiraCartao,
      });
      _numeroCartaoCtrl.clear();
      _titularCtrl.clear();
      _validadeCtrl.clear();
      _cvvCtrl.clear();
      _cartoes = await PacienteService.listarCartoes();
      if (mounted) setState(() {});
      _snack('Cartão salvo no banco de dados!');
      return true;
    } catch (erro) {
      if (mounted) _snack('Não foi possível concluir: $erro');
      return false;
    }
  }

  Future<void> _alterarPlano(bool premium, {String tipo = 'MENSAL'}) async {
    try {
      if (premium && _cartoes.isEmpty) {
        _snack('Cadastre um cartão abaixo antes de assinar o Premium.');
        return;
      }
      final numero = premium ? '${_cartoes.last['numero'] ?? ''}' : '';
      final finalCartao = numero.length >= 4
          ? numero.substring(numero.length - 4)
          : numero;
      const precos = {
        'MENSAL': 'R\$ 19,90/mês',
        'ANUAL': 'R\$ 149,90/ano',
        'PERMANENTE': 'R\$ 199,00 (pagamento único)',
      };
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(premium ? 'Confirmar assinatura' : 'Cancelar Premium'),
          content: Text(
            premium
                ? 'Assinar o Clube FarmaGrid+ por ${precos[tipo]} usando o cartão final $finalCartao?'
                : 'Você perderá os benefícios Premium ao confirmar o cancelamento.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      if (confirmar != true) return;
      await PacienteService.alterarAssinatura(premium, tipo: tipo);
      final atualizado = await PerfilService.carregar(atualizar: true);
      if (mounted) {
        setState(() {
          _perfil = atualizado;
          _planoAssinatura = premium ? 'Clube FarmaGrid+' : 'Plano Básico';
          _tipoAssinatura = premium ? tipo : 'MENSAL';
        });
      }
      _snack(premium ? 'Assinatura Premium ativada!' : 'Assinatura cancelada.');
    } catch (erro) {
      if (mounted) _snack('Não foi possível concluir: $erro');
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl,
      _sobrenomeCtrl,
      _emailCtrl,
      _telefoneCtrl,
      _nascimentoCtrl,
      _ruaCtrl,
      _numeroCtrl,
      _bairroCtrl,
      _cidadeCtrl,
      _cepCtrl,
      _estadoCtrl,
      _planoCtrl,
      _contatoEmerNomeCtrl,
      _contatoEmerTelCtrl,
      _senhaAtualCtrl,
      _novaSenhaCtrl,
      _confirmSenhaCtrl,
      _numeroCartaoCtrl,
      _titularCtrl,
      _validadeCtrl,
      _cvvCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corFundo,
      body: Column(
        children: [
          _cabecalho(context),
          _barraAbas(),
          Expanded(child: _conteudoAba()),
        ],
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_verde, _teal],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configurações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Gerencie seu perfil',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            backgroundImage: _foto == null ? null : MemoryImage(_foto!),
            child: _foto == null
                ? const Icon(Icons.person, color: Colors.white, size: 24)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _barraAbas() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: _corCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ScrollConfiguration(
        behavior: _SemGlowScroll(),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: _abas.length,
          itemBuilder: (_, index) => _itemAba(index),
        ),
      ),
    );
  }

  Widget _itemAba(int index) {
    final sel = _abaSelecionada == index;
    return GestureDetector(
      onTap: () => setState(() {
        _abaSelecionada = index;
        _modoEdicao = false;
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? _verde
              : (_isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _abas[index]['icone'] as IconData,
              color: sel
                  ? Colors.white
                  : (_isDark ? Colors.white54 : Colors.grey[500]),
              size: 17,
            ),
            const SizedBox(width: 7),
            Text(
              _abas[index]['titulo'] as String,
              style: TextStyle(
                fontSize: 12.5,
                color: sel
                    ? Colors.white
                    : (_isDark ? Colors.white60 : Colors.grey[600]),
                fontWeight: sel ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conteudoAba() {
    switch (_abaSelecionada) {
      case 0:
        return _abaPerfil();
      case 1:
        return _abaSaude();
      case 2:
        return _abaSeguranca();
      case 3:
        return _abaPagamento();
      case 4:
        return _abaDependentes();
      default:
        return _abaPerfil();
    }
  }

  Widget _scaffoldAba({
    required String titulo,
    required String subtitulo,
    bool botaoEditar = false,
    VoidCallback? onEditar,
    VoidCallback? onSalvar,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: _isDark ? Colors.white : _oliva,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: TextStyle(color: _corSubtexto, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (botaoEditar)
                ElevatedButton(
                  onPressed: onEditar ?? onSalvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _modoEdicao ? _verde : _oliva,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _modoEdicao ? 'Salvar' : 'Editar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _abaPerfil() {
    return _scaffoldAba(
      titulo: 'Perfil Pessoal',
      subtitulo: 'Suas informações pessoais cadastradas',
      botaoEditar: true,
      onEditar: () {
        if (_modoEdicao) {
          _salvarDados();
          return;
        }
        setState(() => _modoEdicao = !_modoEdicao);
      },
      child: Column(
        children: [
          _cardSecao(
            titulo: 'Foto de Perfil',
            subtitulo: 'Sua foto visível no sistema',
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _teal.withValues(alpha: 0.3),
                  backgroundImage: _foto == null ? null : MemoryImage(_foto!),
                  child: _foto == null
                      ? const Icon(Icons.person, color: _oliva, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _modoEdicao ? _selecionarFoto : null,
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: _modoEdicao ? _oliva : Colors.grey,
                  ),
                  label: Text(
                    'Alterar Foto',
                    style: TextStyle(
                      color: _modoEdicao ? _oliva : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _modoEdicao
                          ? _corBordaCampo
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _cardSecao(
            titulo: 'Informações Pessoais',
            subtitulo: _modoEdicao
                ? 'Edite seus dados e toque em Salvar'
                : 'Toque em Editar para alterar',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _campo('Nome:', _nomeCtrl, _modoEdicao)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campo('Sobrenome:', _sobrenomeCtrl, _modoEdicao),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _campo('E-mail:', _emailCtrl, _modoEdicao),
                const SizedBox(height: 12),
                _campo('Telefone:', _telefoneCtrl, _modoEdicao),
                const SizedBox(height: 12),
                _campo('Data de Nascimento:', _nascimentoCtrl, _modoEdicao),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _campo('Rua:', _ruaCtrl, _modoEdicao),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _campo('Número:', _numeroCtrl, _modoEdicao),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _campo('Bairro:', _bairroCtrl, _modoEdicao),
                const SizedBox(height: 12),
                _campo('Estado (UF):', _estadoCtrl, _modoEdicao),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _campo('Cidade:', _cidadeCtrl, _modoEdicao),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _campo('CEP:', _cepCtrl, _modoEdicao),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_modoEdicao)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _verde.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _verde.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, color: _verde, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modo de edição ativo. Altere os campos e toque em Salvar.',
                      style: TextStyle(color: _verde, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _abaSaude() {
    return _scaffoldAba(
      titulo: 'Informações de Saúde',
      subtitulo: 'Dados médicos e plano de saúde',
      botaoEditar: true,
      onEditar: () {
        if (_modoEdicao) {
          _salvarDados();
          return;
        }
        setState(() => _modoEdicao = !_modoEdicao);
      },
      child: Column(
        children: [
          _cardSecao(
            titulo: 'Plano de Saúde',
            subtitulo: 'Informações do seu convênio médico',
            child: Column(
              children: [_campo('Nome do Plano:', _planoCtrl, _modoEdicao)],
            ),
          ),
          const SizedBox(height: 14),
          _cardSecao(
            titulo: 'Dados Médicos',
            subtitulo: 'Informações relevantes para seus atendimentos',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo Sanguíneo:',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDark ? Colors.white70 : const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _tipoSanguineo,
                  style: TextStyle(color: _corTexto, fontSize: 14),
                  dropdownColor: _corCard,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _corCampo,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _corBordaCampo),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _corBordaCampo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _verde, width: 2),
                    ),
                  ),
                  items:
                      [
                            'Não informado',
                            'A+',
                            'A-',
                            'B+',
                            'B-',
                            'O+',
                            'O-',
                            'AB+',
                            'AB-',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: _modoEdicao
                      ? (v) => setState(() => _tipoSanguineo = v!)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Alergias conhecidas:',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDark ? Colors.white70 : const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._alergias.map(
                      (a) => Chip(
                        label: Text(
                          a,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: _verde,
                        deleteIcon: _modoEdicao
                            ? const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                        onDeleted: _modoEdicao
                            ? () => setState(() => _alergias.remove(a))
                            : null,
                      ),
                    ),
                    if (_modoEdicao)
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 16, color: _oliva),
                        label: const Text(
                          'Adicionar',
                          style: TextStyle(fontSize: 12, color: _oliva),
                        ),
                        backgroundColor: _oliva.withValues(alpha: 0.1),
                        onPressed: _dialogoAdicionarAlergia,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _campo(
                        'Contato de Emergência:',
                        _contatoEmerNomeCtrl,
                        _modoEdicao,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campo(
                        'Telefone:',
                        _contatoEmerTelCtrl,
                        _modoEdicao,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _abaSeguranca() {
    return _scaffoldAba(
      titulo: 'Segurança e Privacidade',
      subtitulo: 'Gerencie sua senha e permissões de dados',
      child: Column(
        children: [
          _cardSecao(
            titulo: 'Alterar Senha',
            subtitulo: 'Mantenha sua conta segura com uma senha forte',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _campoSenha(
                  'Senha Atual:',
                  _senhaAtualCtrl,
                  _verSenhaAtual,
                  () => setState(() => _verSenhaAtual = !_verSenhaAtual),
                ),
                const SizedBox(height: 12),
                _campoSenha(
                  'Nova Senha:',
                  _novaSenhaCtrl,
                  _verNovaSenha,
                  () => setState(() => _verNovaSenha = !_verNovaSenha),
                ),
                const SizedBox(height: 12),
                _campoSenha(
                  'Confirmar Nova Senha:',
                  _confirmSenhaCtrl,
                  _verConfirm,
                  () => setState(() => _verConfirm = !_verConfirm),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _alterarSenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _oliva,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Atualizar Senha',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _abaPagamento() {
    return _scaffoldAba(
      titulo: 'Pagamento',
      subtitulo: 'Cartões e assinaturas do plano',
      child: Column(
        children: [
          _cardSecao(
            titulo: 'Assinatura Atual',
            subtitulo: 'Seu plano ativo e benefícios incluídos',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_verde, _teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _planoAssinatura,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _perfil['planoPremium'] == true
                                ? (_tipoAssinatura == 'PERMANENTE'
                                      ? 'Ativo · acesso permanente'
                                      : 'Ativo · válido até ${_perfil['assinaturaValidade'] ?? '—'}')
                                : 'Plano gratuito',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Trocar plano:',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDark ? Colors.white70 : const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 8),
                ...[
                  ('Plano Básico', false, 'MENSAL', 'Grátis'),
                  ('Clube Mensal', true, 'MENSAL', 'R\$ 19,90/mês'),
                  (
                    'Clube Anual',
                    true,
                    'ANUAL',
                    'R\$ 149,90/ano · economize R\$ 88,90',
                  ),
                  (
                    'Clube Permanente',
                    true,
                    'PERMANENTE',
                    'R\$ 199,00 · pagamento único',
                  ),
                ].map((opcao) {
                  final plano = opcao.$1;
                  final premium = opcao.$2;
                  final tipo = opcao.$3;
                  final sel = premium
                      ? _planoAssinatura == 'Clube FarmaGrid+' &&
                            _tipoAssinatura == tipo
                      : _planoAssinatura == 'Plano Básico';
                  return GestureDetector(
                    onTap: () async {
                      if (sel) return;
                      await _alterarPlano(premium, tipo: tipo);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? _verde.withValues(alpha: 0.08) : _corCampo,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? _verde : _corBordaCampo,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            sel
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: sel ? _verde : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plano,
                                  style: TextStyle(
                                    fontWeight: sel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: sel ? _oliva : _corTexto,
                                  ),
                                ),
                                Text(
                                  opcao.$4,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _corSubtexto,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _cardSecao(
            titulo: 'Cartão de Pagamento',
            subtitulo: 'Gerencie seu método de pagamento',
            child: Column(
              children: [
                _prototipoCartao(),
                const SizedBox(height: 20),
                _campo(
                  'Número do Cartão:',
                  _numeroCartaoCtrl,
                  true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [const _NumeroCartaoFormatter()],
                ),
                const SizedBox(height: 12),
                _campo(
                  'Nome do Titular:',
                  _titularCtrl,
                  true,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _campo(
                        'Validade:',
                        _validadeCtrl,
                        true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [const _ValidadeCartaoFormatter()],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campo(
                        'CVV:',
                        _cvvCtrl,
                        true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [const _CvvFormatter()],
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: _corCampo,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _corBordaCampo),
                  ),
                  child: Row(
                    children: [
                      _iconeBandeira(largura: 42, altura: 27),
                      const SizedBox(width: 10),
                      Text(
                        _bandeiraCartao,
                        style: TextStyle(fontSize: 14, color: _corTexto),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _salvarCartao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _oliva,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salvar Cartão',
                    style: TextStyle(
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

  Widget _abaDependentes() {
    return _scaffoldAba(
      titulo: 'Dependentes',
      subtitulo: 'Gerencie os dependentes vinculados ao seu plano',
      child: Column(
        children: [
          _cardSecao(
            titulo: 'Dependentes Cadastrados',
            subtitulo: '${_dependentes.length} dependente(s) no plano',
            child: Column(
              children: [
                ListView.builder(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _dependentes.length,
                  itemBuilder: (context, index) {
                    final dep = _dependentes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _corCampo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _corBordaCampo),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: _verde.withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.person,
                              color: _verde,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dep.nome,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _corTexto,
                                  ),
                                ),
                                Text(
                                  '${dep.parentesco} · CPF: ${dep.cpf}',
                                  style: TextStyle(
                                    color: _corSubtexto,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () async {
                              try {
                                await PacienteService.removerDependente(dep.id);
                                if (!mounted) return;
                                setState(() => _dependentes.remove(dep));
                                _snack('Dependente removido.');
                              } catch (erro) {
                                if (mounted)
                                  _snack('Não foi possível remover: $erro');
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _dialogoAdicionarDependente(),
                    icon: const Icon(
                      Icons.person_add_outlined,
                      color: _oliva,
                      size: 18,
                    ),
                    label: const Text(
                      'Adicionar Dependente',
                      style: TextStyle(
                        color: _oliva,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _oliva),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _cardSecao(
            titulo: 'Limite do Plano',
            subtitulo: 'Dependentes permitidos no seu plano atual',
            child: Row(
              children: [
                Expanded(
                  child: _miniStat(
                    '${_dependentes.length}',
                    'Cadastrados',
                    _verde,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniStat(
                    '${3 - _dependentes.length}',
                    'Disponíveis',
                    _teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _miniStat('3', 'Máximo', _oliva)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _dialogoAdicionarDependente() {
    if (_dependentes.length >= 3) {
      _snack('Limite de 3 dependentes atingido no plano atual.');
      return;
    }

    final nomeCtrl = TextEditingController();
    final cpfCtrl = TextEditingController();
    final parentescoCtrl = TextEditingController();
    String parentescoSel = 'Filho(a)';
    const opcoes = ['Filho(a)', 'Cônjuge', 'Pai/Mãe', 'Irmão/Irmã', 'Outro'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: _corCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: _verde,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Novo Dependente',
                style: TextStyle(
                  color: _corTexto,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome completo',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDark ? Colors.white70 : const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nomeCtrl,
                  style: TextStyle(color: _corTexto),
                  decoration: InputDecoration(
                    hintText: 'Ex: Maria da Silva',
                    hintStyle: TextStyle(color: _corSubtexto),
                    filled: true,
                    fillColor: _corCampo,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _corBordaCampo),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _corBordaCampo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _verde, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'CPF',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDark ? Colors.white70 : const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: cpfCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: _corTexto),
                  decoration: InputDecoration(
                    hintText: 'Ex: 000.000.000-00',
                    hintStyle: TextStyle(color: _corSubtexto),
                    filled: true,
                    fillColor: _corCampo,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _corBordaCampo),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _corBordaCampo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _verde, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Parentesco',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDark ? Colors.white70 : const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _corCampo,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _corBordaCampo),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: parentescoSel,
                      isExpanded: true,
                      style: TextStyle(color: _corTexto, fontSize: 14),
                      dropdownColor: _corCard,
                      items: opcoes
                          .map(
                            (o) => DropdownMenuItem(value: o, child: Text(o)),
                          )
                          .toList(),
                      onChanged: (v) => setDlg(() => parentescoSel = v!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: _corSubtexto)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _verde,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final nome = nomeCtrl.text.trim();
                final cpf = cpfCtrl.text.trim();
                if (nome.isEmpty || cpf.isEmpty) {
                  _snack('Preencha nome e CPF para continuar.');
                  return;
                }
                try {
                  await PacienteService.adicionarDependente({
                    'nome': nome,
                    'parentesco': parentescoSel,
                    'cpf': cpf,
                  });
                  if (!mounted || !ctx.mounted) return;
                  Navigator.pop(ctx);
                  await _carregarDados();
                  if (mounted)
                    _snack('Dependente "$nome" adicionado com sucesso!');
                } catch (erro) {
                  if (mounted) _snack('Não foi possível adicionar: $erro');
                }
              },
              child: const Text(
                'Adicionar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogoAdicionarAlergia() {
    final alergiaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _corCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _verde.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_outlined,
                color: _verde,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Nova Alergia',
              style: TextStyle(
                color: _corTexto,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: alergiaCtrl,
          autofocus: true,
          style: TextStyle(color: _corTexto),
          decoration: InputDecoration(
            hintText: 'Ex: Dipirona',
            hintStyle: TextStyle(color: _corSubtexto),
            filled: true,
            fillColor: _corCampo,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _corBordaCampo),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _corBordaCampo),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _verde, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: _corSubtexto)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _verde,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final nome = alergiaCtrl.text.trim();
              if (nome.isEmpty) {
                _snack('Digite o nome da alergia.');
                return;
              }
              setState(() => _alergias.add(nome));
              Navigator.pop(ctx);
            },
            child: const Text(
              'Adicionar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String valor, String label, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: _isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: cor.withValues(alpha: 0.7), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _cardSecao({
    required String titulo,
    required String subtitulo,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _corCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: _isDark ? Colors.white : _oliva,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitulo, style: TextStyle(color: _corSubtexto, fontSize: 11)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _prototipoCartao() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 390),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_oliva, _verde, _teal.withValues(alpha: .95)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _oliva.withValues(alpha: .25),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 43,
                height: 31,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8C96A),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.white38),
                ),
                child: const Icon(
                  Icons.memory,
                  size: 21,
                  color: Color(0xFF8A6C1E),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _iconeBandeira(
                  key: ValueKey(_bandeiraCartao),
                  largura: 62,
                  altura: 38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 27),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '•••• •••• •••• ••••',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _dadoCartao('TITULAR', 'NOME DO TITULAR')),
              const SizedBox(width: 16),
              _dadoCartao('VALIDADE', 'MM/AA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dadoCartao(String rotulo, String valor) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        rotulo,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 9,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        valor,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
    ],
  );

  Widget _iconeBandeira({
    Key? key,
    required double largura,
    required double altura,
  }) {
    final bandeira = _bandeiraCartao;
    if (bandeira == 'Mastercard') {
      return SizedBox(
        key: key,
        width: largura,
        height: altura,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: largura * .12,
              child: _circuloLogo(altura, const Color(0xFFEB001B)),
            ),
            Positioned(
              right: largura * .12,
              child: _circuloLogo(altura, const Color(0xFFF79E1B)),
            ),
          ],
        ),
      );
    }

    final estilo = switch (bandeira) {
      'Visa' => (const Color(0xFFFFFFFF), const Color(0xFF1434CB), 'VISA'),
      'Amex' => (const Color(0xFF2E77BC), Colors.white, 'AMEX'),
      'Elo' => (const Color(0xFF171717), const Color(0xFFFFCB05), 'elo'),
      'Hipercard' => (const Color(0xFFB3131B), Colors.white, 'hipercard'),
      'Discover' => (Colors.white, const Color(0xFFF58220), 'DISCOVER'),
      'JCB' => (const Color(0xFF1677B8), Colors.white, 'JCB'),
      _ => (Colors.white24, Colors.white70, '••••'),
    };
    return Container(
      key: key,
      width: largura,
      height: altura,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: estilo.$1,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: FittedBox(
        child: Text(
          estilo.$3,
          style: TextStyle(
            color: estilo.$2,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            fontStyle: bandeira == 'Visa' ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _circuloLogo(double tamanho, Color cor) => Container(
    width: tamanho,
    height: tamanho,
    decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
  );

  Widget _campo(
    String label,
    TextEditingController ctrl,
    bool editavel, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: _isDark ? Colors.white70 : const Color(0xFF444444),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          enabled: editavel,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 14,
            color: editavel
                ? _corTexto
                : (_isDark ? Colors.white54 : const Color(0xFF666666)),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: editavel
                ? _corCampo
                : (_isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _corBordaCampo),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: editavel ? _corBordaCampo : Colors.transparent,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFFE8E8E8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _verde, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoSenha(
    String label,
    TextEditingController ctrl,
    bool visivel,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: _isDark ? Colors.white70 : const Color(0xFF444444),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          obscureText: !visivel,
          style: TextStyle(fontSize: 14, color: _corTexto),
          decoration: InputDecoration(
            filled: true,
            fillColor: _corCampo,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                visivel
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _corBordaCampo),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _corBordaCampo),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _verde, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchItem(
    IconData icone,
    String titulo,
    String sub,
    bool valor,
    ValueChanged<bool> onChange,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: _verde.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icone, color: _verde, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _corTexto,
                ),
              ),
              Text(sub, style: TextStyle(color: _corSubtexto, fontSize: 12)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => onChange(!valor),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 26,
            decoration: BoxDecoration(
              color: valor ? _verde : Colors.grey.shade400,
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
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _verde,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SemGlowScroll extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}

class _NumeroCartaoFormatter extends TextInputFormatter {
  const _NumeroCartaoFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amex = digitos.startsWith('34') || digitos.startsWith('37');
    final limite = amex ? 15 : 19;
    if (digitos.length > limite) digitos = digitos.substring(0, limite);

    final grupos = <String>[];
    if (amex) {
      const tamanhos = [4, 6, 5];
      var inicio = 0;
      for (final tamanho in tamanhos) {
        if (inicio >= digitos.length) break;
        final fim = (inicio + tamanho).clamp(0, digitos.length);
        grupos.add(digitos.substring(inicio, fim));
        inicio = fim;
      }
    } else {
      for (var i = 0; i < digitos.length; i += 4) {
        grupos.add(digitos.substring(i, (i + 4).clamp(0, digitos.length)));
      }
    }
    final texto = grupos.join(' ');
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class _ValidadeCartaoFormatter extends TextInputFormatter {
  const _ValidadeCartaoFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length > 4) digitos = digitos.substring(0, 4);
    final texto = digitos.length > 2
        ? '${digitos.substring(0, 2)}/${digitos.substring(2)}'
        : digitos;
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class _CvvFormatter extends TextInputFormatter {
  const _CvvFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length > 4) digitos = digitos.substring(0, 4);
    return TextEditingValue(
      text: digitos,
      selection: TextSelection.collapsed(offset: digitos.length),
    );
  }
}
