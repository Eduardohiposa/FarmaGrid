const { contextBridge, ipcRenderer } = require("electron");

// valida o cpf
function validarCPF(valor) {
  const cpf = String(valor ?? '').replace(/\D/g, '');

  if (cpf.length !== 11 || /^(\d)\1{10}$/.test(cpf)) {
    return false;
  }

  const calcularDigito = (quantidade) => {
    let soma = 0;
    for (let indice = 0; indice < quantidade; indice += 1) {
      soma += Number(cpf[indice]) * (quantidade + 1 - indice);
    }

    const resto = (soma * 10) % 11;
    return resto === 10 ? 0 : resto;
  };

  return calcularDigito(9) === Number(cpf[9])
    && calcularDigito(10) === Number(cpf[10]);
}

let operacoesEmAndamento = 0;
const botoesEmAndamento = new WeakMap();

function mensagemDaOperacao(canal) {
  if (canal === 'login') return 'Entrando...';
  if (canal.startsWith('buscar') || canal.startsWith('verificar')) return 'Carregando...';
  if (canal.startsWith('cadastrar') || canal.startsWith('criar')) return 'Cadastrando...';
  if (canal.startsWith('salvar')) return 'Salvando...';
  if (canal.startsWith('atualizar') || canal.startsWith('editar') || canal.startsWith('reagendar')) return 'Atualizando...';
  if (canal.startsWith('deletar') || canal.startsWith('remover')) return 'Excluindo...';
  if (canal.startsWith('gerar')) return 'Gerando...';
  if (canal.startsWith('baixar') || canal.startsWith('abrir') || canal.startsWith('selecionar')) return 'Processando...';
  if (canal.startsWith('enviar')) return 'Enviando...';
  return 'Processando...';
}

function obterIndicador() {
  if (!document.body) return null;

  let indicador = document.getElementById('farmagrid-loading-overlay');
  if (indicador) return indicador;

  const estilo = document.createElement('style');
  estilo.id = 'farmagrid-loading-style';
  estilo.textContent = `
    #farmagrid-loading-overlay {
      position: fixed;
      inset: 0;
      z-index: 2147483647;
      display: none;
      align-items: center;
      justify-content: center;
      background: rgba(248, 250, 249, 0.72);
      backdrop-filter: blur(2px);
      -webkit-backdrop-filter: blur(2px);
      cursor: wait;
    }

    #farmagrid-loading-overlay.farmagrid-loading-visivel {
      display: flex;
    }

    .farmagrid-loading-card {
      min-width: 190px;
      padding: 24px 30px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 14px;
      border: 1px solid rgba(53, 94, 59, 0.16);
      border-radius: 16px;
      background: #ffffff;
      color: #355e3b;
      font-family: Poppins, Arial, sans-serif;
      font-size: 16px;
      font-weight: 600;
      box-shadow: 0 12px 35px rgba(35, 78, 46, 0.18);
    }

    .farmagrid-loading-spinner {
      width: 38px;
      height: 38px;
      border: 4px solid #dbe9df;
      border-top-color: #355e3b;
      border-radius: 50%;
      animation: farmagrid-girar 0.8s linear infinite;
    }

    @keyframes farmagrid-girar {
      to { transform: rotate(360deg); }
    }

    @media (prefers-reduced-motion: reduce) {
      .farmagrid-loading-spinner { animation-duration: 1.6s; }
    }
  `;
  document.head.appendChild(estilo);

  indicador = document.createElement('div');
  indicador.id = 'farmagrid-loading-overlay';
  indicador.setAttribute('role', 'status');
  indicador.setAttribute('aria-live', 'polite');
  indicador.setAttribute('aria-hidden', 'true');
  indicador.innerHTML = `
    <div class="farmagrid-loading-card">
      <div class="farmagrid-loading-spinner" aria-hidden="true"></div>
      <span id="farmagrid-loading-mensagem">Carregando...</span>
    </div>
  `;
  document.body.appendChild(indicador);
  return indicador;
}

function iniciarCarregamento(canal) {
  operacoesEmAndamento += 1;

  const indicador = obterIndicador();
  if (indicador) {
    const mensagem = indicador.querySelector('#farmagrid-loading-mensagem');
    if (mensagem) mensagem.textContent = mensagemDaOperacao(canal);
    indicador.classList.add('farmagrid-loading-visivel');
    indicador.setAttribute('aria-hidden', 'false');
  }

  const ativo = document.activeElement;
  const botao = ativo && typeof ativo.closest === 'function'
    ? ativo.closest('button, input[type="button"], input[type="submit"]')
    : null;

  if (botao) {
    const atual = botoesEmAndamento.get(botao);
    if (atual) {
      atual.quantidade += 1;
    } else {
      botoesEmAndamento.set(botao, {
        quantidade: 1,
        desabilitadoAntes: botao.disabled,
        ariaBusyAntes: botao.getAttribute('aria-busy'),
      });
      botao.disabled = true;
      botao.setAttribute('aria-busy', 'true');
    }
  }

  return botao;
}

