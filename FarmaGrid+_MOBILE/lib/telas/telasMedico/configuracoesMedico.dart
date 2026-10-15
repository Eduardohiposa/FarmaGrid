import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:farmagrid/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/perfil_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

const Color _verde = Color(0xFF59AA53);
const Color _oliva = Color(0xFF136A48);
const Color _teal = Color(0xFF7FC6BB);

class TelaConfiguracoesMedico extends StatefulWidget {
  final int abaInicial;
  const TelaConfiguracoesMedico({super.key, this.abaInicial = 0});

  @override
  State<TelaConfiguracoesMedico> createState() =>
      _TelaConfiguracoesMedicoState();
}

class _TelaConfiguracoesMedicoState extends State<TelaConfiguracoesMedico> {
  int _abaSelecionada = 0;
  final _themeCtrl = AppThemeController();

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

  final _nomeCtrl = TextEditingController();
  final _sobrenomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _nascimentoCtrl = TextEditingController(text: 'dd/mm/aaaa');

  final _crmCtrl = TextEditingController();
  final _especialidadeCtrl = TextEditingController();
  final _clinicaNomeCtrl = TextEditingController();

  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  final _confirmSenhaCtrl = TextEditingController();

  bool _editandoPerfil = false;
  bool _editandoProfissional = false;
  Map<String, dynamic> _perfil = {};
  Uint8List? _foto;

  bool _verSenhaAtual = false;
  bool _verNovaSenha = false;
  bool _verConfirm = false;
  bool _notifConsultas = true;
  bool _notifMensagens = true;
  bool _notifLembretes = false;
  String _idioma = 'Português (BR)';

