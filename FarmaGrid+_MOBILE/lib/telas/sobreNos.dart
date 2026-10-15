import '../models/lista_models.dart';
import 'package:flutter/material.dart';

class TelaSobreNos extends StatelessWidget {
  const TelaSobreNos({super.key});

  static final List<MembroEquipe> _devs = List<MembroEquipe>.from(
    [
      {
        'nome': 'Ana Carolina Lanzoni',
        'curso': 'Análise e Desenvolvimento de Sistemas',
        'ra': 'RA: 204057',
        'descricao':
            'Desenvolvedora mobile em Flutter, responsável pela concepção e implementação da aplicação móvel do FarmaGrid+. Atuou na definição da arquitetura das telas, criação do design, desenvolvimento das funcionalidades e otimização da experiência do usuário, garantindo uma navegação intuitiva e eficiente.',
        'imagemAsset': 'assets/images/carol.jpeg',
        'github': 'github.com/lanzonicaroll',
        'linkedin': '-',
      },
      {
        'nome': 'Heloisa Pola Argentin',
        'curso': 'Análise e Desenvolvimento de Sistemas',
        'ra': 'RA: 204215',
        'descricao':
            'Desenvolvedora desktop responsável pela criação e manutenção da aplicação voltada ao ambiente administrativo do FarmaGrid+. Atuou no desenvolvimento de funcionalidades estratégicas, integração com os demais sistemas e implementação de recursos que contribuem para a gestão e operação da plataforma.',
        'imagemAsset': 'assets/images/heloisa.jpeg',
        'github': 'github.com/Heloisa012',
        'linkedin': '-',
      },
      {
        'nome': 'Gabriel Andreolli Aires',
        'curso': 'Análise e Desenvolvimento de Sistemas',
        'ra': 'RA: 204062',
        'descricao':
            'Desenvolvedor responsável pela estrutura web e pelos serviços backend do FarmaGrid+. Liderou a construção das APIs, modelagem do banco de dados e implementação das regras de negócio, assegurando a comunicação segura e eficiente entre os diferentes módulos da plataforma.',
        'imagemAsset': 'assets/images/aires.jpeg',
        'github': 'github.com/AiresGabrielAndreolli',
        'linkedin': '-',
      },
    ].map((d) => MembroEquipe.fromJson(d)),
  );

  static const Color _verde = Color(0xFF59AA53);
  static const Color _oliva = Color(0xFF136A48);
  static const Color _teal = Color(0xFF7FC6BB);
  static const Color _fundo = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,
      body: Column(
        children: [
          _cabecalho(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _cardProjeto(),
                  const SizedBox(height: 30),
                  const Text(
                    "Nossa Equipe",
                    style: TextStyle(
                      color: Color(0xFF2E2E2E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${_devs.length} desenvolvedores",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    primary: false,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _devs.length,
                    itemBuilder: (context, index) {
                      return _cardDev(_devs[index]);
                    },
                  ),
                  const SizedBox(height: 30),
                  _rodape(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 60,
            left: 25,
            right: 25,
            bottom: 28,
          ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Sobre Nós",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Conheça a equipe por trás do FarmaGrid+",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.code, color: _verde, size: 18),
                SizedBox(width: 8),
                Text(
                  "Projeto Integrador — FarmaGrid+",
                  style: TextStyle(
                    color: _oliva,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardProjeto() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _verde.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _verde.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital_outlined,
                  color: _oliva,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FarmaGrid+",
                      style: TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Saúde digital integrada",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "O FarmaGrid+ é uma plataforma mobile que conecta pacientes, "
            "médicos e farmácias em um único ecossistema digital. Desenvolvido "
            "como Projeto Integrador do curso de DS, o app oferece teleconsultas, "
            "prescrições digitais, localização de farmácias parceiras e muito mais.",
            style: TextStyle(
              color: Color(0xFF444444),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip("Flutter", Icons.phone_android),
              _chip("Dart", Icons.code),
              _chip("DS", Icons.school_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String texto, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _teal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 13, color: _oliva),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              color: _oliva,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardDev(MembroEquipe dev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_verde, _teal],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: ClipOval(
                    child: Image.asset(dev.imagemAsset, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dev.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  dev.ra,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_outlined, color: _verde, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dev.curso,
                        style: const TextStyle(
                          color: _oliva,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  dev.descricao,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _linkBotao(
                        Icons.code,
                        "GitHub",
                        dev.github,
                        _oliva,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _linkBotao(
                        Icons.work_outline,
                        "LinkedIn",
                        dev.linkedin,
                        _teal,
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

  Widget _linkBotao(IconData icone, String label, String url, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: cor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rodape() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _oliva.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.favorite, color: _verde, size: 22),
          SizedBox(height: 8),
          Text(
            "Desenvolvido com dedicação",
            style: TextStyle(
              color: _oliva,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Projeto Integrador — DS\nFarmaGrid+ © 2026",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }
}
