# Raciocínio e Metodologia para Cálculo de KPIs

## 🎯 Introdução

Este documento detalha toda a metodologia e raciocínio utilizados para definir, calcular e organizar os KPIs estratégicos, bem como os insights derivados da análise dos dados.

## 📊 Metodologia de Seleção de KPIs

### 1. Framework de Avaliação

Para selecionar os KPIs mais relevantes, utilizamos o framework **SMART + Impact**:

- **S**pecific: KPI tem definição clara e inequívoca
- **M**easurable: Pode ser medido quantitativamente
- **A**chievable: Meta é realista e atingível
- **R**elevant: Alinha com objetivos estratégicos
- **T**ime-bound: Tem periodicidade definida
- **Impact**: Influencia diretamente decisões de negócio

### 2. Matriz de Priorização

| KPI | Impacto | Dificuldade | Frequência | Score Final |
|-----|---------|-------------|------------|-------------|
| Taxa de Conversão | Alto | Baixa | Diária | 9.5 |
| CAC | Alto | Média | Mensal | 8.5 |
| MRR Growth | Alto | Média | Diária | 8.8 |
| SLA WhatsApp | Médio | Baixa | Diária | 7.8 |
| Lead Time | Médio | Média | Diária | 7.5 |
| Margem Bruta | Alto | Alta | Mensal | 8.2 |
| ROI Eventos | Médio | Alta | Por evento | 6.8 |

## 🔢 Cálculos Detalhados dos KPIs

### 1. Taxa de Conversão por Canal

**Definição**: Percentual de leads que se convertem em clientes pagantes por canal de aquisição.

**Fórmula**:
```
Taxa de Conversão = (Número de Conversões / Número de Leads) × 100
```

**Raciocínio**:
- **Numerador**: Clientes que efetivamente fizeram compra
- **Denominador**: Total de leads qualificados recebidos
- **Segmentação**: Por canal (Ads, WhatsApp, Site, SDR, Eventos, Indicações)

**Benchmark de Mercado**:
- **Ads**: 2-5% (média: 3%)
- **WhatsApp**: 8-15% (média: 12%)
- **Site/Inbound**: 5-10% (média: 7%)
- **SDR**: 15-25% (média: 20%)
- **Eventos**: 10-20% (média: 15%)
- **Indicações**: 25-40% (média: 30%)

**Implementação SQL**:
```sql
WITH conversions AS (
    SELECT 
        channel,
        DATE_TRUNC('day', created_at) as date_key,
        COUNT(DISTINCT lead_id) as total_leads,
        COUNT(DISTINCT CASE WHEN status = 'converted' THEN lead_id END) as conversions
    FROM fct_leads
    WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY 1, 2
)
SELECT 
    channel,
    date_key,
    total_leads,
    conversions,
    ROUND((conversions::float / NULLIF(total_leads, 0)) * 100, 2) as conversion_rate
FROM conversions
ORDER BY date_key DESC, conversion_rate DESC
```

### 2. CAC - Customer Acquisition Cost

**Definição**: Custo médio para adquirir um novo cliente, segmentado por canal.

**Fórmula**:
```
CAC = (Gastos de Marketing + Gastos de Vendas) / Número de Clientes Adquiridos
```

**Raciocínio**:
- **Numerador**: Investimento total em aquisição
  - Ads: Spend direto em plataformas
  - WhatsApp: Custo de operação + ferramentas
  - Site: SEO/SEM + desenvolvimento
  - SDR: Salários + ferramentas + comissões
  - Eventos: Participação + equipe + materiais
  - Indicações: Programa de referência + recompensas

- **Denominador**: Clientes efetivamente adquiridos (não leads)

**Benchmark por Canal**:
- **Ads**: R$ 100-300 (média: R$ 200)
- **WhatsApp**: R$ 50-150 (média: R$ 100)
- **Site/Inbound**: R$ 80-200 (média: R$ 140)
- **SDR**: R$ 300-800 (média: R$ 500)
- **Eventos**: R$ 200-600 (média: R$ 400)
- **Indicações**: R$ 20-80 (média: R$ 50)

