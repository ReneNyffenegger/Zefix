-- select
--   count(*),
--   bezeichnung
-- from
--   firma
-- where
--   id_hauptsitz is null
-- group by
--   bezeichnung
-- order by
--   count(*) desc
-- limit 100;

select
  count(*),
  replace(
  replace(
  replace(
  replace(
  replace(
  replace(f.bezeichnung,
          '"', '"'),
          "'", "'"),
          ":", ':'),
          ".", '.'),
          "+", '+'),
          " ", ' '),
  g.name
from
  firma    f join
  gemeinde g on f.id_gemeinde = g.id
where
  id_hauptsitz is null and
  status != 0
group by
  replace(
  replace(
  replace(
  replace(
  replace(
  replace(f.bezeichnung,
          '"', '"'),
          "'", "'"),
          ":", ':'),
          ".", '.'),
          "+", '+'),
          " ", ' '),
  g.name
order by
  count(*) desc
limit 20;
