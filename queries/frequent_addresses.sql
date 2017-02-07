.mode column
.width  6 30 10 4 30
select
  count(*),
  strasse,
  hausnummer || address_zusatz,
  plz,
  ort
from
  firma
group by
  strasse,
  hausnummer || address_zusatz,
  plz,
  ort
order by
  count(*) desc
limit 100;

