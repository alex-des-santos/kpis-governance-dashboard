# Arquitetura de Dados - Lakehouse Approach

## Visão Geral

A arquitetura proposta adota uma abordagem "lakehouse" que combina as vantagens de um data lake (flexibilidade e baixo custo) com as capacidades analíticas de um data warehouse (performance e consultas SQL).

## Camadas da Arquitetura

### 1. Camada de Ingestão & CDC

**Objetivo**: Capturar dados das fontes com mínimo impacto operacional

**Ferramentas**:
- **Airbyte**: Conectores open-source para a maioria das fontes
- **Fivetran**: Fallback para conectores críticos não disponíveis no Airbyte
- **N8N**: Orquestração de webhooks do WhatsApp Business API
- **CDC (Change Data Capture)**: Para SAP B1 e Ploomes

**Fontes de Dados**:
- CRM Ploomes
- ERP SAP B1
- WhatsApp Business API (via N8N)
- Plataformas de ads (Google Ads, Facebook Ads)
- Site/E-commerce
- Planilhas legadas (migração gradual)

### 2. Raw Zone (Data Lake)

**Objetivo**: Armazenar dados brutos de forma imutável e versionada

**Tecnologias**:
- **Armazenamento**: Amazon S3, Azure Data Lake Storage, Google Cloud Storage
- **Formato**: Apache Parquet ou Apache Iceberg
- **Organização**: Particionamento por data e fonte
- **Versionamento**: Time-travel capabilities para auditoria

**Estrutura**:
```
raw/
├── ploomes/
│   ├── year=2024/month=01/day=15/
│   └── leads_20240115_001.parquet
├── sap_b1/
│   ├── year=2024/month=01/day=15/
│   └── invoices_20240115_001.parquet
└── whatsapp/
    ├── year=2024/month=01/day=15/
    └── messages_20240115_001.parquet
```

### 3. Staging & Transform

**Objetivo**: Limpeza, padronização e enriquecimento dos dados

**Ferramenta Principal**: dbt (Data Build Tool)

**Processos**:
- **Limpeza**: Remoção de duplicatas, tratamento de nulos
- **Padronização**: Tipos de dados consistentes, nomenclatura unificada
- **Enriquecimento**: Cálculos derivados, classificações
- **Testes**: Validação automática de qualidade

**Modelos dbt**:
```sql
-- models/staging/stg_ploomes_leads.sql
WITH source AS (
    SELECT * FROM {{ ref('raw_ploomes_leads') }}
),

cleaned AS (
    SELECT
        lead_id,
        TRIM(LOWER(email)) AS email,
        COALESCE(phone, '') AS phone,
        DATE(created_at) AS created_date,
        CASE 
            WHEN status = 'Won' THEN 'Convertido'
            WHEN status = 'Lost' THEN 'Perdido'
            ELSE 'Em Andamento'
        END AS status_ptbr
    FROM source
    WHERE email IS NOT NULL
)

SELECT * FROM cleaned
```

### 4. Warehouse/Lakehouse

**Objetivo**: Fornecer interface SQL para consultas analíticas

**Opções de Tecnologia**:
- **Snowflake**: Melhor para workloads analíticos complexos
- **Google BigQuery**: Ótimo custo-benefício para consultas ad-hoc
- **Azure Synapse**: Integração nativa com ecossistema Microsoft

**Modelagem**:
- **Esquema estrela**: Fatos e dimensões para performance
- **Materialização**: Views materializadas para KPIs frequentes
- **Particionamento**: Por data para queries otimizadas

### 5. Semantic/Metric Layer

**Objetivo**: Padronizar definições de métricas e eliminar divergências

**Ferramentas**:
- **dbt Metrics**: Definições centralizadas de KPIs
- **Cube.dev**: API de métricas para aplicações
- **LookML**: Se usando Looker como BI

