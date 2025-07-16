-- Modelo de fatos para KPIs operacionais
-- models/marts/operational/fct_kpis_operational.sql

{{
  config(
    materialized='table',
    unique_key='date_key',
    cluster_by=['date_key'],
    tags=['kpi', 'operational']
  )
}}

WITH whatsapp_metrics AS (
  SELECT
    DATE(message_timestamp) as date_key,
    COUNT(*) as total_messages,
    COUNT(CASE WHEN response_time_minutes <= 15 THEN 1 END) as messages_within_sla,
    AVG(response_time_minutes) as avg_response_time
  FROM {{ ref('stg_whatsapp_messages') }}
  WHERE DATE(message_timestamp) >= CURRENT_DATE - INTERVAL '30 days'
    AND message_type = 'received'
    AND response_time_minutes IS NOT NULL
  GROUP BY DATE(message_timestamp)
),

order_metrics AS (
  SELECT
    DATE(order_date) as date_key,
    COUNT(*) as total_orders,
    AVG(DATEDIFF(day, order_date, invoice_date)) as avg_lead_time,
    COUNT(CASE WHEN status = 'Rework' THEN 1 END) as rework_orders
  FROM {{ ref('stg_sap_orders') }}
  WHERE DATE(order_date) >= CURRENT_DATE - INTERVAL '30 days'
    AND invoice_date IS NOT NULL
  GROUP BY DATE(order_date)
),

operational_kpis AS (
  SELECT
    COALESCE(w.date_key, o.date_key) as date_key,
    
    -- WhatsApp SLA
    COALESCE(w.total_messages, 0) as total_messages,
    COALESCE(w.messages_within_sla, 0) as messages_within_sla,
    CASE 
      WHEN w.total_messages > 0 
      THEN (w.messages_within_sla::FLOAT / w.total_messages::FLOAT) * 100 
      ELSE 0 
    END as sla_whatsapp_percent,
    COALESCE(w.avg_response_time, 0) as avg_response_time,
    
    -- Lead Time
    COALESCE(o.total_orders, 0) as total_orders,
    COALESCE(o.avg_lead_time, 0) as avg_lead_time_days,
    COALESCE(o.rework_orders, 0) as rework_orders,
    CASE 
      WHEN o.total_orders > 0 
      THEN (o.rework_orders::FLOAT / o.total_orders::FLOAT) * 100 
      ELSE 0 
    END as rework_rate_percent
    
  FROM whatsapp_metrics w
  FULL OUTER JOIN order_metrics o ON w.date_key = o.date_key
)

SELECT
  date_key,
  total_messages,
  messages_within_sla,
  sla_whatsapp_percent,
  avg_response_time,
  total_orders,
  avg_lead_time_days,
  rework_orders,
  rework_rate_percent,
  CURRENT_TIMESTAMP as updated_at
FROM operational_kpis
ORDER BY date_key DESC
