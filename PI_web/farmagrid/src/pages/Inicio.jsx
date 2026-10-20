import { useState } from 'react';
import '../styles/inicio.css';
import { Logo } from '../components/Logo.jsx';
import { IVideo, IArquivo, IEstoque, IRelogio, IEstrela, IGrafico } from '../components/Icones.jsx';

const SERVICOS = [
  [IVideo,    'Teleconsultas',           'Consultas médicas por videochamada com profissionais verificados e especialistas.'],
  [IArquivo,  'Prontuários Eletrônicos', 'Histórico médico completo, exames e receitas digitais em um só lugar.'],
  [IEstoque,  'Controle de Estoque', 'Gestão inteligente so estoque.'],
  [IRelogio,  'Receitas Digitais',       'Prescrições eletrônicas com assinatura digital ICP-Brasil e validação por QR Code.'],
  [IEstrela,  'Clube de Descontos',      'Até 60% de desconto em medicamentos com assinatura mensal ou anual.'],
  [IGrafico,  'Relatórios Gerenciais',   'Análise completa de vendas, consultas e performance com gráficos detalhados.'],
];

const ETAPAS = [
  ['1', 'Cadastre-se', 'Crie sua conta como paciente, médico ou farmácia em menos de 2 minutos.'],
  ['2', 'Conecte-se',  'Agende consultas, emita receitas ou gerencie seu estoque de forma integrada.'],
  ['3', 'Aproveite',   'Economize tempo, reduza custos e ofereça melhor atendimento aos pacientes.'],
];

const PLANOS = [
  {
    titulo: 'Paciente Básico', preco: '0', destaque: false, cta: 'Começar Grátis',
    recursos: [['Teleconsultas ilimitadas', true], ['Prontuário digital', true], ['Receitas eletrônicas', true], ['Clube de descontos', false], ['Prioridade no atendimento', false]],
  },
  {
    titulo: 'Clube Premium', preco: '15', destaque: true, cta: 'Assinar Agora',
    recursos: [['Tudo do plano Básico', true], ['Até 60% de desconto', true], ['Prioridade no atendimento', true], ['Entrega grátis', true], ['Cashback em compras', true]],
  },
  {
    titulo: 'Profissional/Farmácia', preco: '1000', destaque: false, cta: 'Começar Teste',
    recursos: [['Gestão completa', true], ['Estoque com IoT/RFID', true], ['Relatórios gerenciais', true], ['Suporte prioritário', true], ['API de integração', true]],
  },
];