**Implementação SQL**:
```sql
WITH monthly_spend AS (
    SELECT 
        channel,
        DATE_TRUNC('month', date) as month_key,
        SUM(marketing_spend) as total_marketing_spend,
        SUM(sales_spend) as total_sales_spend
    FROM fct_marketing_spend
    GROUP BY 1, 2
),
monthly_acquisitions AS (
    SELECT 
        channel,
        DATE_TRUNC('month', conversion_date) as month_key,
        COUNT(DISTINCT customer_id) as new_customers
    FROM fct_customers
    WHERE conversion_date IS NOT NULL
    GROUP BY 1, 2
)
SELECT 
    s.channel,
    s.month_key,
    s.total_marketing_spend + s.total_sales_spend as total_spend,
    a.new_customers,
    ROUND(
        (s.total_marketing_spend + s.total_sales_spend) / 
        NULLIF(a.new_customers, 0), 2
    ) as cac
FROM monthly_spend s
JOIN monthly_acquisitions a ON s.channel = a.channel AND s.month_key = a.month_key
ORDER BY s.month_key DESC, cac ASC
```

### 3. MRR Growth - Monthly Recurring Revenue Growth

**Definição**: Crescimento percentual da receita recorrente mensal.

**Fórmula**:
```
MRR Growth = ((MRR Atual - MRR Anterior) / MRR Anterior) × 100
```

**Componentes do MRR**:
- **New MRR**: Receita de novos clientes
- **Expansion MRR**: Upsell/cross-sell de clientes existentes
- **Contraction MRR**: Downgrade de clientes existentes
- **Churn MRR**: Receita perdida por cancelamentos

**Raciocínio**:
- Foco em crescimento sustentável
- Diferenciação entre crescimento orgânico e inorgânico
- Análise de cohort para entender saúde do negócio

**Benchmark**:
- **Crescimento saudável**: 10-20% ao mês
- **Crescimento acelerado**: 20-30% ao mês
- **Crescimento insustentável**: >30% ao mês

**Implementação SQL**:
```sql
WITH monthly_mrr AS (
    SELECT 
        DATE_TRUNC('month', date) as month_key,
        SUM(CASE WHEN customer_type = 'new' THEN mrr_amount ELSE 0 END) as new_mrr,
        SUM(CASE WHEN customer_type = 'expansion' THEN mrr_amount ELSE 0 END) as expansion_mrr,
        SUM(CASE WHEN customer_type = 'contraction' THEN -mrr_amount ELSE 0 END) as contraction_mrr,
        SUM(CASE WHEN customer_type = 'churn' THEN -mrr_amount ELSE 0 END) as churn_mrr,
        SUM(mrr_amount) as total_mrr
    FROM fct_mrr_movements
    GROUP BY 1
),
mrr_with_growth AS (
    SELECT 
        *,
        LAG(total_mrr) OVER (ORDER BY month_key) as previous_mrr,
        total_mrr - LAG(total_mrr) OVER (ORDER BY month_key) as mrr_change
    FROM monthly_mrr
)
SELECT 
    month_key,
    new_mrr,
    expansion_mrr,
    contraction_mrr,
    churn_mrr,
    total_mrr,
    previous_mrr,
    mrr_change,
    ROUND(
        (mrr_change / NULLIF(previous_mrr, 0)) * 100, 2
    ) as mrr_growth_rate
FROM mrr_with_growth
ORDER BY month_key DESC
```

### 4. SLA Compliance - WhatsApp

**Definição**: Percentual de mensagens respondidas dentro do SLA estabelecido.

**Fórmula**:
```
SLA Compliance = (Mensagens Respondidas no SLA / Total de Mensagens) × 100
```

**Raciocínio**:
- **SLA Definido**: 15 minutos para primeira resposta
- **Horário Comercial**: 8h às 18h, segunda a sexta
- **Exceções**: Fins de semana e feriados têm SLA de 2 horas

**Benchmark**:
- **Excelente**: >95%
- **Bom**: 90-95%
- **Regular**: 80-90%
- **Ruim**: <80%

