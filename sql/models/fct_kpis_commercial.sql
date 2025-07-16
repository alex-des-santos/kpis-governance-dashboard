-- Modelo de fatos para KPIs comerciais
-- models/marts/commercial/fct_kpis_commercial.sql

{{
  config(
    materialized='table',
    unique_key='date_key',
    cluster_by=['date_key'],
    tags=['kpi', 'commercial']
  )
}}

WITH daily_leads AS (
  SELECT
    DATE(created_at) as date_key,
    channel,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN status = 'Won' THEN 1 END) as converted_leads,
    SUM(CASE WHEN status = 'Won' THEN deal_value ELSE 0 END) as total_revenue,
    SUM(marketing_cost) as marketing_cost
  FROM {{ ref('stg_ploomes_leads') }}
  WHERE DATE(created_at) >= CURRENT_DATE - INTERVAL '90 days'
  GROUP BY DATE(created_at), channel
),

channel_aggregated AS (
  SELECT
    date_key,
    SUM(total_leads) as total_leads,
    SUM(converted_leads) as converted_leads,
    SUM(total_revenue) as total_revenue,
    SUM(marketing_cost) as marketing_cost
  FROM daily_leads
  GROUP BY date_key
),

kpis_calculated AS (
  SELECT
    date_key,
    total_leads,
    converted_leads,
    total_revenue,
    marketing_cost,
    
    -- Taxa de Conversão
    CASE 
      WHEN total_leads > 0 
      THEN (converted_leads::FLOAT / total_leads::FLOAT) * 100 
      ELSE 0 
    END as conversion_rate,
    
    -- CAC (Customer Acquisition Cost)
    CASE 
      WHEN converted_leads > 0 
      THEN marketing_cost::FLOAT / converted_leads::FLOAT 
      ELSE 0 
    END as cac,
    
    -- Valor Médio do Pedido
    CASE 
      WHEN converted_leads > 0 
      THEN total_revenue::FLOAT / converted_leads::FLOAT 
      ELSE 0 
    END as avg_deal_value
    
  FROM channel_aggregated
)

SELECT
  date_key,
  total_leads,
  converted_leads,
  total_revenue,
  marketing_cost,
  conversion_rate,
  cac,
  avg_deal_value,
  CURRENT_TIMESTAMP as updated_at
FROM kpis_calculated
ORDER BY date_key DESC