**Exemplo de Métrica**:
```yaml
# models/metrics/mrr.yml
version: 2

metrics:
  - name: mrr
    label: Monthly Recurring Revenue
    model: ref('fct_subscriptions')
    description: "Total de receita recorrente mensal"
    calculation_method: sum
    expression: monthly_value
    timestamp: date_month
    time_grains: [month, quarter, year]
    dimensions:
      - customer_segment
      - product_category
    filters:
      - field: is_active
        operator: '='
        value: true
```

### 6. BI & Applications

**Objetivo**: Democratizar o acesso aos dados através de dashboards e APIs

**Ferramentas de BI**:
- **Power BI**: Integração com ecossistema Microsoft
- **Tableau**: Visualizações avançadas
- **Looker Studio**: Custo-benefício para dashboards simples

**APIs e Aplicações**:
- **GraphQL**: APIs flexíveis para aplicações internas
- **REST APIs**: Integração com sistemas legados
- **Alertas**: Notificações automáticas via Slack/Teams

## Governança e Qualidade

### Data Catalog

**Ferramentas**:
- **OpenMetadata**: Open-source, completo
- **Apache Atlas**: Integração com ecossistema Hadoop
- **Magda**: Leve e flexível

**Funcionalidades**:
- Catalogação automática de datasets
- Documentação colaborativa
- Linhagem de dados
- Classificação de sensibilidade

### Qualidade de Dados

**Great Expectations**:
- Testes automatizados de qualidade
- Profiling de dados
- Alertas de anomalias
- Integração com pipelines dbt

**Exemplo de Teste**:
```python
# tests/test_leads_quality.py
def test_leads_email_format():
    return {
        "expectation_type": "expect_column_values_to_match_regex",
        "kwargs": {
            "column": "email",
            "regex": r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        }
    }
```

### Linhagem de Dados

**OpenLineage**:
- Rastreamento automático de transformações
- Integração com Airflow e dbt
- Visualização de dependências
- Análise de impacto de mudanças

### Segurança

**Controles**:
- **RBAC**: Controle de acesso baseado em papéis
- **Criptografia**: At-rest e in-transit
- **Auditoria**: Logs de acesso e modificações
- **Mascaramento**: Dados sensíveis em ambientes de desenvolvimento

## Monitoramento e Observabilidade

### Métricas de Performance

**Grafana + Prometheus**:
- Latência de pipelines ETL
- Taxa de sucesso de jobs
- Utilização de recursos
- Tempo de resposta de queries

### Alertas

**Configurações**:
- Pipeline failures → Slack crítico
- Qualidade de dados → Email para stewards
- Performance degradada → Teams para DevOps

### SLAs

| Fonte | SLA Atualização | SLA Disponibilidade |
|-------|----------------|-------------------|
| CRM Ploomes | 15 minutos | 99.5% |
| ERP SAP B1 | 30 minutos | 99.9% |
| WhatsApp API | 5 minutos | 99.0% |
| Ads Platforms | 1 hora | 95.0% |

## Escalabilidade

### Horizontal Scaling

- **Spark**: Para processamento de grandes volumes
- **Kubernetes**: Orquestração de containers
- **Auto-scaling**: Ajuste automático de recursos

### Otimizações

- **Particionamento**: Por data e fonte
- **Compressão**: Parquet com compressão Snappy
- **Caching**: Resultados de queries frequentes
- **Indexação**: Colunas de filtro comuns

## Conclusão

A arquitetura lakehouse proposta oferece:

- **Flexibilidade**: Suporte a dados estruturados e não-estruturados
- **Performance**: Consultas SQL otimizadas
- **Custo-efetividade**: Armazenamento barato no data lake
- **Governança**: Controles centralizados de qualidade e segurança
- **Escalabilidade**: Crescimento horizontal conforme necessidade

Esta arquitetura posiciona a empresa para crescer de forma sustentável, mantendo a qualidade dos dados e a velocidade de insights.
