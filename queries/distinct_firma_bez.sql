select
  count(*),
  f.bezeichnung,
  g.name
from
  firma    f join
  gemeinde g on f.id_gemeinde = g.id
--where
--  id_hauptsitz is null
group by
  f.bezeichnung,
  g.name
order by
  count(*) desc
limit 100;