**Implementação SQL**:
```sql
WITH message_response_times AS (
    SELECT 
        conversation_id,
        message_id,
        received_at,
        first_response_at,
        CASE 
            WHEN EXTRACT(dow FROM received_at) IN (0, 6) THEN 120 -- Weekend: 2 hours
            WHEN EXTRACT(hour FROM received_at) BETWEEN 8 AND 18 THEN 15 -- Business hours: 15 min
            ELSE 120 -- After hours: 2 hours
        END as sla_minutes,
        EXTRACT(EPOCH FROM (first_response_at - received_at)) / 60 as response_time_minutes
    FROM fct_whatsapp_messages
    WHERE received_at >= CURRENT_DATE - INTERVAL '30 days'
      AND message_type = 'incoming'
      AND first_response_at IS NOT NULL
)
SELECT 
    DATE_TRUNC('day', received_at) as date_key,
    COUNT(*) as total_messages,
    COUNT(CASE WHEN response_time_minutes <= sla_minutes THEN 1 END) as messages_in_sla,
    ROUND(
        (COUNT(CASE WHEN response_time_minutes <= sla_minutes THEN 1 END)::float / 
         COUNT(*)) * 100, 2
    ) as sla_compliance_rate,
    ROUND(AVG(response_time_minutes), 2) as avg_response_time_minutes
FROM message_response_times
GROUP BY 1
ORDER BY 1 DESC
```

### 5. Lead Time Médio

**Definição**: Tempo médio entre a criação do pedido e a entrega/conclusão.

**Fórmula**:
```
Lead Time = Média(Data de Conclusão - Data de Criação do Pedido)
```

**Raciocínio**:
- **Início**: Quando pedido é confirmado no sistema
- **Fim**: Quando produto/serviço é entregue/ativado
- **Segmentação**: Por tipo de produto/serviço

**Benchmark por Tipo**:
- **Produtos Físicos**: 5-10 dias
- **Serviços Digitais**: 1-3 dias
- **Implementações**: 15-30 dias

**Implementação SQL**:
```sql
WITH order_lead_times AS (
    SELECT 
        order_id,
        product_type,
        created_at as order_date,
        delivered_at as delivery_date,
        EXTRACT(EPOCH FROM (delivered_at - created_at)) / 86400 as lead_time_days
    FROM fct_orders
    WHERE delivered_at IS NOT NULL
      AND created_at >= CURRENT_DATE - INTERVAL '90 days'
)
SELECT 
    DATE_TRUNC('day', order_date) as date_key,
    product_type,
    COUNT(*) as total_orders,
    ROUND(AVG(lead_time_days), 2) as avg_lead_time_days,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lead_time_days), 2) as median_lead_time_days,
    ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY lead_time_days), 2) as p90_lead_time_days
FROM order_lead_times
GROUP BY 1, 2
ORDER BY 1 DESC, 2
```

### 6. Margem Bruta

**Definição**: Percentual da receita que resta após deduzir os custos diretos.

**Fórmula**:
```
Margem Bruta = ((Receita - Custos Diretos) / Receita) × 100
```

**Raciocínio**:
- **Receita**: Valor total das vendas
- **Custos Diretos**: Custos diretamente atribuíveis ao produto/serviço
  - Custo de produtos vendidos (CPV)
  - Comissões de vendas
  - Custos de processamento de pagamento
  - Custos de suporte técnico

**Benchmark por Setor**:
- **SaaS**: 70-85%
- **E-commerce**: 20-40%
- **Serviços**: 50-70%
- **Produtos Físicos**: 30-50%

**Implementação SQL**:
```sql
WITH monthly_financials AS (
    SELECT 
        DATE_TRUNC('month', sale_date) as month_key,
        product_category,
        SUM(revenue_amount) as total_revenue,
        SUM(cogs_amount) as total_cogs,
        SUM(sales_commission) as total_commissions,
        SUM(payment_processing_fee) as total_payment_fees,
        SUM(support_costs) as total_support_costs
    FROM fct_sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY 1, 2
),
margins AS (
    SELECT 
        month_key,
        product_category,
        total_revenue,
        total_cogs + total_commissions + total_payment_fees + total_support_costs as total_direct_costs,
        total_revenue - (total_cogs + total_commissions + total_payment_fees + total_support_costs) as gross_profit
    FROM monthly_financials
)
SELECT 
    month_key,
    product_category,
    total_revenue,
    total_direct_costs,
    gross_profit,
    ROUND((gross_profit / NULLIF(total_revenue, 0)) * 100, 2) as gross_margin_percent
FROM margins
ORDER BY month_key DESC, gross_margin_percent DESC
```

### 7. ROI de Eventos

**Definição**: Retorno sobre investimento em feiras e eventos de marketing.

