alter table radios_rosario add column cluster integer;
update radios_rosario set cluster = 0;

with total as (
  select sum(vivs) total_vivs, sum(desocupado) total_desocupado
  from radios_rosario
  )
select  sum(1.0*total_vivs/vivs *
           vivs/vivs *
          (vivs/vivs * desocupado - desocupado)^2)
        as "Mínimo SCW cada radio es un cluster",
        sum(1.0*total_vivs/vivs *
           vivs/total_vivs *
          (total_vivs/vivs * desocupado - total_desocupado)^2)
        as "Máximo SCW todos los radios en 1 cluster"
from total, radios_rosario
;
          

/*          
 Mínimo SCW cada radio es un cluster | Máximo SCW todos los radios en 1 cluster
-------------------------------------+------------------------------------------
                                   0 |                             395074120125
(1 fila)

Algoritmo

juntar radios de a pares maximizando dSCW

Calcular cardinality de adyacencias

with ambos_lados as (
  select ffrr_i, ffrr_j
  from adyacencias
  union
  select ffrr_j, ffrr_i
  from adyacencias
)
select codigo, vivs, desocupado, 
    cardinality(array_agg(distinct ffrr_j)), 
    array_agg(distinct ffrr_j order by ffrr_j)
from radios_rosario
join ambos_lados
on codigo = ffrr_i
group by codigo, vivs, desocupado
order by 4, vivs desc
;

0. Juntar primero los que tengan 0 (Islas) con el más próximo usando st_distance()

¿Recalcular cardinality, ya con cluster que contienen las Islas?
1. Juntar los que tengan 1: Tienen un solo radio adyacente

¡Recalcular cardinality ahora ya con clusters!
Los radios sueltos se consideran clusters
y recalcularla después de cada fusion
que se elige maximizando dSCW
sujeto a tamaño menor que cierto valor m.
Este valor se irá duplicando a medida que avanza el algoritmo...
... cuando ya todos los cluster contienen 2 o + radios (más de 1 radio)
o ese radio es mayor al tamaño aceptable.


*/

DROP TABLE fronteras;
CREATE TABLE fronteras AS
WITH intersecciones AS (
  SELECT i.i as cluster_i, j.i cluster_j,
    ST_Intersection(i.wkb_geometry, j.wkb_geometry) interseccion_ij
  FROM radios_rosario i
  JOIN radios_rosario j
  ON i.wkb_geometry && j.wkb_geometry
  AND ST_Dimension(ST_Intersection(i.wkb_geometry, j.wkb_geometry)) > 0
  AND i.i < j.i
  )
SELECT cluster_i, cluster_j, st_length(interseccion_ij) longitud
FROM intersecciones
;


UPDATE radios_rosario SET cluster = i;

---------------------- Seleccionar con cardinality 0 ó 1
with ambos_lados as (
  select cluster_i, cluster_j
  from fronteras
  union
  select cluster_j, cluster_i
  from fronteras
)
select i, vivs, desocupado, 
    cardinality(array_agg(distinct cluster_j)), 
    array_agg(distinct cluster_j order by cluster_j)
from radios_rosario
join ambos_lados
on cluster_i = cluster  -- cada cluster es un radio
group by radios_rosario.i, vivs, desocupado
-- condición de primera vuelta
having cardinality(array_agg(distinct cluster_j)) < 2
order by 4, vivs desc
;
/*
 i  | vivs | desocupado | cardinality | array_agg
----+------+------------+-------------+-----------
 12 |  155 |         10 |           1 | {32}
(1 fila)
*/

--- seteo cluster en el menor
update radios_rosario set cluster = 12 where cluster = 32;
update fronteras set cluster_i = 12 where cluster_i = 32;
update fronteras set cluster_j = 12 where cluster_j = 32;

--- Ahora busco entre los que tienen 2 opciones
with ambos_lados as (
  select cluster_i, cluster_j
  from fronteras
  union
  select cluster_j, cluster_i
  from fronteras
),
los_que_tienen_2_vecinos as (
    select i
    from radios_rosario
    join ambos_lados
    on cluster_i = cluster  -- cada cluster es un radio
    group by i
    -- condición de primera vuelta
    having count(distinct cluster_j) = 2
)
select cluster_i, cluster_j, 
r_i.vivs vivs_i, r_j.vivs vivs_j, r_i.vivs + r_j.vivs sum_vivs,
r_i.desocupado desocupado_i, r_j.desocupado desocupado_j,
100*r_i.desocupado/r_i.vivs porc_i, 100*r_j.desocupado/r_j.vivs porc_j,
abs(100*r_i.desocupado/r_i.vivs - 100*r_j.desocupado/r_j.vivs) delta_porc
from los_que_tienen_2_vecinos lq2v
join ambos_lados al
on lq2v.i = al.cluster_i
join radios_rosario r_i
on r_i.i = lq2v.i
join radios_rosario r_j
on r_j.i = cluster_j
order by (r_i.vivs + r_j.vivs)/100*100,
abs(100*r_i.desocupado/r_i.vivs - 100*r_j.desocupado/r_j.vivs) desc
;

/*
 cluster_i | cluster_j | vivs_i | vivs_j | sum_vivs | desocupado_i | desocupado_j | porc_i | porc_j | delta_porc
-----------+-----------+--------+--------+----------+--------------+--------------+--------+--------+------------
       899 |       898 |    183 |     71 |      254 |           25 |           13 |     13 |     18 |          5
      1025 |      1027 |    290 |     76 |      366 |           48 |            5 |     16 |      6 |         10
      1026 |      1027 |    240 |     76 |      316 |           29 |            5 |     12 |      6 |          6
       694 |       695 |    221 |    172 |      393 |           41 |           37 |     18 |     21 |          3
      1055 |      1056 |    105 |    266 |      371 |           12 |           24 |     11 |      9 |          2
      1055 |       797 |    105 |    235 |      340 |           12 |           24 |     11 |     10 |          1
       694 |       704 |    221 |     85 |      306 |           41 |           16 |     18 |     18 |          0
         2 |        10 |    256 |    187 |      443 |           80 |           29 |     31 |     15 |         16
       899 |       900 |    183 |    281 |      464 |           25 |           56 |     13 |     19 |          6
         2 |         9 |    256 |    288 |      544 |           80 |           29 |     31 |     10 |         21
       687 |       684 |    313 |    258 |      571 |           75 |           35 |     23 |     13 |         10
       552 |       539 |    283 |    269 |      552 |           44 |           24 |     15 |      8 |          7
       552 |       540 |    283 |    285 |      568 |           44 |           25 |     15 |      8 |          7
      1026 |      1012 |    240 |    283 |      523 |           29 |           48 |     12 |     16 |          4
      1025 |      1024 |    290 |    340 |      630 |           48 |           98 |     16 |     28 |         12
       813 |       805 |    391 |    287 |      678 |           87 |           32 |     22 |     11 |         11
       687 |       686 |    313 |    323 |      636 |           75 |           48 |     23 |     14 |          9
        15 |        16 |    312 |    362 |      674 |           27 |           21 |      8 |      5 |          3
        15 |        14 |    312 |    331 |      643 |           27 |           21 |      8 |      6 |          2
       556 |       557 |    341 |    329 |      670 |           47 |           38 |     13 |     11 |          2
       556 |       542 |    341 |    360 |      701 |           47 |           68 |     13 |     18 |          5
       813 |       812 |    391 |    430 |      821 |           87 |           34 |     22 |      7 |         15
(22 filas)


*/
