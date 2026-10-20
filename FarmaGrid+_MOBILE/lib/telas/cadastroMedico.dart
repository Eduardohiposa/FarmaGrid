import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import '../services/auth_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const Color _verde = Color(0xFF59AA53);
const Color _oliva = Color(0xFF136A48);
const Color _teal = Color(0xFF7FC6BB);
const Color _fundo = Color.fromARGB(255, 245, 245, 245);
const Color _verdeFraco = Color(0xFFE8F5E9);

class TelaCadastroMedico extends StatefulWidget {
  const TelaCadastroMedico({super.key});

  @override
  State<TelaCadastroMedico> createState() => _TelaCadastroMedicoState();
}

class _TelaCadastroMedicoState extends State<TelaCadastroMedico> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _crmCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final TextEditingController _especialidadeCtrl = TextEditingController();
  final TextEditingController _clinicaCtrl = TextEditingController();
  final TextEditingController _telefoneCtrl = TextEditingController();
  final TextEditingController _dataNascimentoCtrl = TextEditingController();
  final TextEditingController _enderecoCtrl = TextEditingController();
  final TextEditingController _enderecoClinicaCtrl = TextEditingController();
  final TextEditingController _rqeCtrl = TextEditingController();
  final TextEditingController _subespecialidadesCtrl = TextEditingController();
  final TextEditingController _horarioInicioCtrl = TextEditingController();
  final TextEditingController _horarioTerminoCtrl = TextEditingController();
  final TextEditingController _tempoConsultaCtrl = TextEditingController();
  final TextEditingController _valorConsultaCtrl = TextEditingController();

  bool _atendeTeleconsulta = false;
  bool _aceitaTermos = false;

  bool _receberNotif = false;

  String _turnoAtendimento = "";
  String _tipoAtendimento = "";

  bool _senhaVisivel = false;

  // mascaras pra crm, rqe e telefone ja sairem formatados enquanto digita
  final _crmMask = MaskTextInputFormatter(
    mask: '######/AA',
    filter: {'#': RegExp(r'[0-9]'), 'A': RegExp(r'[A-Za-z]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _rqeMask = MaskTextInputFormatter(
    mask: '######/AA',
    filter: {'#': RegExp(r'[0-9]'), 'A': RegExp(r'[A-Za-z]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  Future<void> _cadastrar() async {
    if (_turnoAtendimento.isEmpty) {
      _alertaErro("Selecione o turno de atendimento.");
      return;
    }
    if (_tipoAtendimento.isEmpty) {
      _alertaErro("Selecione o tipo de atendimento.");
      return;
    }
    if (!_aceitaTermos) {
      _alertaErro("Você deve aceitar os Termos de Uso.");
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        await AuthService.cadastrarMedico(
          email: _emailCtrl.text.trim(),
          senha: _senhaCtrl.text,
          nome: _nomeCtrl.text.trim(),
          crm: _crmCtrl.text.trim(),
          especialidade: _especialidadeCtrl.text.trim(),
          clinica: _clinicaCtrl.text.trim(),
          enderecoClinica: _enderecoClinicaCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim(),
          endereco: _enderecoCtrl.text.trim(),
          dataNascimento: _dataParaApi(_dataNascimentoCtrl.text.trim()),
          rqe: _rqeCtrl.text.trim(),
          subespecialidades: _subespecialidadesCtrl.text.trim(),
          horarioInicio: _horarioInicioCtrl.text.trim(),
          horarioTermino: _horarioTerminoCtrl.text.trim(),
          tempoConsulta: _tempoConsultaCtrl.text.trim(),
          valorConsulta: _valorConsultaCtrl.text.trim().replaceAll(',', '.'),
          tipoAtendimento: _tipoAtendimento,
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
            "Sua conta médica foi criada com sucesso.\nFaça login para continuar.",
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
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
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

  void _limpar() {
    _crmCtrl.clear();
    _emailCtrl.clear();
    _nomeCtrl.clear();
    _senhaCtrl.clear();
    _confirmCtrl.clear();
    _especialidadeCtrl.clear();
    _clinicaCtrl.clear();
    _telefoneCtrl.clear();
    _dataNascimentoCtrl.clear();
    _enderecoCtrl.clear();
    _enderecoClinicaCtrl.clear();
    _rqeCtrl.clear();
    _subespecialidadesCtrl.clear();
    _horarioInicioCtrl.clear();
    _horarioTerminoCtrl.clear();
    _tempoConsultaCtrl.clear();
    _valorConsultaCtrl.clear();
    setState(() {
      _atendeTeleconsulta = false;
      _aceitaTermos = false;
      _receberNotif = false;
      _turnoAtendimento = "";
      _tipoAtendimento = "";
    });
  }

  @override
  void dispose() {
    _crmCtrl.dispose();
    _emailCtrl.dispose();
    _nomeCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmCtrl.dispose();
    _especialidadeCtrl.dispose();
    _clinicaCtrl.dispose();
    _telefoneCtrl.dispose();
    _dataNascimentoCtrl.dispose();
    _enderecoCtrl.dispose();
    _enderecoClinicaCtrl.dispose();
    _rqeCtrl.dispose();
    _subespecialidadesCtrl.dispose();
    _horarioInicioCtrl.dispose();
    _horarioTerminoCtrl.dispose();
    _tempoConsultaCtrl.dispose();
    _valorConsultaCtrl.dispose();
    super.dispose();
  }

  String _dataParaApi(String data) {
    final partes = data.split('/');
    if (partes.length != 3) return data;
    return '${partes[2]}-${partes[1]}-${partes[0]}';
  }

  Future<void> _selecionarDataNascimento() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime(1985, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      setState(() {
        _dataNascimentoCtrl.text =
            '${data.day.toString().padLeft(2, '0')}/'
            '${data.month.toString().padLeft(2, '0')}/'
            '${data.year}';
      });
    }
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
                    _secao("Dados Profissionais", Icons.badge_outlined),
                    const SizedBox(height: 12),

                    _campo(
                      controller: _crmCtrl,
                      label: "CRM (ex: 123456/SP)",
                      icone: Icons.badge_outlined,
                      inputFormatters: [_crmMask],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Campo obrigatório!";
                        if (_crmMask.getUnmaskedText().length < 8)
                          return "CRM inválido.";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

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

                    GestureDetector(
                      onTap: _selecionarDataNascimento,
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
                      controller: _enderecoCtrl,
                      label: "Endereço residencial do médico",
                      icone: Icons.location_on_outlined,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _especialidadeCtrl,
                      label: "Especialidade (ex: Cardiologia)",
                      icone: Icons.local_hospital_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Campo obrigatório!";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _rqeCtrl,
                      label: "RQE",
                      icone: Icons.verified_outlined,
                      inputFormatters: [_rqeMask],
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _subespecialidadesCtrl,
                      label: "Subespecialidades",
                      icone: Icons.account_tree_outlined,
                      validator: (v) => null,
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _clinicaCtrl,
                      label: "Clínica / Hospital",
                      icone: Icons.business_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Campo obrigatório!";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _campo(
                      controller: _enderecoClinicaCtrl,
                      label: "Endereço da clínica / hospital",
                      icone: Icons.location_city_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "Campo obrigatório!";
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

                    Row(
                      children: [
                        Expanded(
                          child: _campo(
                            controller: _tempoConsultaCtrl,
                            label: "Duração da consulta",
                            icone: Icons.timelapse_outlined,
                            validator: (v) => null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            controller: _valorConsultaCtrl,
                            label: "Valor (RS)",
                            icone: Icons.payments_outlined,
                            teclado: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) => null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    _secao("Dados de Acesso", Icons.lock_outline),
                    const SizedBox(height: 12),

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

                    _campoSenha(
                      controller: _senhaCtrl,
                      label: "Senha",
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
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Campo obrigatório!";
                        if (v != _senhaCtrl.text)
                          return "As senhas não coincidem.";
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    _secao(
                      "Tipo de Atendimento",
                      Icons.medical_services_outlined,
                    ),
                    const SizedBox(height: 8),
                    _cardOpcoes(
                      child: Column(
                        children:
                            [
                                  "Presencial",
                                  "Teleconsulta",
                                  "Presencial e teleconsulta",
                                ]
                                .map(
                                  (op) => RadioListTile<String>(
                                    title: Text(
                                      op,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    value: op,
                                    groupValue: _tipoAtendimento,
                                    activeColor: _verde,
                                    dense: true,
                                    onChanged: (v) => setState(() {
                                      _tipoAtendimento = v!;
                                      _atendeTeleconsulta = v != "Presencial";
                                    }),
                                  ),
                                )
                                .toList(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _secao("Turno de Atendimento", Icons.schedule_outlined),
                    const SizedBox(height: 8),
                    _cardOpcoes(
                      child: Column(
                        children: ["Manhã", "Tarde", "Integral"]
                            .map(
                              (op) => RadioListTile<String>(
                                title: Text(
                                  op,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: op,
                                groupValue: _turnoAtendimento,
                                activeColor: _verde,
                                dense: true,
                                onChanged: (v) =>
                                    setState(() => _turnoAtendimento = v!),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _campo(
                            controller: _horarioInicioCtrl,
                            label: "Início (HH:mm)",
                            icone: Icons.login_outlined,
                            teclado: TextInputType.datetime,
                            validator: (v) => null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            controller: _horarioTerminoCtrl,
                            label: "Fim (HH:mm)",
                            icone: Icons.logout_outlined,
                            teclado: TextInputType.datetime,
                            validator: (v) => null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 20),

                    _secao("Preferências & Termos", Icons.settings_outlined),
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
                "Cadastro de Médico",
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
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      inputFormatters: inputFormatters,
      validator: validator,
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
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_senhaVisivel,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline, color: _verde, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _senhaVisivel
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
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
