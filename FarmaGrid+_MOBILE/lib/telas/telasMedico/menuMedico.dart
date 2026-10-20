import 'package:flutter/material.dart';
import 'package:farmagrid/telas/telasMedico/configuracoesMedico.dart';
import 'package:farmagrid/telas/sobreNos.dart';
import '../../services/perfil_service.dart';
import '../../services/auth_service.dart';
import '../login.dart';

class DrawerMedico extends StatelessWidget {
  final Color corVerde, corOliva, corTeal, corCard, corTexto;

  const DrawerMedico({
    super.key,
    required this.corVerde,
    required this.corOliva,
    required this.corTeal,
    required this.corCard,
    required this.corTexto,
  });

  void _navegarParaAba(BuildContext context, int abaIndex) {
    final nav = Navigator.of(context, rootNavigator: true);
    nav.pop();
    nav.push(
      MaterialPageRoute(
        builder: (_) => TelaConfiguracoesMedico(abaInicial: abaIndex),
      ),
    );
  }

  void _navegarPara(BuildContext context, Widget tela) {
    final nav = Navigator.of(context, rootNavigator: true);
    nav.pop();
    nav.push(MaterialPageRoute(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    final perfil = PerfilService.atual.value;
    final foto = PerfilService.foto(perfil);
    final nome = PerfilService.nome(perfil);
    const bgColor = Colors.white;
    const subColor = Colors.grey;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: corVerde.withValues(alpha: 0.15),
                    backgroundImage: foto == null ? null : MemoryImage(foto),
                    child: foto == null
                        ? Icon(Icons.person, size: 50, color: corVerde)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Dr(a). ${nome.isEmpty ? 'Médico' : nome}",
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${perfil?['email'] ?? ''}',
                    style: TextStyle(color: subColor, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _badge("CRM ${perfil?['crm'] ?? ''}", corVerde, corOliva),
                      const SizedBox(width: 8),
                      _badge(
                        "CRM Ativo",
                        Colors.green.shade100,
                        Colors.green.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: corVerde.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: corVerde.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dados Profissionais",
                    style: TextStyle(
                      color: corOliva,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dadoProfissional(
                    Icons.badge_outlined,
                    "CRM",
                    '${perfil?['crm'] ?? ''}',
                  ),
                  const SizedBox(height: 10),
                  _dadoProfissional(
                    Icons.local_hospital_outlined,
                    "Especialidade",
                    '${perfil?['especialidade'] ?? ''}',
                  ),
                  const SizedBox(height: 10),
                  _dadoProfissional(
                    Icons.school_outlined,
                    "Formação",
                    '${perfil?['subespecialidades'] ?? 'Não informado'}',
                  ),
                  const SizedBox(height: 10),
                  _dadoProfissional(
                    Icons.work_outline,
                    "Experiência",
                    '${perfil?['tipoAtendimento'] ?? 'Não informado'}',
                  ),
                  const SizedBox(height: 10),
                  _dadoProfissional(
                    Icons.location_on_outlined,
                    "Consultório",
                    '${perfil?['nomeClinica'] ?? ''}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    '${perfil?['totalPacientes'] ?? 0}',
                    "Pacientes",
                    Icons.people_outline,
                    corVerde,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoCard(
                    '${perfil?['totalConsultas'] ?? 0}',
                    "Consultas",
                    Icons.calendar_today_outlined,
                    corTeal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoCard(
                    '${perfil?['totalReceitas'] ?? 0}',
                    "Receitas",
                    Icons.description_outlined,
                    corOliva,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _secao("Conta", subColor),
            _item(
              Icons.person_outline,
              "Meu Perfil",
              "Editar dados pessoais",
              corVerde,
              () => _navegarParaAba(context, 0),
            ),
            _item(
              Icons.work_outline,
              "Informações Profissionais",
              "Registro, especialidades e clínica",
              corVerde,
              () => _navegarParaAba(context, 1),
            ),
            _item(
              Icons.shield_outlined,
              "Segurança",
              "Alterar senha de acesso",
              corVerde,
              () => _navegarParaAba(context, 2),
            ),
            const SizedBox(height: 20),
            _secao("Preferências", subColor),
            _item(
              Icons.privacy_tip_outlined,
              "Privacidade",
              "Dados e permissões",
              corVerde,
              () => _navegarParaAba(context, 2),
            ),
            const SizedBox(height: 20),

            _secao("Suporte", subColor),
            _item(
              Icons.info_outline,
              "Sobre Nós",
              "Conheça a equipe",
              corVerde,
              () => _navegarPara(context, const TelaSobreNos()),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                await AuthService.logout();
                PerfilService.limpar();
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => TelaLogin()),
                  (_) => false,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Sair da conta",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _badge(String texto, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texto,
      style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );

  Widget _dadoProfissional(
    IconData icone,
    String label,
    String valor,
  ) => Row(
    children: [
      Icon(icone, size: 18, color: corVerde),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              color: const Color(0xFF2E2E2E),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _secao(String titulo, Color cor) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      titulo,
      style: TextStyle(
        color: cor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _infoCard(
    String valor,
    String label,
    IconData icone,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: cor.withValues(alpha: 0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icone,
    String titulo,
    String sub,
    Color cor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, color: cor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: const Color(0xFF2E2E2E),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemSwitch(
    IconData icone,
    String titulo,
    String sub,
    Color cor,
    bool valor,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: const Color(0xFF2E2E2E),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            // essa animacao deixa o seletor deslizar quando a pessoa troca a opcao
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                color: valor ? cor : Colors.grey.shade400,
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
      ),
    );
  }
}
