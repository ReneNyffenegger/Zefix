select count(*) from person where von         like ' %'; 
select count(*) from person where von         like '% ';

select count(*) from person where vorname     like ' %';
select count(*) from person where vorname     like '% ';

select count(*) from person where nachname    like ' %';
select count(*) from person where nachname    like '% ';

select count(*) from person where bezeichnung like ' %';
select count(*) from person where bezeichnung like '% ';

select count(*) from person_firma where funktion like ' %';
select count(*) from person_firma where funktion like '% ';

-- 
-- select
--   'http://renenyffenegger.ch/Firmen/f' || f.id || ' ',
--   f.bezeichnung,
--   '>' || p.von || '<'
-- from
--   person       p                         join
--   person_firma pf on p.id = pf.id_person join
--   firma         f on f.id = pf.id_firma
-- where
--   p.von like '% ';
-- 

