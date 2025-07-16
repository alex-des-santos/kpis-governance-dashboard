# KPIs Governance Dashboard

## 📊 Sobre o Repositório

**Nome:** `kpis-governance-dashboard`

**Descrição:** Plataforma completa de governança de dados e dashboard de KPIs estratégicos para empresas em crescimento com múltiplos canais de aquisição.

## 🎯 Principais Funcionalidades

- **Dashboard Interativo**: Interface HTML/CSS/JS responsiva com 7 KPIs estratégicos
- **Arquitetura Lakehouse**: Stack completo de dados moderno e escalável
- **Governança Estruturada**: Framework de governança de dados corporativa
- **Automação Completa**: Pipeline ETL/ELT automatizado com Airflow
- **Qualidade de Dados**: Validação e monitoramento com Great Expectations
- **Documentação Abrangente**: Guias técnicos e de implementação

## 🛠️ Stack Tecnológico

### Data Stack
- **Ingestão**: Airbyte, Apache Airflow
- **Warehouse**: Snowflake, BigQuery
- **Transformação**: dbt (Data Build Tool)
- **Qualidade**: Great Expectations
- **Visualização**: HTML/CSS/JS, Power BI

### DevOps & Infraestrutura
- **Containerização**: Docker, Docker Compose
- **Orquestração**: Kubernetes (planejado)
- **Monitoramento**: Grafana, Prometheus
- **CI/CD**: GitHub Actions (planejado)

## 📂 Estrutura do Projeto

```
kpis-governance-dashboard/
├── dashboard/              # Dashboard interativo
│   ├── index.html
│   ├── styles.css
│   ├── script.js
│   └── mockdata.js
├── docs/                   # Documentação técnica
│   ├── arquitetura-dados.md
│   ├── governanca-dados.md
│   ├── kpis-detalhados.md
│   └── plano-implementacao.md
├── sql/                    # Modelos SQL/dbt
│   └── models/
├── config/                 # Configurações
│   ├── dbt/
│   ├── great-expectations/
│   └── pipeline-config.yaml
├── scripts/               # Scripts de automação
│   └── setup.sh
├── docker-compose.yml     # Ambiente local
├── Makefile              # Comandos de automação
└── README.md
```

## 🚀 Quick Start

### Pré-requisitos
- Docker & Docker Compose
- Python 3.8+
- Git

### Instalação Rápida

```bash
# Clone o repositório
git clone https://github.com/company/kpis-governance-dashboard.git
cd kpis-governance-dashboard

# Configure o ambiente
make setup

# Inicie os serviços
make start

# Abra o dashboard
open dashboard/index.html
```

### Serviços Disponíveis

- **Dashboard**: `dashboard/index.html`
- **Airflow**: `http://localhost:8080`
- **Airbyte**: `http://localhost:8000`
- **Grafana**: `http://localhost:3000`
- **Jupyter**: `http://localhost:8888`

## 📊 KPIs Implementados

### Comercial
1. **Taxa de Conversão por Canal** - Monitoramento diário
2. **CAC (Customer Acquisition Cost)** - Análise mensal
3. **MRR Growth** - Crescimento da receita recorrente

### Operacional
4. **SLA Compliance** - Cumprimento de acordos de nível de serviço
5. **Lead Time** - Tempo médio de processamento

### Financeiro
6. **Margem Bruta** - Lucratividade por produto/serviço
7. **ROI de Eventos** - Retorno sobre investimento em eventos

## 🏗️ Arquitetura

### Fluxo de Dados
```
[Sistemas Fonte] → [Airbyte] → [Raw Zone] → [dbt] → [Warehouse] → [Dashboard]
     ↓
[Ploomes CRM]
[SAP B1 ERP]
[WhatsApp API]
```

### Camadas da Arquitetura
- **Ingestão**: Airbyte para conectores
- **Transformação**: dbt para modelagem
- **Armazenamento**: Snowflake como warehouse
- **Visualização**: Dashboard HTML + Power BI

## 🔧 Desenvolvimento

### Comandos Principais

```bash
make help           # Lista todos os comandos
make start          # Inicia todos os serviços
make test           # Executa testes
make lint           # Executa linting
make docs           # Gera documentação
make deploy-dev     # Deploy para desenvolvimento
```

### Workflow de Desenvolvimento

1. **Feature Branch**: `git checkout -b feature/nova-funcionalidade`
2. **Desenvolvimento**: Implementar mudanças
3. **Testes**: `make test && make lint`
4. **Pull Request**: Abrir PR para `develop`
5. **Review**: Code review e aprovação
6. **Merge**: Merge para `develop`

## 📋 Roadmap

### Fase 1 (Atual) - Fundação ✅
- Dashboard básico funcional
- Arquitetura lakehouse definida
- Documentação completa
- Ambiente de desenvolvimento

### Fase 2 - Dados Reais 🔄
- Conectores reais implementados
- Modelos dbt refinados
- Testes de qualidade
- Governança ativa

### Fase 3 - Escala 📋
- Performance otimizada
- Monitoramento avançado
- Segurança enterprise
- Múltiplos departamentos

## 🤝 Contribuição

Consulte [CONTRIBUTING.md](CONTRIBUTING.md) para:
- Padrões de código
- Processo de development
- Como reportar bugs
- Como sugerir melhorias

## 📚 Documentação

- [Arquitetura de Dados](docs/arquitetura-dados.md)
- [Governança de Dados](docs/governanca-dados.md)
- [KPIs Detalhados](docs/kpis-detalhados.md)
- [Plano de Implementação](docs/plano-implementacao.md)
- [Metodologia](docs/metodologia-desenvolvimento.md)

## 🎯 Valor de Negócio

### Benefícios Imediatos
- **Visibilidade**: KPIs em tempo real
- **Eficiência**: Automação de relatórios
- **Qualidade**: Dados confiáveis e validados

### Benefícios a Longo Prazo
- **Escalabilidade**: Arquitetura preparada para crescimento
- **Governança**: Dados organizados e auditáveis
- **Decisões**: Insights baseados em dados

## 📞 Contato

- **Email**: data-team@company.com
- **Slack**: #data-team
- **Issues**: [GitHub Issues](https://github.com/company/kpis-governance-dashboard/issues)

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para mais detalhes.

---

*Desenvolvido com ❤️ pela equipe de dados*
