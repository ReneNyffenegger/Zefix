.mode column
.width 4 8 8 70
select
  count(*),
  min(person.id),
  max(person.id),
  von
from
  person
where
  von not in (select name from gemeinde)
group by
  von
order by
  count(*) desc; 
