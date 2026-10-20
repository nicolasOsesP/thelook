-- =====================================================================
-- PREGUNTA 3. De los clientes que compraron por primera vez en un mes
-- dado, ¿qué porcentaje vuelve a comprar en los meses siguientes?
-- (Retención por cohortes)
-- Funciones de ventana: MIN() OVER, MAX() OVER
-- =====================================================================

-- =====================================================================
-- HALLAZGOS: 
-- RECOMENDACIONES:
-- =====================================================================

-- select oi.user_id, u.first_name, u.last_name, count(*) as cant_compras
-- from `thelook.users` u join `thelook.order_items` oi on oi.user_id = u.id
-- where oi.status not in ('Returned', 'Cancelled')
-- group by user_id, u.first_name, u.last_name
-- order by cant_compras desc;

with compras as (
  select 
    user_id, 
    date_trunc(date(created_at), month)  as mes_compra
  from `thelook.orders`
  where status != 'Cancelled'
  group by user_id, mes_compra
), cohorte as (
  select 
    user_id, 
    mes_compra, 
    min(mes_compra) over(partition by user_id) as mes_cohorte
  from compras
), actividad as (
  select
    mes_cohorte,
    date_diff(mes_compra, mes_cohorte, month) as meses_desde_primera_compra,
    count(distinct user_id) as clientes_activos
  from cohorte
  group by mes_cohorte, meses_desde_primera_compra
)
select
  mes_cohorte,
  meses_desde_primera_compra,
  clientes_activos,
  max(if(meses_desde_primera_compra = 0, clientes_activos, null)) over(partition by mes_cohorte) as tamano_cohorte,
  round(clientes_activos / max(if(meses_desde_primera_compra = 0, clientes_activos, null)) over(partition by mes_cohorte) * 100, 2) as pct_retencion
from actividad
where meses_desde_primera_compra <= 12
order by mes_cohorte, meses_desde_primera_compra;