**Fórmula**:
```
ROI Eventos = ((Receita Gerada - Investimento) / Investimento) × 100
```

**Raciocínio**:
- **Investimento**: Custo total do evento
  - Taxa de participação
  - Viagem e hospedagem
  - Material promocional
  - Salários da equipe (horas alocadas)
  - Custo de oportunidade

- **Receita Gerada**: Receita atribuída ao evento
  - Vendas diretas no evento
  - Pipeline gerado (com probabilidade de conversão)
  - Vendas posteriores trackadas

**Desafios**:
- **Atribuição**: Definir janela de atribuição (90-180 dias)
- **Multi-touch**: Cliente pode ter múltiplos pontos de contato
- **Valor de longo prazo**: Considerar LTV, não apenas primeira compra

**Implementação SQL**:
```sql
WITH event_investments AS (
    SELECT 
        event_id,
        event_name,
        event_date,
        participation_fee + travel_costs + material_costs + staff_costs as total_investment
    FROM dim_events
    WHERE event_date >= CURRENT_DATE - INTERVAL '12 months'
),
event_revenue AS (
    SELECT 
        e.event_id,
        SUM(s.revenue_amount) as direct_revenue,
        SUM(s.revenue_amount * c.conversion_probability) as pipeline_value
    FROM event_investments e
    JOIN fct_leads l ON l.source_event_id = e.event_id
    LEFT JOIN fct_sales s ON s.lead_id = l.lead_id
    LEFT JOIN fct_pipeline p ON p.lead_id = l.lead_id
    LEFT JOIN dim_conversion_rates c ON c.lead_source = 'event'
    WHERE l.created_at BETWEEN e.event_date AND e.event_date + INTERVAL '90 days'
    GROUP BY 1
)
SELECT 
    i.event_id,
    i.event_name,
    i.event_date,
    i.total_investment,
    COALESCE(r.direct_revenue, 0) as direct_revenue,
    COALESCE(r.pipeline_value, 0) as pipeline_value,
    COALESCE(r.direct_revenue, 0) + COALESCE(r.pipeline_value, 0) as total_expected_revenue,
    ROUND(
        ((COALESCE(r.direct_revenue, 0) + COALESCE(r.pipeline_value, 0) - i.total_investment) / 
         NULLIF(i.total_investment, 0)) * 100, 2
    ) as roi_percent
FROM event_investments i
LEFT JOIN event_revenue r ON i.event_id = r.event_id
ORDER BY i.event_date DESC
```

## 🎯 Metodologia de Definição de Metas

### 1. Análise Histórica

Para cada KPI, analisamos:
- **Tendência**: Crescimento, estabilidade ou declínio
- **Sazonalidade**: Padrões mensais/trimestrais
- **Volatilidade**: Consistência dos resultados

### 2. Benchmarking Competitivo

Comparação com:
- **Concorrentes diretos**: Empresas similares do setor
- **Benchmark de mercado**: Médias da indústria
- **Best practices**: Empresas referência

### 3. Capacidade Organizacional

Avaliação de:
- **Recursos disponíveis**: Equipe, orçamento, tecnologia
- **Maturidade dos processos**: Eficiência atual
- **Capacidade de mudança**: Agilidade organizacional

### 4. Definição de Metas SMART

| KPI | Meta Atual | Meta 6 meses | Meta 12 meses | Justificativa |
|-----|------------|--------------|---------------|---------------|
| Taxa Conversão | 4.2% | 6.0% | 8.5% | Melhoria de processo + automação |
| CAC | R$ 185 | R$ 150 | R$ 120 | Otimização de campanhas |
| MRR Growth | 8.5% | 12.0% | 15.0% | Expansão de mercado |
| SLA Compliance | 78% | 90% | 95% | Automação WhatsApp |
| Lead Time | 8.2 dias | 6.0 dias | 4.5 dias | Processo otimizado |
| Margem Bruta | 42% | 48% | 55% | Redução custos + pricing |
| ROI Eventos | 120% | 180% | 250% | Melhor seleção + follow-up |

## 📊 Metodologia de Coleta e Validação

### 1. Fontes de Dados

**Sistemas Primários**:
- **CRM Ploomes**: Leads, oportunidades, conversões
- **ERP SAP B1**: Vendas, custos, margem
- **WhatsApp Business API**: Mensagens, tempos de resposta
- **Plataformas de Ads**: Google Ads, Facebook Ads
- **Sistemas Financeiros**: Receitas, custos, pagamentos

