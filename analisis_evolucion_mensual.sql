-- =====================================================================
-- PREGUNTA 1. ¿Cómo evolucionan los ingresos, las órdenes y el ticket
-- promedio mes a mes, y en qué meses crece o cae el negocio?
-- =====================================================================

-- =====================================================================
-- HALLAZGOS: 
-- RECOMENDACIONES:
-- =====================================================================

with ventas_por_mes as (
  select 
  date_trunc(date(created_at), month) as mes,
  count(distinct order_id) as ordenes,
  count(distinct user_id) as clientes,
  round(sum(sale_price), 2) as ingresos,
  round(round(sum(sale_price), 2)/count(distinct order_id), 2) as ticket_promedio
from `thelook.order_items`
where status not in ('Cancelled', 'Returned')
group by mes
)
select
  mes,
  ordenes,
  clientes,
  ingresos,
  ticket_promedio,
  round(safe_divide(ingresos - lag(ingresos, 1, 0) over(order by mes), lag(ingresos) over(order by mes)) * 100, 2) as crecimiento_ingresos_pct,
  round(safe_divide(ordenes - lag(ordenes, 1, 0) over(order by mes), lag(ordenes) over(order by mes)) * 100, 2) as crecimiento_ordenes_pct,
  round(safe_divide(ticket_promedio - lag(ticket_promedio, 1, 0) over(order by mes), lag(ticket_promedio) over(order by mes)) * 100, 2) as crecimiento_ticket_pct,
  round(sum(ingresos) over(partition by extract(year from mes) order by mes), 2) as ingresos_acumulados_anio
from ventas_por_mes
order by mes;