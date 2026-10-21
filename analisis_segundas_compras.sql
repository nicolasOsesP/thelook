-- ====================================================
-- ¿Cuánto tarda un cliente en hacer su segunda compra?
-- (Sirve para definir cuándo enviar una campaña de recompra)
-- =====================================================

with ordenes_usuario as (
select
  user_id,
  order_id,
  created_at,
  row_number() over(partition by user_id order by created_at) as n_orden,
  lag(created_at) over(partition by user_id order by created_at) as fecha_orden_anterior
from `thelook.orders`
where status != 'Cancelled'
), segunda_compra as (
  select 
    user_id,
    timestamp_diff(created_at, fecha_orden_anterior, day) as dias_entre_compras
  from ordenes_usuario
  where n_orden = 2
)
select 
  count(*) as clientes_con_segunda_compra,
  approx_quantiles(dias_entre_compras, 100)[offset(25)] as p25_dias,
  approx_quantiles(dias_entre_compras, 100)[offset(50)] as p50_dias,
  approx_quantiles(dias_entre_compras, 100)[offset(75)] as p75_dias,
  round(avg(dias_entre_compras)) as media_dias
from segunda_compra;

-- ====================================================
-- P25 = 99 días: aproximadamente el 25% de los clientes tardó hasta 99 días en realizar su segunda compra.
-- P50 = 280 días: aproximadamente el 50% tardó hasta 280 días. Es la mediana.
-- P75 = 631 días: aproximadamente el 75% tardó hasta 631 días.
-- En promedio los clientes tardan 434 días en hacer su segunda compra
-- ====================================================
