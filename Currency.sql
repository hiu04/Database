select *
from xiaoyuma_db.simpsons."CADCNY=X" as c; -- download from yahoo finance

create table t as (
with rank as (
select cast(c."Date" as date) as date, c.*
    from xiaoyuma_db.simpsons."CADCNY=X" as c)
select extract(year from r.date) as year,
       extract(month from r.date) as month,
       extract(day from r.date) as day,
       r."High",
       rank() over (partition by
           extract(year from r.date),
           extract(month from r.date)
           order by r."High")
from rank as r);


with lowest_300 as (
select t.year, t.month, t."High"
from t
group by t.year, t.month, t."High"
order by t."High"
limit 300)  -- 300 lowest high currency from Jan 2018 to Jun 2023
select l.month, count(l.month)  -- count which month(s) have greatest number of low currency
from lowest_300 as l
group by l.month
order by count(l.month) desc;  -- Results: low in Mar, Apr; high in Jul, Aug and Sep