function finalizarCarregamento(botao) {
  operacoesEmAndamento = Math.max(0, operacoesEmAndamento - 1);

  if (botao) {
    const estado = botoesEmAndamento.get(botao);
    if (estado) {
      estado.quantidade -= 1;
      if (estado.quantidade <= 0) {
        botao.disabled = estado.desabilitadoAntes;
        if (estado.ariaBusyAntes === null) botao.removeAttribute('aria-busy');
        else botao.setAttribute('aria-busy', estado.ariaBusyAntes);
        botoesEmAndamento.delete(botao);
      }
    }
  }

  if (operacoesEmAndamento === 0) {
    const indicador = document.getElementById('farmagrid-loading-overlay');
    if (indicador) {
      indicador.classList.remove('farmagrid-loading-visivel');
      indicador.setAttribute('aria-hidden', 'true');
    }
  }
}

async function invocar(canal, ...argumentos) {
  const botao = iniciarCarregamento(canal);
  try {
    return await ipcRenderer.invoke(canal, ...argumentos);
  } finally {
    finalizarCarregamento(botao);
  }
}

function campoDeCPF(elemento) {
  if (!elemento || elemento.tagName !== 'INPUT') return false;
  const identificador = `${elemento.id || ''} ${elemento.name || ''}`.toLowerCase();
  return identificador.includes('cpf');
}

function removerAvisoCPF(campo) {
  campo.setCustomValidity('');
  campo.classList.remove('farmagrid-cpf-invalido');
  campo.removeAttribute('aria-invalid');

  const aviso = campo.nextElementSibling;
  if (aviso?.classList.contains('farmagrid-cpf-feedback')) aviso.remove();
}

function mostrarAvisoCPF(campo) {
  campo.setCustomValidity('Informe um CPF válido.');
  campo.classList.add('farmagrid-cpf-invalido');
  campo.setAttribute('aria-invalid', 'true');

  if (!campo.nextElementSibling?.classList.contains('farmagrid-cpf-feedback')) {
    const aviso = document.createElement('div');
    aviso.className = 'farmagrid-cpf-feedback';
    aviso.textContent = 'CPF inválido. Confira os números informados.';
    campo.insertAdjacentElement('afterend', aviso);
  }
}

function validarCampoCPF(campo, forcar = false) {
  if (!campoDeCPF(campo)) return true;

  const digitos = campo.value.replace(/\D/g, '');
  if (!digitos) {
    removerAvisoCPF(campo);
    return true;
  }

  if (!forcar && digitos.length < 11) {
    removerAvisoCPF(campo);
    return false;
  }

  const valido = validarCPF(digitos);
  if (valido) removerAvisoCPF(campo);
  else mostrarAvisoCPF(campo);
  return valido;
}

function configurarValidacaoVisualCPF() {
  if (!document.getElementById('farmagrid-cpf-style')) {
    const estilo = document.createElement('style');
    estilo.id = 'farmagrid-cpf-style';
    estilo.textContent = `
      .farmagrid-cpf-invalido {
        border-color: #c62828 !important;
        box-shadow: 0 0 0 2px rgba(198, 40, 40, 0.12) !important;
      }

      .farmagrid-cpf-feedback {
        margin-top: -10px;
        margin-bottom: 10px;
        color: #c62828;
        font-family: Poppins, Arial, sans-serif;
        font-size: 12px;
      }
    `;
    document.head.appendChild(estilo);
  }

  document.addEventListener('input', (evento) => {
    if (campoDeCPF(evento.target)) validarCampoCPF(evento.target);
  });

  document.addEventListener('blur', (evento) => {
    if (campoDeCPF(evento.target)) validarCampoCPF(evento.target, true);
  }, true);
}

//cache

let ultimoStatusCache = null;

