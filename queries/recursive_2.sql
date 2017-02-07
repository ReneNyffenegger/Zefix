.mode column
.width 9 9  70 70

select
  lvl_1.id,
  lvl_2.id,
  bez_1.bezeichnung,
  bez_2.bezeichnung
from
  firma     lvl_1                                                                          join
  firma     lvl_2 on lvl_1.id       = lvl_2.id_hauptsitz                              left join
  firma_bez bez_1 on bez_1.id_firma = lvl_1.id and bez_1.status = 3 and bez_1.typ = 1 left join 
  firma_bez bez_2 on bez_2.id_firma = lvl_2.id and bez_2.status = 3 and bez_2.typ = 1
order by
  lvl_1.id,
  lvl_2.id
;
