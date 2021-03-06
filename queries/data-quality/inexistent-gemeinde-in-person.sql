.mode column
.width 4 8 8 70
select
  count(*),
  min(person.id),
  max(person.id),
  von || '<'
from
  person
where
  von not like '% und %' and
  von not like '% e %' and
  von not like '%Staatsangehörige%' and
  von not like 'cittadin%' and
  von not like 'citoyen%' and
  von not in (select name from gemeinde)
group by
  von || '<'
order by
  von;