**Sistemas Secundários**:
- **Analytics**: Google Analytics, Hotjar
- **Email Marketing**: RD Station, Mailchimp
- **Eventos**: Planilhas, sistemas de inscrição
- **Suporte**: Zendesk, Freshdesk

### 2. Qualidade de Dados

**Validações Automáticas**:
- **Completude**: Campos obrigatórios preenchidos
- **Consistência**: Valores dentro de faixas esperadas
- **Unicidade**: Duplicatas identificadas e tratadas
- **Atualidade**: Dados atualizados dentro do SLA

**Exemplo de Validação**:
```sql
-- Validação de Taxa de Conversão
SELECT 
    channel,
    date_key,
    conversion_rate,
    CASE 
        WHEN conversion_rate < 0 THEN 'ERRO: Taxa negativa'
        WHEN conversion_rate > 50 THEN 'ALERTA: Taxa muito alta'
        WHEN conversion_rate IS NULL THEN 'ERRO: Valor nulo'
        ELSE 'OK'
    END as validation_status
FROM fct_conversion_rates
WHERE date_key = CURRENT_DATE - 1
```

### 3. Reconciliação de Dados

**Processo Diário**:
1. **Extração**: Dados coletados de todas as fontes
2. **Transformação**: Limpeza e padronização
3. **Validação**: Testes de qualidade executados
4. **Reconciliação**: Comparação com fontes primárias
5. **Aprovação**: Validação manual dos resultados
6. **Publicação**: Dados disponibilizados no dashboard

## 🔍 Insights e Interpretação

### 1. Análise de Correlações

**Correlações Identificadas**:
- **CAC vs. Lead Time**: Correlação negativa (-0.65)
  - Leads mais rápidos tendem a custar menos
  - Hipótese: Melhor qualificação reduz ciclo

- **SLA WhatsApp vs. Taxa Conversão**: Correlação positiva (0.78)
  - Resposta rápida melhora conversão
  - Hipótese: Experiência do cliente impacta decisão

- **Margem Bruta vs. MRR Growth**: Correlação positiva (0.42)
  - Margem saudável permite reinvestimento
  - Hipótese: Sustentabilidade financeira

### 2. Segmentação Avançada

**Por Canal**:
- **WhatsApp**: Maior conversão, menor volume
- **Ads**: Maior volume, menor qualidade
- **SDR**: Maior ticket médio, ciclo mais longo

**Por Produto**:
- **Produtos Digitais**: Maior margem, menor lead time
- **Serviços**: Maior LTV, maior CAC
- **Implementações**: Maior complexidade, maior satisfação

### 3. Padrões Temporais

**Sazonalidade**:
- **Q4**: Maior volume de vendas (25% acima da média)
- **Janeiro**: Menor performance (15% abaixo da média)
- **Meio de semana**: Melhor conversão em WhatsApp

**Tendências**:
- **CAC**: Crescimento de 15% aa (pressão competitiva)
- **Lead Time**: Redução de 20% aa (melhoria de processo)
- **Margem**: Estabilidade relativa (±3% aa)

## 📈 Projeções e Modelagem

### 1. Modelos Preditivos

**Taxa de Conversão**:
```
Conversão = 0.85 × Conversão_Anterior + 0.15 × Média_Móvel_30d + Sazonalidade
```

**CAC**:
```
CAC = CAC_Base × (1 + Inflação_Ads) × Fator_Competitividade
```

**MRR Growth**:
```
MRR = MRR_Anterior × (1 + Taxa_Crescimento) - Churn_Esperado
```

### 2. Cenários

**Cenário Base**: Manutenção das tendências atuais
**Cenário Otimista**: Implementação bem-sucedida de todas as melhorias
**Cenário Pessimista**: Aumento da competição e pressão de custos

### 3. Simulações

**Impacto de Melhorias**:
- **Automação WhatsApp**: +25% SLA, +15% conversão
- **Otimização Ads**: -20% CAC, +10% volume
- **Processo Otimizado**: -30% lead time, +10% satisfação

---

*Este documento reflete a metodologia completa utilizada para desenvolvimento dos KPIs, garantindo transparência e replicabilidade dos resultados.*
