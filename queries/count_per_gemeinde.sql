-- select
--   count(*),
--   id_gemeinde
-- from
--   firma
-- where
--   id_hauptsitz is null and
--   status != 0
-- group by
--   id_gemeinde
-- order by
--   count(*) desc
-- limit 10;

select
  count(*),
  plz
from
  firma
where
  id_hauptsitz is null and
  status != 0          and
  id_gemeinde =  261 
--id_gemeinde = 6621
--id_gemeinde = 1711
--id_gemeinde = 2701
--id_gemeinde = 5191
--id_gemeinde = 5586
--id_gemeinde =  351
--id_gemeinde = 1061
group by
  plz
order by
  count(*) desc;
