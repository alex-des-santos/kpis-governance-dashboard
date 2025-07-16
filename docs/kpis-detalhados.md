# KPIs Detalhados - Indicadores Estratégicos

## Visão Geral

Este documento detalha os 7 indicadores estratégicos selecionados, organizados por categoria (Comercial, Operacional, Financeiro) com origem dos dados, fórmulas de cálculo e frequência de atualização.

## Indicadores Comerciais

### 1. Taxa de Conversão de Leads

**Descrição**: Percentual de leads que se convertem em clientes pagantes

**Origem dos Dados**:
- **Primária**: CRM Ploomes (stages do pipeline)
- **Secundária**: Site/Landing Pages (tracking de conversões)

**Fórmula**:
```sql
Taxa_Conversao = (Leads_Convertidos / Total_Leads) * 100

WHERE:
- Leads_Convertidos = COUNT(leads WHERE status = 'Won')
- Total_Leads = COUNT(leads WHERE created_date >= periodo_inicio)
```

**Frequência de Atualização**: Diário (atualização às 8h)

**Metas**:
- Excelente: > 15%
- Bom: 10-15%
- Atenção: < 10%

**Segmentações**:
- Por canal de origem (ads, WhatsApp, indicações, etc.)
- Por segmento de cliente
- Por período (diário, semanal, mensal)

### 2. CAC (Customer Acquisition Cost)

**Descrição**: Custo médio para adquirir um novo cliente

**Origem dos Dados**:
- **Primária**: ERP SAP B1 (custos de marketing e vendas)
- **Secundária**: Plataformas de ads (Google Ads, Facebook Ads)
- **Terciária**: CRM Ploomes (novos clientes)

**Fórmula**:
```sql
CAC = (Total_Gastos_Marketing_Vendas) / (Novos_Clientes_Periodo)

WHERE:
- Total_Gastos_Marketing_Vendas = SUM(despesas_marketing + salarios_vendas + ferramentas)
- Novos_Clientes_Periodo = COUNT(DISTINCT clientes WHERE primeira_compra >= periodo_inicio)
```

**Frequência de Atualização**: Mensal (fechamento do mês)

**Metas**:
- Excelente: < 3x LTV
- Bom: 3-5x LTV
- Atenção: > 5x LTV

**Segmentações**:
- Por canal de aquisição
- Por segmento de produto
- Por região geográfica

### 3. MRR (Monthly Recurring Revenue)

**Descrição**: Receita recorrente mensal de contratos ativos

**Origem dos Dados**:
- **Primária**: ERP SAP B1 (contratos e faturas)
- **Secundária**: CRM Ploomes (oportunidades recorrentes)

**Fórmula**:
```sql
MRR = SUM(valor_mensal_contrato)

WHERE:
- Contratos ativos no mês de referência
- Normalização para valor mensal (anual/12, trimestral/3, etc.)
```

**Frequência de Atualização**: Diário (visão sempre atual)

**Metas**:
- Crescimento mensal: > 20%
- Crescimento trimestral: > 60%
- Crescimento anual: > 300%

**Segmentações**:
- Por tipo de contrato
- Por segmento de cliente
- Por produto/serviço

## Indicadores Operacionais

### 4. SLA de Resposta WhatsApp

**Descrição**: Percentual de mensagens respondidas dentro do prazo estabelecido

**Origem dos Dados**:
- **Primária**: WhatsApp Business API (logs via N8N)
- **Secundária**: Sistema de atendimento integrado

**Fórmula**:
```sql
SLA_WhatsApp = (Mensagens_Respondidas_No_Prazo / Total_Mensagens_Recebidas) * 100

WHERE:
- Mensagens_Respondidas_No_Prazo = COUNT(mensagens WHERE tempo_resposta <= 15_minutos)
- Total_Mensagens_Recebidas = COUNT(mensagens WHERE tipo = 'recebida')
```

**Frequência de Atualização**: Diário (tempo real durante horário comercial)

**Metas**:
- Excelente: > 90%
- Bom: 80-90%
- Atenção: < 80%

**Segmentações**:
- Por horário do dia
- Por dia da semana
- Por tipo de solicitação

### 5. Lead Time de Pedido

**Descrição**: Tempo médio entre o pedido e a entrega/faturamento

**Origem dos Dados**:
- **Primária**: ERP SAP B1 (pedidos, estoque, faturamento)
- **Secundária**: Sistema logístico integrado

**Fórmula**:
```sql
Lead_Time = AVG(data_faturamento - data_pedido)

WHERE:
- data_faturamento IS NOT NULL
- data_pedido >= periodo_inicio
```

**Frequência de Atualização**: Diário

**Metas**:
- Excelente: < 5 dias
- Bom: 5-10 dias
- Atenção: > 10 dias

**Segmentações**:
- Por tipo de produto
- Por região de entrega
- Por canal de venda

## Indicadores Financeiros

### 6. Margem Bruta

**Descrição**: Percentual da receita que resta após custos diretos

**Origem dos Dados**:
- **Primária**: ERP SAP B1 (receitas e custos)
- **Secundária**: Sistema de custeio integrado