  final List<Map<String, dynamic>> _abas = [
    {'titulo': 'Perfil Pessoal', 'icone': Icons.person_outline},
    {'titulo': 'Info. Profissionais', 'icone': Icons.work_outline},
    {'titulo': 'Segurança', 'icone': Icons.shield_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _abaSelecionada = widget.abaInicial;
    _carregarDados();
  }

  void _preencherDados() {
    _nomeCtrl.text = PerfilService.nome(_perfil);
    _sobrenomeCtrl.clear();
    _emailCtrl.text =
        '${_perfil['email'] ?? AuthService.usuarioLogado?.email ?? ''}';
    _telefoneCtrl.text = '${_perfil['telefone'] ?? ''}';
    _nascimentoCtrl.text = '${_perfil['dataNascimento'] ?? ''}';
    _crmCtrl.text = '${_perfil['crm'] ?? ''}';
    _especialidadeCtrl.text = '${_perfil['especialidade'] ?? ''}';
    _clinicaNomeCtrl.text = '${_perfil['nomeClinica'] ?? ''}';
    _foto = PerfilService.foto(_perfil);
  }

  Future<void> _carregarDados() async {
    try {
      final perfil = await PerfilService.carregar(atualizar: true);
      if (!mounted) return;
      setState(() {
        _perfil = perfil;
        _preencherDados();
      });
    } catch (e) {
      if (mounted) _snack('$e');
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
      _crmCtrl,
      _especialidadeCtrl,
      _clinicaNomeCtrl,
      _senhaAtualCtrl,
      _novaSenhaCtrl,
      _confirmSenhaCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfil() async {
    try {
      await PerfilService.salvarPerfil({
        'nome': _nomeCtrl.text.trim(),
        'sobrenome': null,
        'email': _emailCtrl.text.trim(),
        'telefone': _telefoneCtrl.text.trim(),
        'dataNascimento': _nascimentoCtrl.text.trim(),
        'endereco': _perfil['endereco'],
      });
      if (mounted) setState(() => _editandoPerfil = false);
      _snack('Perfil atualizado com sucesso!');
    } catch (erro) {
      if (mounted) _snack('Não foi possível concluir: $erro');
    }
  }

  Future<void> _salvarProfissional() async {
    try {
      await PerfilService.salvarProfissional({
        'crm': _crmCtrl.text.trim(),
        'especialidade': _especialidadeCtrl.text.trim(),
        'nomeClinica': _clinicaNomeCtrl.text.trim(),
        'rqe': _perfil['rqe'],
        'subespecialidades': _perfil['subespecialidades'],
        'tipoAtendimento': _perfil['tipoAtendimento'],
        'enderecoClinica': _perfil['enderecoClinica'],
        'tempoConsulta': _perfil['tempoConsulta'],
        'valorConsulta': _perfil['valorConsulta'],
      });
      if (mounted) setState(() => _editandoProfissional = false);
      _snack('Informações profissionais atualizadas!');
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
    final iniciais = _nomeCtrl.text.isNotEmpty
        ? _nomeCtrl.text.substring(0, 1).toUpperCase() +
              (_sobrenomeCtrl.text.isNotEmpty
                  ? _sobrenomeCtrl.text.substring(0, 1).toUpperCase()
                  : '')
        : 'DR';

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
            child: _foto != null
                ? null
                : Text(
                    iniciais,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
      onTap: () => setState(() => _abaSelecionada = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? _verde : _corFundo,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _abas[index]['icone'] as IconData,
              color: sel ? Colors.white : Colors.grey[500],
              size: 17,
            ),
            const SizedBox(width: 7),
            Text(
              _abas[index]['titulo'] as String,
              style: TextStyle(
                fontSize: 12.5,
                color: sel ? Colors.white : Colors.grey[600],
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
        return _abaInfoProfissional();
      case 2:
        return _abaSeguranca();
      default:
        return _abaPerfil();
    }
  }

  Widget _scaffoldAba({
    required String titulo,
    required String subtitulo,
    required bool editando,
    required VoidCallback onEditar,
    required VoidCallback onSalvar,
    required VoidCallback onCancelar,
    required Widget child,
    bool mostrarBotaoEditar = true,
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
                      style: const TextStyle(
                        color: _oliva,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (mostrarBotaoEditar && !editando)
                ElevatedButton.icon(
                  onPressed: onEditar,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Editar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _oliva,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              else if (mostrarBotaoEditar)
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: onCancelar,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onSalvar,
                      icon: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _verde,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (editando)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _verde.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: _verde, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Modo de edição ativo — altere os campos e salve.',
                      style: TextStyle(color: _oliva, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
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
      subtitulo: 'Visualize e edite suas informações pessoais',
      editando: _editandoPerfil,
      onEditar: () => setState(() => _editandoPerfil = true),
      onSalvar: _salvarPerfil,
      onCancelar: () {
        _preencherDados();
        setState(() => _editandoPerfil = false);
      },
      child: Column(
        children: [
          _cardSecao(
            titulo: 'Foto de Perfil',
            subtitulo: 'Atualize sua foto de perfil visível no sistema',
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _teal.withValues(alpha: 0.3),
                  backgroundImage: _foto == null ? null : MemoryImage(_foto!),
                  child: _foto != null
                      ? null
                      : Text(
                          _nomeCtrl.text.isNotEmpty
                              ? _nomeCtrl.text.substring(0, 1).toUpperCase() +
                                    (_sobrenomeCtrl.text.isNotEmpty
                                        ? _sobrenomeCtrl.text
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : '')
                              : 'DR',
                          style: const TextStyle(
                            color: _oliva,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _editandoPerfil ? _selecionarFoto : null,
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: _editandoPerfil ? _oliva : Colors.grey,
                  ),
                  label: Text(
                    'Alterar Foto',
                    style: TextStyle(
                      color: _editandoPerfil ? _oliva : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _editandoPerfil
                          ? _corBordaCampo
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Flexible(
                  child: Text(
                    'JPG, PNG ou GIF. Máximo 5MB.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _cardSecao(
            titulo: 'Informações Pessoais',
            subtitulo: 'Mantenha suas informações pessoais atualizadas',
            child: Column(
              children: [
                _campo(
                  'Nome completo:',
                  _nomeCtrl,
                  habilitado: _editandoPerfil,
                ),
                const SizedBox(height: 12),
                _campo('E-mail:', _emailCtrl, habilitado: _editandoPerfil),
                const SizedBox(height: 12),
                _campo('Telefone:', _telefoneCtrl, habilitado: _editandoPerfil),
                const SizedBox(height: 12),
                _campo(
                  'Data de Nascimento:',
                  _nascimentoCtrl,
                  habilitado: _editandoPerfil,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _abaInfoProfissional() {
    return _scaffoldAba(
      titulo: 'Informações Profissionais',
      subtitulo: 'Visualize e edite seus dados de registro e clínica',
      editando: _editandoProfissional,
      onEditar: () => setState(() => _editandoProfissional = true),
      onSalvar: _salvarProfissional,
      onCancelar: () {
        _preencherDados();
        setState(() => _editandoProfissional = false);
      },
      child: Column(
        children: [
          _cardSecao(
            titulo: 'Credenciais Profissionais',
            subtitulo: 'Informações sobre seu registro e especialidades',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _campo(
                        'CRM:',
                        _crmCtrl,
                        habilitado: _editandoProfissional,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 12),
                _campo(
                  'Especialidade:',
                  _especialidadeCtrl,
                  habilitado: _editandoProfissional,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _cardSecao(
            titulo: 'Informações da Clínica',
            subtitulo: 'Local de atendimento',
            child: Column(
              children: [
                _campo(
                  'Nome da Clínica/Hospital:',
                  _clinicaNomeCtrl,
                  habilitado: _editandoProfissional,
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
      titulo: 'Segurança',
      subtitulo: 'Gerencie sua senha e permissões de acesso',
      editando: false,
      mostrarBotaoEditar: false,
      onEditar: () {},
      onSalvar: () {},
      onCancelar: () {},
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
            color: Colors.black.withValues(alpha: 0.04),
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
            style: const TextStyle(
              color: _oliva,
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

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    bool habilitado = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: _corTexto)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          enabled: habilitado,
          style: TextStyle(
            fontSize: 14,
            color: habilitado ? _corTexto : _corSubtexto,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: habilitado ? _corCampo : _corFundo,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            suffixIcon: !habilitado && ctrl.text.isNotEmpty
                ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _corBordaCampo),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _corBordaCampo),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
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
        Text(label, style: TextStyle(fontSize: 13, color: _corTexto)),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
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
  ) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}
