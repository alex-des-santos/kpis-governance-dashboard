-- Modelo de fatos para KPIs financeiros
-- models/marts/financial/fct_kpis_financial.sql

{{
  config(
    materialized='table',
    unique_key='date_key',
    cluster_by=['date_key'],
    tags=['kpi', 'financial']
  )
}}

WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC('month', invoice_date) as month_key,
    SUM(invoice_amount) as total_revenue,
    SUM(product_cost) as total_cogs,
    COUNT(DISTINCT customer_id) as unique_customers
  FROM {{ ref('stg_sap_invoices') }}
  WHERE invoice_date >= CURRENT_DATE - INTERVAL '12 months'
  GROUP BY DATE_TRUNC('month', invoice_date)
),

recurring_revenue AS (
  SELECT
    DATE_TRUNC('month', contract_start_date) as month_key,
    SUM(monthly_value) as mrr_amount
  FROM {{ ref('stg_sap_contracts') }}
  WHERE contract_status = 'Active'
    AND contract_start_date >= CURRENT_DATE - INTERVAL '12 months'
  GROUP BY DATE_TRUNC('month', contract_start_date)
),

events_roi AS (
  SELECT
    event_date,
    event_name,
    event_cost,
    COUNT(DISTINCT lead_id) as leads_generated,
    SUM(revenue_generated) as revenue_from_event
  FROM {{ ref('stg_events_performance') }}
  WHERE event_date >= CURRENT_DATE - INTERVAL '12 months'
  GROUP BY event_date, event_name, event_cost
),

financial_kpis AS (
  SELECT
    r.month_key as date_key,
    
    -- Receita e Margem
    COALESCE(r.total_revenue, 0) as total_revenue,
    COALESCE(r.total_cogs, 0) as total_cogs,
    CASE 
      WHEN r.total_revenue > 0 
      THEN ((r.total_revenue - r.total_cogs) / r.total_revenue) * 100 
      ELSE 0 
    END as gross_margin_percent,
    
    -- MRR
    COALESCE(mr.mrr_amount, 0) as mrr_amount,
    
    -- Customers
    COALESCE(r.unique_customers, 0) as unique_customers
    
  FROM monthly_revenue r
  LEFT JOIN recurring_revenue mr ON r.month_key = mr.month_key
),

events_aggregated AS (
  SELECT
    DATE_TRUNC('month', event_date) as month_key,
    SUM(event_cost) as total_event_cost,
    SUM(leads_generated) as total_leads_from_events,
    SUM(revenue_from_event) as total_revenue_from_events,
    CASE 
      WHEN SUM(event_cost) > 0 
      THEN ((SUM(revenue_from_event) - SUM(event_cost)) / SUM(event_cost)) * 100 
      ELSE 0 
    END as events_roi_percent
  FROM events_roi
  GROUP BY DATE_TRUNC('month', event_date)
),

final_kpis AS (
  SELECT
    f.date_key,
    f.total_revenue,
    f.total_cogs,
    f.gross_margin_percent,
    f.mrr_amount,
    f.unique_customers,
    COALESCE(e.total_event_cost, 0) as total_event_cost,
    COALESCE(e.total_leads_from_events, 0) as total_leads_from_events,
    COALESCE(e.total_revenue_from_events, 0) as total_revenue_from_events,
    COALESCE(e.events_roi_percent, 0) as events_roi_percent
  FROM financial_kpis f
  LEFT JOIN events_aggregated e ON f.date_key = e.month_key
)

SELECT
  date_key,
  total_revenue,
  total_cogs,
  gross_margin_percent,
  mrr_amount,
  unique_customers,
  total_event_cost,
  total_leads_from_events,
  total_revenue_from_events,
  events_roi_percent,
  CURRENT_TIMESTAMP as updated_at
FROM final_kpis
ORDER BY date_key DESC