function renderizarStatusCache(status) {
  ultimoStatusCache = status;
  if (!document.body || !status) return;

  let indicador = document.getElementById('farmagrid-offline-status');
  if (!indicador) {
    const estilo = document.createElement('style');
    estilo.id = 'farmagrid-offline-style';
    estilo.textContent = `
      #farmagrid-offline-status {
        position: fixed;
        right: 16px;
        bottom: 16px;
        z-index: 2147483646;
        display: none;
        padding: 9px 13px;
        border: 0;
        border-radius: 999px;
        background: #8a5a00;
        color: #fff;
        font: 600 12px Poppins, Arial, sans-serif;
        box-shadow: 0 5px 18px rgba(0, 0, 0, .2);
        cursor: pointer;
      }
      #farmagrid-offline-status.farmagrid-cache-visivel { display: block; }
      #farmagrid-offline-status.farmagrid-cache-erro { background: #a12622; }
      #farmagrid-offline-status.farmagrid-cache-sync { background: #355e3b; }
    `;
    document.head.appendChild(estilo);

    indicador = document.createElement('button');
    indicador.id = 'farmagrid-offline-status';
    indicador.type = 'button';
    indicador.title = 'Clique para tentar sincronizar agora';
    indicador.addEventListener('click', () => invocar('sincronizar-cache'));
    document.body.appendChild(indicador);
  }

  indicador.className = '';
  const total = Number(status.pendentes || 0);
  const erros = Number(status.comErro || 0);

  if (status.sincronizando) {
    indicador.textContent = `Sincronizando ${total} item(ns)...`;
    indicador.classList.add('farmagrid-cache-visivel', 'farmagrid-cache-sync');
  } else if (!status.online) {
    indicador.textContent = `Offline • ${total} pendente(s)`;
    indicador.classList.add('farmagrid-cache-visivel');
  } else if (erros > 0) {
    indicador.textContent = `${erros} item(ns) com erro de sincronização`;
    indicador.classList.add('farmagrid-cache-visivel', 'farmagrid-cache-erro');
  } else if (total > 0) {
    indicador.textContent = `${total} item(ns) aguardando sincronização`;
    indicador.classList.add('farmagrid-cache-visivel');
  }
}

function configurarStatusCache() {
  if (ultimoStatusCache) renderizarStatusCache(ultimoStatusCache);
  ipcRenderer.invoke('obter-status-cache').then(renderizarStatusCache).catch(() => {});
}

ipcRenderer.on('cache-status-alterado', (_event, status) => renderizarStatusCache(status));

if (document.readyState === 'loading') {
  window.addEventListener('DOMContentLoaded', () => {
    configurarValidacaoVisualCPF();
    configurarStatusCache();
  }, { once: true });
} else {
  configurarValidacaoVisualCPF();
  configurarStatusCache();
}

