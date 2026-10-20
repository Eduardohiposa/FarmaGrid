import '../widgets/carregamento.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import '../services/auth_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

const Color _verde = Color(0xFF59AA53);
const Color _oliva = Color(0xFF136A48);
const Color _teal = Color(0xFF7FC6BB);
const Color _fundo = Color.fromARGB(255, 245, 245, 245);
const Color _verdeFraco = Color(0xFFE8F5E9);

class TelaCadastroPaciente extends StatefulWidget {
  const TelaCadastroPaciente({super.key});

  @override
  State<TelaCadastroPaciente> createState() => _TelaCadastroPacienteState();
}

class _TelaCadastroPacienteState extends State<TelaCadastroPaciente> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _cpfCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final TextEditingController _telefoneCtrl = TextEditingController();
  final TextEditingController _dataNascimentoCtrl = TextEditingController();
  final TextEditingController _cepCtrl = TextEditingController();
  final TextEditingController _ruaCtrl = TextEditingController();
  final TextEditingController _bairroCtrl = TextEditingController();
  final TextEditingController _cidadeCtrl = TextEditingController();
  final TextEditingController _estadoCtrl = TextEditingController();
  final TextEditingController _numeroCtrl = TextEditingController();
  final TextEditingController _tipoSanguineoCtrl = TextEditingController();
  final TextEditingController _contatoEmergenciaNomeCtrl =
      TextEditingController();
  final TextEditingController _contatoEmergenciaTelefoneCtrl =
      TextEditingController();

  bool _possuiPlano = false;
  bool _aceitaTermos = false;

  bool _receberNotif = false;

  String _genero = "";

  bool _senhaVisivel = false;

  // aplica mascaras pra telefone, cpf, data e cep ja sairem formatados enquanto digita
  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _contatoEmergenciaTelefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _dataMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Future<void> _cadastrar() async {
    if (_genero.isEmpty) {
      _alertaErro("Selecione o gênero.");
      return;
    }
    if (!_aceitaTermos) {
      _alertaErro("Você deve aceitar os Termos de Uso.");
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        await AuthService.cadastrarPaciente(
          email: _emailCtrl.text.trim(),
          senha: _senhaCtrl.text,
          nome: _nomeCtrl.text.trim(),
          cpf: _cpfMask.getUnmaskedText(),
          dataNascimento: _dataNascimentoCtrl.text.trim(),
          sexo: _genero,
          rua: _ruaCtrl.text.trim(),
          numCasa: int.tryParse(_numeroCtrl.text.trim()),
          bairro: _bairroCtrl.text.trim(),
          cidade: _cidadeCtrl.text.trim(),
          estado: _estadoCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim(),
          cep: _cepCtrl.text.trim(),
          tipoSanguineo: _tipoSanguineoCtrl.text.trim(),
          contatoEmergenciaNome: _contatoEmergenciaNomeCtrl.text.trim(),
          contatoEmergenciaTelefone: _contatoEmergenciaTelefoneCtrl.text.trim(),
        );
      } on ApiException catch (e) {
        _alertaErro(e.mensagem);
        return;
      }

      _limpar();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: _verde),
              SizedBox(width: 8),
              Text("Cadastro realizado!"),
            ],
          ),
          content: const Text(
            "Sua conta foi criada com sucesso.\nFaça login para continuar.",
          ),
          actions: [
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(color: _verde, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => TelaLogin()),
                );
              },
            ),
          ],
        ),
      );
    }
  }

  void _alertaErro(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Atenção"),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text(
              "OK",
              style: TextStyle(color: _verde, fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarData() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      setState(() {
        _dataNascimentoCtrl.text =
            "${data.day.toString().padLeft(2, '0')}/"
            "${data.month.toString().padLeft(2, '0')}/"
            "${data.year}";
      });
    }
  }

  void _limpar() {
    _nomeCtrl.clear();
    _cpfCtrl.clear();
    _emailCtrl.clear();
    _senhaCtrl.clear();
    _confirmCtrl.clear();
    _telefoneCtrl.clear();
    _dataNascimentoCtrl.clear();
    _tipoSanguineoCtrl.clear();
    _contatoEmergenciaNomeCtrl.clear();
    _contatoEmergenciaTelefoneCtrl.clear();
    setState(() {
      _possuiPlano = false;
      _aceitaTermos = false;
      _receberNotif = false;
      _genero = "";
    });
  }

  Future<void> _buscarCep() async {
    // consulta um servico externo de cep e preenche o endereco quando encontra os dados
    final cep = _cepCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) return;

    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await Carregamento.executar(
        'Consultando CEP...',
        () => http.get(url).timeout(const Duration(seconds: 15)),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['erro'] == true) {
          _alertaErro('CEP não encontrado.');
          return;
        }

        setState(() {
          _ruaCtrl.text = data['logradouro'] ?? '';
          _bairroCtrl.text = data['bairro'] ?? '';
          _cidadeCtrl.text = data['localidade'] ?? '';
          _estadoCtrl.text = data['uf'] ?? '';
        });
      } else {
        _alertaErro('Erro ao consultar o CEP.');
      }
    } catch (e) {
      if (!mounted) return;
      _alertaErro('Não foi possível consultar o CEP.');
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmCtrl.dispose();
    _telefoneCtrl.dispose();
    _dataNascimentoCtrl.dispose();
    _cepCtrl.dispose();
    _ruaCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _numeroCtrl.dispose();
    _tipoSanguineoCtrl.dispose();
    _contatoEmergenciaNomeCtrl.dispose();
    _contatoEmergenciaTelefoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,
      body: Column(
        children: [
          _cabecalho(context),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _secao("Dados Pessoais", Icons.person_outline),
                    const SizedBox(height: 12),

                    _campo(
                      controller: _nomeCtrl,
                      label: "Nome completo",
                      icone: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Campo obrigatório!";
                        if (v.trim().length < 3) return "Nome muito curto.";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _cpfCtrl,
                      label: "CPF",
                      icone: Icons.badge_outlined,
                      teclado: TextInputType.number,
                      inputFormatters: [_cpfMask],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Campo obrigatório!";
                        }
                        if (_cpfMask.getUnmaskedText().length != 11) {
                          return "CPF inválido. Digite 11 dígitos.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _emailCtrl,
                      label: "E-mail",
                      icone: Icons.email_outlined,
                      teclado: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Campo obrigatório!";
                        if (!v.contains("@") || !v.contains("."))
                          return "E-mail inválido.";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _telefoneCtrl,
                      label: "Telefone / WhatsApp",
                      icone: Icons.phone_outlined,
                      teclado: TextInputType.phone,
                      inputFormatters: [_telefoneMask],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Campo obrigatório!";
                        if (_telefoneMask.getUnmaskedText().length < 10)
                          return "Telefone inválido.";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: _selecionarData,
                      child: AbsorbPointer(
                        child: _campo(
                          controller: _dataNascimentoCtrl,
                          label: "Data de nascimento",
                          icone: Icons.cake_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Campo obrigatório!";
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _cepCtrl,
                      label: "CEP",
                      icone: Icons.location_on_outlined,
                      teclado: TextInputType.number,
                      inputFormatters: [_cepMask],
                      onChanged: (_) => _buscarCep(),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Campo obrigatório!";
                        if (_cepCtrl.text
                                .replaceAll(RegExp(r'[^0-9]'), '')
                                .length !=
                            8) {
                          return "CEP inválido.";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _campo(
                            controller: _ruaCtrl,
                            label: "Rua",
                            icone: Icons.home_outlined,
                            validator: (v) => null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _campo(
                            controller: _numeroCtrl,
                            label: "Nº",
                            icone: Icons.numbers_outlined,
                            teclado: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return "Obrigatório!";
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _campo(
                      controller: _bairroCtrl,
                      label: "Bairro",
                      icone: Icons.location_city_outlined,
                      validator: (v) => null,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _campo(
                            controller: _cidadeCtrl,
                            label: "Cidade",
                            icone: Icons.location_city_outlined,
                            validator: (v) => null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _campo(
                            controller: _estadoCtrl,
                            label: "UF",
                            icone: Icons.map_outlined,
                            validator: (v) => null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _campoSenha(
                      controller: _senhaCtrl,
                      label: "Senha",
                      visivel: _senhaVisivel,
                      onToggle: () =>
                          setState(() => _senhaVisivel = !_senhaVisivel),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Campo obrigatório!";
                        if (v.length < 6)
                          return "Senha deve ter pelo menos 6 caracteres.";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _campoSenha(
                      controller: _confirmCtrl,
                      label: "Confirmar senha",
                      visivel: _senhaVisivel,
                      onToggle: () =>
                          setState(() => _senhaVisivel = !_senhaVisivel),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Campo obrigatório!";
                        if (v != _senhaCtrl.text)
                          return "As senhas não coincidem.";
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    _secao("Gênero", Icons.wc_outlined),
                    const SizedBox(height: 8),
                    _cardOpcoes(
                      child: Column(
                        children: ["Masculino", "Feminino", "Outro"]
                            .map(
                              (op) => RadioListTile<String>(
                                title: Text(
                                  op,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: op,
                                groupValue: _genero,
                                activeColor: _verde,
                                dense: true,
                                onChanged: (v) => setState(() => _genero = v!),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _secao("Dados de Saúde", Icons.favorite_outline),
                    const SizedBox(height: 8),
                    _cardOpcoes(
                      child: Column(
                        children: [
                          _campo(
                            controller: _tipoSanguineoCtrl,
                            label: "Tipo sanguíneo",
                            icone: Icons.bloodtype_outlined,
                            validator: (v) => null,
                          ),
                          const SizedBox(height: 14),
                          _campo(
                            controller: _contatoEmergenciaNomeCtrl,
                            label: "Nome do contato de emergência",
                            icone: Icons.contact_emergency_outlined,
                            validator: (v) => null,
                          ),
                          const SizedBox(height: 14),
                          _campo(
                            controller: _contatoEmergenciaTelefoneCtrl,
                            label: "Telefone do contato de emergência",
                            icone: Icons.phone_in_talk_outlined,
                            teclado: TextInputType.phone,
                            inputFormatters: [_contatoEmergenciaTelefoneMask],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              if (_contatoEmergenciaTelefoneMask
                                      .getUnmaskedText()
                                      .length <
                                  10) {
                                return "Telefone inválido.";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 8),

                    const SizedBox(height: 20),

                    _secao(
                      "Saúde & Preferências",
                      Icons.health_and_safety_outlined,
                    ),
                    const SizedBox(height: 8),
                    _cardOpcoes(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          CheckboxListTile(
                            title: const Text(
                              "Aceito os Termos de Uso",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text(
                              "Li e concordo com a política de privacidade",
                            ),
                            secondary: const Icon(
                              Icons.gavel_outlined,
                              color: _verde,
                            ),
                            tileColor: _verdeFraco,
                            activeColor: _verde,
                            value: _aceitaTermos,
                            onChanged: (v) =>
                                setState(() => _aceitaTermos = v!),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _verde,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Cadastrar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Já tenho uma conta",
                          style: TextStyle(
                            color: _oliva,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_verde, _teal],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Criar conta",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                "Cadastro de Paciente",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secao(String titulo, IconData icone) {
    return Row(
      children: [
        Icon(icone, color: _verde, size: 18),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF2E2E2E),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _cardOpcoes({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    ValueChanged<String>? onChanged,
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icone, color: _verde, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _verde, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _campoSenha({
    required TextEditingController controller,
    required String label,
    required bool visivel,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visivel,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline, color: _verde, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            visivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _verde, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
