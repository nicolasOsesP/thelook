-- =====================================================================
-- PREGUNTA 4. ¿Qué segmentos de clientes existen según su recencia,
-- frecuencia y gasto (RFM), y cuánto del ingreso aporta cada uno?
-- =====================================================================

with base as (
  select 
    user_id,
    max(date(created_at)) as maxd,
    date_diff(date('2026-10-01'), max(date(created_at)), day) as recencia_dias,
    count(distinct order_id) as frecuencia,
    round(sum(sale_price), 2) as monto
  from `thelook.order_items`
  where status not in ('Cancelled', 'Returned')
  group by user_id
  order by frecuencia desc
), scores as (
  select
    *,
    ntile(5) over(order by recencia_dias desc) as score_recencia, -- 5  = compro hace poco
    ntile(5) over(order by frecuencia desc) as score_frecuencia,   -- 5 = compra seguido
    ntile(5) over(order by monto desc) as score_monto             -- 5 = gasto alto
  from base
), segmentos as (
  select
    *,
    case
      when score_recencia >= 4 and score_frecuencia >= 4 then 'Campeones'
      when score_recencia >= 3 and score_frecuencia >= 3 then 'Leales'
      when score_recencia >= 3 and score_frecuencia <= 2 then 'Prometedores'
      when score_recencia <= 2 and score_frecuencia >= 3 then 'En riesgo'
      when score_recencia <= 2 and score_frecuencia <= 2 then 'Perdidos'
      else 'Necesitan atención'
    end as segmento
  from scores
)
select
  segmento,
  count(*) as clientes,
  round(avg(recencia_dias)) as prom_recencia_dias,
  round(avg(frecuencia), 2) as prom_frecuencia,
  round(sum(monto), 2) as ingresos,
  round(sum(monto) / sum(sum(monto)) over() * 100, 2) as pct_ingresos
from segmentos
group by segmento
order by ingresos desc;



