.mode column
.width 9 9 9  50 50 70


with lvl_1 as (
  select
    lvl_1.id
--  lvl_2.id,
--  lvl_3.id
  from
    firma lvl_1                                   join
    firma lvl_2 on lvl_1.id = lvl_2.id_hauptsitz  join
    firma lvl_3 on lvl_2.id = lvl_3.id_hauptsitz
  where
    lvl_1.id_hauptsitz is null
)
select
  lvl_1.id,
  lvl_2.id,
  lvl_3.id,
  bez_1.bezeichnung,
  bez_2.bezeichnung,
  bez_3.bezeichnung
from
            lvl_1                                                                     left join
  firma     lvl_2 on lvl_1.id = lvl_2.id_hauptsitz                                    left join
  firma     lvl_3 on lvl_2.id = lvl_3.id_hauptsitz                                    left join
  firma_bez bez_1 on lvl_1.id = bez_1.id_firma and bez_1.status = 3 and bez_1.typ = 1 left join
  firma_bez bez_2 on lvl_2.id = bez_2.id_firma and bez_2.status = 3 and bez_2.typ = 1 left join
  firma_bez bez_3 on lvl_3.id = bez_3.id_firma and bez_3.status = 3 and bez_3.typ = 1
order by
  lvl_1.id,
  lvl_2.id,
  lvl_3.id;

