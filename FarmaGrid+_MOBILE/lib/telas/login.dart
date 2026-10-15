import 'recuperar_senha.dart';
import 'package:flutter/material.dart';
import 'selecaoCadastro.dart';
import 'sobreNos.dart';
import 'telasPaciente/homePaciente.dart';
import 'telasMedico/home_medico.dart';
import '../services/auth_service.dart';
import '../services/perfil_service.dart';
import '../models/usuario_logado.dart';

const Color corFundoClaro = Color.fromARGB(255, 245, 245, 245);
const Color corVerdePrimario = Color(0xFF59AA53);
const Color corVerdeEscuro = Color(0xFF4F8946);
const Color corTeal = Color(0xFF63BFC4);

const TextStyle estiloTitulo = TextStyle(
  fontFamily: 'Inter',
  fontSize: 32,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();

  String _perfilSelecionado = 'Paciente';
  bool _senhaVisivel = false;
  bool _carregando = false;

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String email = _emailCtrl.text.trim();
    final String senha = _senhaCtrl.text;

    final int tipo = _perfilSelecionado == 'Paciente'
        ? TipoLogin.paciente
        : TipoLogin.medico;

    setState(() {
      _carregando = true;
    });

    try {
      final UsuarioLogado usuario = await AuthService.login(email, senha, tipo);

      try {
        await PerfilService.carregar(atualizar: true);
      } catch (_) {}

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Login realizado com sucesso!'),
            ],
          ),
          backgroundColor: corVerdePrimario,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      if (usuario.tipo == TipoLogin.paciente) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TelaHomePaciente()),
        );
      } else if (usuario.tipo == TipoLogin.medico) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TelaHomeMedico()),
        );
      } else {
        _mostrarErro(
          'Tipo de usuário ${usuario.tipo} não possui uma tela configurada.',
        );
      }
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarErro(e.mensagem);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarErro(
        'Não foi possível conectar ao servidor.\n'
        'Verifique sua conexão e tente novamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _abrirRecuperacao() async {
    final email = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaRecuperarSenha(emailInicial: _emailCtrl.text.trim()),
      ),
    );
    if (!mounted || email == null) return;
    setState(() {
      _emailCtrl.text = email;
      _senhaCtrl.clear();
    });
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Erro no login"),
          ],
        ),
        content: Text(mensagem),
        actions: [
          TextButton(
            child: const Text(
              "OK",
              style: TextStyle(
                color: corVerdePrimario,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: FloatingActionButton.small(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaSobreNos()),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.25),
          elevation: 0,
          tooltip: 'Sobre Nós',
          child: const Icon(Icons.info_outline, color: Colors.white, size: 22),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [corTeal, corVerdePrimario],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 15),
                Text(
                  "Bem-vindo ao\nFarmaGrid+",
                  textAlign: TextAlign.center,
                  style: estiloTitulo,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sua saúde digital integrada",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: corFundoClaro,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return "Campo obrigatório!";
                            if (!v.contains("@") || !v.contains("."))
                              return "E-mail inválido.";
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "E-mail",
                            labelStyle: const TextStyle(
                              color: corVerdeEscuro,
                              fontWeight: FontWeight.bold,
                            ),
                            suffixIcon: const Icon(
                              Icons.email_outlined,
                              color: corVerdeEscuro,
                            ),
                            filled: true,
                            fillColor: corVerdePrimario.withValues(alpha: 0.08),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: corVerdePrimario,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _senhaCtrl,
                          obscureText: !_senhaVisivel,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Campo obrigatório!";
                            if (v.length < 6)
                              return "Senha deve ter pelo menos 6 caracteres.";
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Senha",
                            labelStyle: const TextStyle(
                              color: corVerdeEscuro,
                              fontWeight: FontWeight.bold,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _senhaVisivel
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: corVerdeEscuro,
                              ),
                              onPressed: () => setState(
                                () => _senhaVisivel = !_senhaVisivel,
                              ),
                            ),
                            filled: true,
                            fillColor: corVerdePrimario.withValues(alpha: 0.08),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: corVerdePrimario,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _carregando ? null : _abrirRecuperacao,
                            child: const Text(
                              'Esqueceu sua senha?',
                              style: TextStyle(
                                color: corVerdeEscuro,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Entrar como:",
                          style: TextStyle(
                            color: corVerdeEscuro,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _itemPerfil(
                                Icons.person_outline,
                                "Paciente",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _itemPerfil(
                                Icons.medical_services,
                                "Médico/Clínica",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _entrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: corVerdePrimario,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _carregando
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Entrar",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Ainda não tem uma conta? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TelaSelecaoCadastro(),
                        ),
                      ),
                      child: const Text(
                        "Cadastre-se",
                        style: TextStyle(
                          color: corVerdeEscuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaSobreNos()),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: Colors.white54,
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Sobre Nós",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemPerfil(IconData icone, String rotulo) {
    bool sel = _perfilSelecionado == rotulo;
    return GestureDetector(
      onTap: () => setState(() => _perfilSelecionado = rotulo),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: sel ? corVerdePrimario : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          color: sel
              ? corVerdePrimario.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icone, color: sel ? corVerdePrimario : Colors.grey, size: 30),
            const SizedBox(height: 5),
            Text(
              rotulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: sel ? corVerdePrimario : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