**Fórmula**:
```sql
Margem_Bruta = ((Receita_Total - COGS) / Receita_Total) * 100

WHERE:
- Receita_Total = SUM(valor_faturado)
- COGS = SUM(custo_produtos_vendidos + custos_diretos)
```

**Frequência de Atualização**: Mensal (fechamento contábil)

**Metas**:
- Excelente: > 60%
- Bom: 40-60%
- Atenção: < 40%

**Segmentações**:
- Por produto/serviço
- Por canal de vendas
- Por segmento de cliente

### 7. ROI de Feiras & Eventos

**Descrição**: Retorno sobre investimento em eventos e feiras

**Origem dos Dados**:
- **Primária**: ERP SAP B1 (custos de eventos)
- **Secundária**: CRM Ploomes (leads e vendas de eventos)
- **Terciária**: Controle manual (planilhas legadas)

**Fórmula**:
```sql
ROI_Evento = ((Receita_Gerada - Custo_Evento) / Custo_Evento) * 100

WHERE:
- Receita_Gerada = SUM(vendas WHERE origem = 'evento_X')
- Custo_Evento = SUM(despesas_evento + salarios_equipe + deslocamento)
```

**Frequência de Atualização**: Por evento (análise pós-evento)

**Metas**:
- Excelente: > 300%
- Bom: 150-300%
- Atenção: < 150%

**Segmentações**:
- Por tipo de evento
- Por localização
- Por investimento realizado

## Implementação Técnica

### Modelagem de Dados

```sql
-- Tabela de fatos para KPIs
CREATE TABLE fct_kpis (
    data_referencia DATE,
    kpi_nome VARCHAR(50),
    kpi_valor DECIMAL(10,2),
    kpi_meta DECIMAL(10,2),
    segmento VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- View materializada para dashboard
CREATE MATERIALIZED VIEW vw_kpis_dashboard AS
SELECT 
    kpi_nome,
    kpi_valor,
    kpi_meta,
    CASE 
        WHEN kpi_valor >= kpi_meta THEN 'Verde'
        WHEN kpi_valor >= kpi_meta * 0.9 THEN 'Amarelo'
        ELSE 'Vermelho'
    END AS status_semaforo,
    data_referencia
FROM fct_kpis
WHERE data_referencia = CURRENT_DATE;
```

### Testes de Qualidade

```python
# Great Expectations - Testes de KPIs
def test_kpi_values():
    expectations = [
        {
            "expectation_type": "expect_column_values_to_be_between",
            "kwargs": {
                "column": "taxa_conversao",
                "min_value": 0,
                "max_value": 100
            }
        },
        {
            "expectation_type": "expect_column_values_to_not_be_null",
            "kwargs": {
                "column": "mrr"
            }
        }
    ]
    return expectations
```

### Alertas e Monitoramento

```yaml
# Airflow DAG para alertas
alertas_kpis:
  schedule_interval: "0 8 * * *"  # Diário às 8h
  tasks:
    - name: check_conversion_rate
      condition: taxa_conversao < 10
      action: send_slack_alert
      channel: "#vendas"
    
    - name: check_mrr_growth
      condition: mrr_growth < 0
      action: send_email_alert
      recipients: ["ceo@empresa.com", "cfo@empresa.com"]
```

### Dashboard Configuration

```javascript
// Configuração de KPIs para dashboard
const kpiConfig = {
  comercial: [
    {
      name: "Taxa de Conversão",
      value: "taxa_conversao",
      format: "percentage",
      color: "blue",
      goal: 15
    },
    {
      name: "CAC",
      value: "cac",
      format: "currency",
      color: "green",
      goal: 500
    },
    {
      name: "MRR",
      value: "mrr",
      format: "currency",
      color: "purple",
      goal: 100000
    }
  ],
  operacional: [
    {
      name: "SLA WhatsApp",
      value: "sla_whatsapp",
      format: "percentage",
      color: "orange",
      goal: 90
    },
    {
      name: "Lead Time",
      value: "lead_time",
      format: "days",
      color: "red",
      goal: 5
    }
  ],
  financeiro: [
    {
      name: "Margem Bruta",
      value: "margem_bruta",
      format: "percentage",
      color: "teal",
      goal: 60
    },
    {
      name: "ROI Eventos",
      value: "roi_eventos",
      format: "percentage",
      color: "indigo",
      goal: 300
    }
  ]
};
```

## Governança dos KPIs

### Definições Padronizadas

- **Owner**: Responsável por cada KPI
- **Steward**: Executor da curadoria
- **Frequência de Revisão**: Trimestral
- **Processo de Mudança**: Pull Request obrigatório

### Auditoria e Compliance

- Log de todas as alterações
- Rastreabilidade de cálculos
- Backup de dados históricos
- Certificação periódica

### Treinamento

- Documentação acessível
- Workshops trimestrais
- Onboarding para novos usuários
- Suporte técnico dedicado

## Conclusão

Os 7 KPIs selecionados fornecem uma visão 360° da empresa:

- **Comercial**: Eficiência de aquisição e crescimento
- **Operacional**: Qualidade do atendimento e processo
- **Financeiro**: Rentabilidade e retorno sobre investimento

A implementação técnica garante dados confiáveis, atualizados e facilmente consumíveis pelo time de liderança.