export function Inicio({ onLogin }) {
  const rolarAte = (id) => document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });

  const [menuAberto, setMenuAberto] = useState(false);
  const navegar = (id) => { setMenuAberto(false); rolarAte(id); };

  return (
    <div className="landing">
      <header className="header">
        <div className="container">
          <div className="header-inner">
            <Logo />
            <nav className="nav-links">
              <a onClick={() => rolarAte('servicos')}>Serviços</a>
              <a onClick={() => rolarAte('como-funciona')}>Como Funciona</a>
              <a onClick={() => rolarAte('planos')}>Planos</a>
            </nav>
            <button type="button" className="btn btn-primary btn-lg desktop-only" onClick={onLogin}>Entrar</button>
            <button
              type="button"
              className="nav-hamburger"
              aria-label="Abrir menu"
              onClick={() => setMenuAberto(a => !a)}
            >
              <span></span><span></span><span></span>
            </button>
          </div>
        </div>
        <nav className={`nav-drawer ${menuAberto ? 'open' : ''}`}>
          <a onClick={() => navegar('servicos')}>Serviços</a>
          <a onClick={() => navegar('como-funciona')}>Como Funciona</a>
          <a onClick={() => navegar('planos')}>Planos</a>
          <a onClick={() => { setMenuAberto(false); onLogin(); }}>Entrar</a>
        </nav>
      </header>

      <section className="hero">
        <div className="container">
          <div className="hero-grid">
            <div className="hero-text">
              <h1>Conectando Pacientes, Médicos e Farmácias em um Só Lugar</h1>
              <p className="hero-sub">Teleconsultas, prontuários eletrônicos, controle de estoque inteligente e clube de descontos. Tudo integrado para melhorar o cuidado com a saúde.</p>
              <div className="hero-btns">
                <button type="button" className="btn btn-primary btn-lg" onClick={onLogin}>Começar Agora</button>
                <button type="button" className="btn btn-secondary btn-lg" onClick={() => rolarAte('como-funciona')}>Saiba Mais</button>
              </div>
              <div className="hero-stats">
                {[['50k+', 'Pacientes Ativos'], ['1.200+', 'Médicos Verificados'], ['300+', 'Farmácias Parceiras']].map(([v, l]) => (
                  <div className="stat-pill" key={l}><strong>{v}</strong><span>{l}</span></div>
                ))}
              </div>
            </div>
            <div className="hero-image">
              <div className="video-responsivo">
                <video autoPlay loop muted playsInline>
                  <source src="/midia/videofarma.mp4" type="video/mp4" />
                </video>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="servicos" className="landing-section">
        <div className="container">
          <div className="section-label"><h2>Recursos Principais</h2><p>Tudo que você precisa para gestão completa de saúde</p></div>
          <div className="services-grid">
            {SERVICOS.map(([Ico, titulo, desc]) => (
              <div className="service-card" key={titulo}>
                <div className="svc-icon"><Ico /></div>
                <h3>{titulo}</h3><p>{desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="como-funciona" className="landing-section section-muted">
        <div className="container">
          <div className="section-label"><h2>Como Funciona</h2><p>Simples e intuitivo para todos os usuários</p></div>
          <div className="steps-grid">
            {ETAPAS.map(([n, t, d]) => (
              <div className="step" key={n}><div className="step-num">{n}</div><h3>{t}</h3><p>{d}</p></div>
            ))}
          </div>
        </div>
      </section>

      <section id="planos" className="landing-section">
        <div className="container">
          <div className="section-label"><h2>Planos e Preços</h2><p>Escolha o melhor plano para você</p></div>
          <div className="pricing-grid">
            {PLANOS.map(p => (
              <div className={`price-card ${p.destaque ? 'featured' : ''}`} key={p.titulo}>
                {p.destaque && <div className="popular">Mais Popular</div>}
                <h3>{p.titulo}</h3>
                <div className="price-display">
                  <span className="price-currency">R$</span>
                  <span className="price-amount">{p.preco}</span>
                  <span className="price-period">/mês</span>
                </div>
                <ul className="price-features">
                  {p.recursos.map(([texto, sim]) => (
                    <li key={texto}>{sim ? '✓' : '✗'} {texto}</li>
                  ))}
                </ul>
                <button type="button" className={`btn ${p.destaque ? 'btn-primary' : 'btn-secondary'}`} style={{ width: '100%' }} onClick={onLogin}>{p.cta}</button>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="download">
        <div className="container download-inner">
          <img src="/midia/FarmaGrid_Personagem-removebg-preview.png" alt="" className="bg-img" />
          <div className="download-content">
            <h2>Baixe o App FarmaGrid</h2>
            <div className="download-btns">
              <button type="button" className="btn-download">
                <img src="/midia/download3.png" alt="Windows" className="img-download" />
                <span>Windows</span>
              </button>
              <button type="button" className="btn-download">
                <img src="/midia/download3.png" alt="Mobile" className="img-download" />
                <span>Mobile</span>
              </button>
            </div>
          </div>
        </div>
      </section>

      <footer className="footer">
        <div className="container">
          <div className="footer-grid">
            <div className="footer-col">
              <img src="/midia/logo.png" alt="FarmaGrid" width="40" height="40" />
              <h4>FarmaGrid</h4>
              <p>Inovação em saúde digital</p>
            </div>
            <div className="footer-col">
              <h4>Produto</h4>
              <a onClick={() => rolarAte('servicos')}>Serviços</a>
              <a onClick={() => rolarAte('planos')}>Preços</a>
              <span>Atualizações</span>
            </div>
            <div className="footer-col">
              <h4>Empresa</h4>
              <span>Sobre nós</span>
              <span>Parcerias</span>
              <span>Política de Privacidade</span>
              <span>Termos de Uso</span>
            </div>
            <div className="footer-col">
              <h4>Contato</h4>
              <span>suporte@farmagrid.com</span>
              <span>(19) 3251-1234</span>
              <span>COTIL - Unicamp</span>
            </div>
          </div>
          <div className="footer-bottom">© 2025 FarmaGrid. Todos os direitos reservados.</div>
        </div>
      </footer>
    </div>
  );
}
