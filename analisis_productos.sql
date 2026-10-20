-- =====================================================================
-- PREGUNTA 2. ¿Qué productos dejan más margen dentro de cada categoría
-- y cuánto del margen de la categoría concentran?
-- =====================================================================

-- =====================================================================
-- HALLAZGOS: 
-- RECOMENDACIONES:
-- =====================================================================

with ventas_producto as (
  select  
    p.category as categoria, 
    p.name as producto, 
    p.id as producto_id, 
    count(*) as unidades,
    round(sum(oi.sale_price), 2) as ingresos,
    round(sum(oi.sale_price - p.cost), 2) as margen
  from `thelook.order_items` oi join `thelook.products` p on oi.product_id = p.id
  where oi.status not in ('Cancelled', 'Returned')
  group by p.category, p.name, p.id
), ranking as (
  select 
    *, 
    rank() over(partition by categoria order by margen desc) as rank_categoria,
    round(margen / sum(margen) over(partition by categoria) * 100, 2) as pct_margen_categoria
  from ventas_producto
)
select 
  *
from ranking
where rank_categoria <= 3
order by categoria, rank_categoria;