contextBridge.exposeInMainWorld("electronAPI", {
  validarCPF: (cpf) => validarCPF(cpf),
  obterStatusCache: () => ipcRenderer.invoke('obter-status-cache'),
  sincronizarCache: () => invocar('sincronizar-cache'),
  aoAlterarStatusCache: (callback) => {
    if (typeof callback !== 'function') return;
    ipcRenderer.on('cache-status-alterado', (_event, status) => callback(status));
  },
  abrirJanelaIndex: () => ipcRenderer.send("abrir-janela-index"),
  abrirJanelaBalconista: () => ipcRenderer.send("abrir-janela-balconista"),
  abrirJanelaCaixa: () => ipcRenderer.send("abrir-janela-caixa"),
  abrirJanelaFunc: () => ipcRenderer.send("abrir-janela-func"),
  abrirJanelaT: () => ipcRenderer.send("abrir-janela-t"),
  abrirJanelaL: () => ipcRenderer.send("abrir-janela-l"),
  abrirJanelaD: () => ipcRenderer.send("abrir-janela-d"),
  abrirJanelaE: () => ipcRenderer.send("abrir-janela-e"),
  abrirJanelaV: () => ipcRenderer.send("abrir-janela-v"),
  abrirJanelaSE: () => ipcRenderer.send("abrir-janela-se"),
  abrirJanelaDE: () => ipcRenderer.send("abrir-janela-de"),
  abrirJanelaR: () => ipcRenderer.send("abrir-janela-r"),
  abrirJanelaIA: () => ipcRenderer.send("abrir-janela-ia"),
  abrirJanelaConfig: () => ipcRenderer.send("abrir-janela-config"),
  abrirJanelaParceria: () => ipcRenderer.send("abrir-janela-parceria"),
  login: (email, senha, tipo) => invocar('login', email, senha, tipo),
  buscarProntuarios: () => invocar('buscar-prontuarios'),
  buscarReceitas: (idPaciente, idMedico) => invocar('buscar-receitas', idPaciente, idMedico),
  buscarRelatorios: (idPaciente, idMedico) => invocar('buscar-relatorios', idPaciente, idMedico),
  criarRelatorio: (idPaciente) => invocar('criar-relatorio', idPaciente),
  cadastrarParceiro: (novoParceiro) => invocar('cadastrar-parceiro', novoParceiro),
  buscarParceiros: (idMedico) => invocar('buscar-parceiros', idMedico),
  atualizarStatusParceiro: (dados) => invocar('atualizar-status-parceiro', dados),
  atualizarDescontoParceiro: (dados) => invocar('atualizar-desconto-parceiro', dados),
  adicionarServicoParceiro: (dados) => invocar('adicionar-servico-parceiro', dados),
  encaminharPacienteParceiro: (dados) => invocar('encaminhar-paciente-parceiro', dados),
  buscarPacientesMedico: (idMedico) => invocar('buscar-pacientes-medico', idMedico),
  buscarConsultasMedico: (idMedico) => invocar('buscar-consultas-medico', idMedico),
  perguntarIA: (prompt) => invocar('enviar-prompt', prompt),
  cadastrarFuncionario: (dados) => invocar('cadastrar-funcionario', dados),
  buscarFuncionarios: (idFarmacia) => invocar('buscar-funcionarios', idFarmacia),
  atualizarStatusFuncionario: (dados) => invocar('atualizar-status-funcionario', dados),
  salvarVenda: (venda) => invocar('salvar-venda', venda),
  buscarVendas: (filtro) => invocar('buscar-vendas', filtro),
  buscarVendasHoje: () => invocar('buscar-vendas-hoje'),
  cadastrarCliente: (cliente) => invocar('cadastrar-cliente', cliente),
  buscarCliente: (cpf, idFarmacia) => invocar('buscar-cliente', cpf, idFarmacia),
  salvarConsulta: (consulta) => invocar("salvarConsulta", consulta),
  reagendarConsulta: (dados) => invocar("reagendarConsulta", dados),
  buscarPacientes: () => invocar('buscar-pacientes'),
  salvarRelatorio: (dados) => invocar('salvar-relatorio', dados),
  selecionarPDF: () => invocar('selecionar-pdf'),
  abrirPDF: (idRelatorio) => invocar('abrir-pdf', idRelatorio),
  deletarRelatorio: (id) => invocar('deletar-relatorio', id),
  buscarDadosMedico: (idMedico) => invocar('buscar-dados-medico', idMedico),
  atualizarDadosMedico: (dados) => invocar('atualizar-dados-medico', dados),
  atualizarDadosProfissionais: (dados) => invocar('atualizar-dados-profissionais', dados),
  atualizarPreferencias: (dados) => invocar('atualizar-preferencias', dados),
  salvarFotoPerfil: (data) => invocar('salvar-foto-perfil', data),
  buscarProdutos: (idFarmacia) => invocar('buscar-produtos', idFarmacia),
  buscarLotes: (idProduto) => invocar('buscar-lotes', idProduto),
  cadastrarProduto: (dados) => invocar('cadastrar-produto', dados),
  editarProduto: (dados) => invocar('editar-produto', dados),
  editarPrateleiraLote: (dados) => invocar('editar-prateleira-lote', dados),
  atualizarEstoque: (dados) => invocar('atualizar-estoque', dados),
  deletarProduto: (id) => invocar('deletar-produto', id),
  buscarAlertasValidade: (idFarmacia) => invocar('buscar-alertas-validade', idFarmacia),
  removerLote: (id) => invocar('remover-lote', id),
  buscarCupons: (idFarmacia) => invocar('buscar-cupons', idFarmacia),
  cadastrarCupom: (dados) => invocar('cadastrar-cupom', dados),
  editarCupom: (dados) => invocar('editar-cupom', dados),
  deletarCupom: (id) => invocar('deletar-cupom', id),
  buscarDashboard: (idFarmacia) => invocar('buscar-dashboard', idFarmacia),
  gerarRelatorioFarmacia: (dados) => invocar('gerar-relatorio-farmacia', dados),
  buscarRelatoriosFarmacia: (idFarmacia) => invocar('buscar-relatorios-farmacia', idFarmacia),
  baixarRelatorioFarmacia: (dados) => invocar('baixar-relatorio-farmacia', dados),
  buscarResumoRelatorios: (idFarmacia) => invocar('buscar-resumo-relatorios', idFarmacia),
  atualizarFuncionario: (dados) => invocar('atualizar-funcionario', dados),
  cadastrarProntuario: (dados) => invocar('cadastrar-prontuario', dados),
  buscarProntuarioRecente: (idPaciente) => invocar('buscar-prontuario-recente', idPaciente),
  cadastrarReceita: (dados) => invocar('cadastrar-receita', dados),
  buscarPacientesProntuario: (idMedico) => invocar('buscar-pacientes-prontuario', idMedico),
  buscarProntuariosPaciente: (idPaciente, idMedico) => invocar('buscar-prontuarios-paciente', idPaciente, idMedico),
  atualizarSenha: (dados) => invocar('atualizar-senha', dados),
  verificarEmailRecuperacao: (email) => invocar('verificar-email-recuperacao', email),
  validarCodigoRecuperacao: (dados) => invocar('validar-codigo-recuperacao', dados),
  redefinirSenha: (dados) => invocar('redefinir-senha', dados),
  cadastrarReceitaControlada: (dados) => invocar('cadastrar-receita-controlada', dados),
  buscarDadosFarmacia: (idFarmacia) => invocar('buscar-dados-farmacia', idFarmacia),
  buscarDadosFuncionario: (cpf) => invocar('buscar-dados-funcionario', cpf),
});

