import 'package:farmagrid/widgets/carregamento.dart';
import 'package:flutter/material.dart';
import '../../models/paciente_models.dart';
import '../../services/paciente_service.dart';

class TelaReceitasProntuarios extends StatefulWidget {
  @override
  _TelaReceitasProntuariosState createState() =>
      _TelaReceitasProntuariosState();
}

class _TelaReceitasProntuariosState extends State<TelaReceitasProntuarios> {
  bool exibirReceitas = true;
  bool _carregando = true;
  String? _erro;
  List<ReceitaPaciente> _receitas = const [];
  List<ProntuarioPaciente> _prontuarios = const [];

  final Color corVerdePrimario = const Color(0xFF59AA53);
  final Color corCardBege = const Color.fromARGB(255, 245, 245, 245);
  final Color corVerdeBotao = const Color(0xFF59AA53);

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
      // busca receitas e prontuarios juntos pra nao esperar cada chamada separada
      final resultados = await Future.wait([
        PacienteService.listarReceitas(),
        PacienteService.listarProntuarios(),
      ]);
      if (mounted)
        setState(() {
          _receitas = resultados[0] as List<ReceitaPaciente>;
          _prontuarios = resultados[1] as List<ProntuarioPaciente>;
        });
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _construirCabecalhoSuperior(),
          const SizedBox(height: 20),
          _construirSeletorTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _conteudo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCabecalhoSuperior() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [corVerdePrimario, corVerdePrimario.withValues(alpha: 0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Receitas e Prontuários",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: corCardBege,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: corVerdePrimario.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history_edu,
                    color: corVerdePrimario,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Histórico Médico",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    Text(
                      "${_receitas.where((r) => r.status.toLowerCase() == 'ativa').length} receita(s) ativa(s)",
                      style: const TextStyle(color: Colors.grey),
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

  Widget _construirSeletorTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => exibirReceitas = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: exibirReceitas ? corVerdePrimario : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "Receitas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: exibirReceitas ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => exibirReceitas = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !exibirReceitas
                      ? corVerdePrimario
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "Prontuários",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !exibirReceitas ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteudo() {
    if (_carregando) return const CartaoCarregamento();
    if (_erro != null)
      return Center(
        child: TextButton(
          onPressed: _carregar,
          child: Text('$_erro\nTentar novamente'),
        ),
      );
    if (exibirReceitas) {
      if (_receitas.isEmpty)
        return const Center(child: Text('Nenhuma receita encontrada.'));
      return ListView.builder(
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _receitas.length,
        itemBuilder: (context, index) {
          return _cardReceita(_receitas[index]);
        },
      );
    }
    if (_prontuarios.isEmpty)
      return const Center(child: Text('Nenhum prontuário encontrado.'));
    return ListView.builder(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _prontuarios.length,
      itemBuilder: (context, index) {
        return _cardProntuario(_prontuarios[index]);
      },
    );
  }

  Widget _cardReceita(ReceitaPaciente receita) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: corVerdePrimario.withValues(alpha: 0.2),
                child: Icon(Icons.medication, color: corVerdePrimario),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Receita médica",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text("FarmaGrid+", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _tagAtiva(receita.status),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                receita.dataPrescricao.isEmpty
                    ? 'Data não informada'
                    : receita.dataPrescricao,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _blocoMedicamentos(receita),
          const SizedBox(height: 20),
          _botoesAcao(),
        ],
      ),
    );
  }

  Widget _cardProntuario(ProntuarioPaciente prontuario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: corVerdePrimario.withValues(alpha: 0.2),
                child: Icon(Icons.history_edu, color: corVerdePrimario),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prontuario.tipo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    "Registro médico",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                prontuario.data.isEmpty
                    ? 'Data não informada'
                    : prontuario.data,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoProntuario(
            "Diagnóstico:",
            prontuario.diagnostico.isEmpty
                ? 'Não informado'
                : prontuario.diagnostico,
          ),
          const SizedBox(height: 15),
          _infoProntuario(
            "Conduta:",
            prontuario.conduta.isEmpty ? 'Não informada' : prontuario.conduta,
            corFundo: Colors.blueGrey[50]!,
          ),
          const SizedBox(height: 20),
          _botoesAcao(),
        ],
      ),
    );
  }

  Widget _tagAtiva(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: corVerdeBotao,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.isEmpty ? "Ativa" : status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _blocoMedicamentos(ReceitaPaciente receita) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: corCardBege,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Medicamentos",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: corVerdePrimario,
            ),
          ),
          const SizedBox(height: 10),
          _itemMedicamento(
            receita.medicamento,
            receita.dosagem,
            "Duração: ${receita.duracao}",
          ),
        ],
      ),
    );
  }

  Widget _itemMedicamento(String nome, String dose, String duracao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nome,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        Text(dose, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          duracao,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _infoProntuario(
    String label,
    String conteudo, {
    Color corFundo = const Color(0xFFFDF9EC),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            conteudo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _botoesAcao() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text("Visualizar"),
            style: OutlinedButton.styleFrom(
              foregroundColor: corVerdeBotao,
              side: BorderSide(color: corVerdeBotao),
              shape: StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text("Baixar PDF"),
            style: ElevatedButton.styleFrom(
              backgroundColor: corVerdeBotao,
              foregroundColor: Colors.white,
              shape: StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
