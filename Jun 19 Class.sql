-- Jun 19 2023 Class
create SCHEMA simpsons;
create table simpsons.characters (
    character_id INTEGER,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    date_of_birth DATE,
    salary NUMERIC
    );

INSERT INTO simpsons.characters(character_id, first_name, last_name, date_of_birth, salary)
VALUES (1, 'Homer', 'Simpson', '1980/1/1', 50000),
       (2, 'Marge','Simpson', '1982/3/15',40000),
       (3, 'Lisa','Simpson', '2014/7/15', null), -- 0 or null
       (4, 'Bart', 'Simpson', '2012/5/1',0),
       (5, 'Maggie', 'Simpson', '2020/12/25', 0),
       (6, 'Ned', 'Flanders', '1981/10/12', 70000),
       (7, 'Moe', 'Szyslak', '1980/2/1', 80000),
       (8, 'Ralph', 'Wiggum', '2014/9/23', 0),
       (9, 'Clancy', 'Wiggum', '1979/5/30', 65000),
       (10, 'Montgomery', 'Burns', '1950/8/7', 100000);

-- Case WHEN statement
select c.*
from simpsons.characters as c;

select c.first_name,
       c.last_name,
       c.date_of_birth,
       c.salary
from simpsons.characters as c
order by c.salary desc
limit 3; -- limit to first three records


select c.first_name,
       c.last_name,
       c.date_of_birth,
       c.salary
from simpsons.characters as c
order by c.salary desc
limit 10;


--- create salary ranges
-- '0-50k', '50k-100k', '100k+'
select c.first_name,
       c.last_name,
       c.date_of_birth,
       c.salary,
       case
           when c.salary < 50000 then '0-50k'
           when c.salary between 50000 and 100000 then '50k-100k'
           else '100k+'
       end as salary_range
from simpsons.characters as c
order by c.salary; -- if exists null, then it would be in group else '100k'

select c.first_name,
       c.last_name,
       c.date_of_birth,
       c.salary,
       case
           when c.salary < 50000 then '0-50k'
           when c.salary between 50000 and 100000 then '50k-100k'
           when c.salary > 100000 then '100k'
           else 'unknown' -- with null values
       end as salary_range
from simpsons.characters as c
order by c.salary;

select c.first_name,
       c.last_name,
       c.date_of_birth,
       c.salary,
       case
           when c.salary < 50000 then '0-50k'
           when c.salary between 50000 and 100000 then '50k-100k'
           when c.salary > 100000 then '100k'
           else 'unknown' -- with null values
       end as salary_range,
       date_part('year', current_date) - date_part('year', c.date_of_birth) as incorrect_age,
       -- or extract(year from current_Date) - extract(year from c.date_of_birth) as age
       -- both are incorrect bcs the calculation based on calender year
      extract(year from age(c.date_of_birth)) as correct_age
from simpsons.characters as c
order by c.salary;

select
    case
           when c.salary < 50000 then '0-50k'
           when c.salary >= 50000 and c.salary < 100000 then '50k-100k' -- inclusive both end
           when c.salary >= 100000 then '100k'
           else 'unknown' -- with null values
       end as salary_range,
      count(distinct c.character_id) as number_of_characters
from simpsons.characters as c
group by salary_range;

insert into simpsons.characters(character_id, first_name, last_name, date_of_birth, salary)
values (11, 'Sideshow', 'Bob', '1978-01-01', 80000);

-- Rank, DENSE_RANK, ROW
with ranked_salaries as (
select c.first_name,
       c.last_name,
       c.date_of_birth,
       c.salary,
       rank() over (order by c.salary desc) as salary_rank, --cumulative
       dense_rank() over (order by c.salary desc) as salary_dense_rank, -- not skip number
       row_number() over (order by c.salary desc) salary_row -- row calculated by order
from simpsons.characters as c)
select *
from ranked_salaries;

select c.first_name,
       c.last_name,
       c.date_of_birth,
       c.salary,
       rank() over (partition by last_name order by c.salary desc) as salary_rank
from simpsons.characters as c;

with family_income as(
select c.last_name,
       sum(c.salary) as total_income
from simpsons.characters as c
group by 1)
select *,
       dense_rank() over (order by total_income desc) as family_rank
from family_income;

select c.last_name,
       sum(c.salary) as total_income,
       rank() over (order by sum(c.salary) desc) as total_income_rank
from simpsons.characters as c
group by 1; -- same as the last query

select *,
       rank() over (order by age(c.date_of_birth)) as age_rank
from simpsons.characters as c;

-- Get the top 3 products based on sales volume and sales revenue
with ranked_product as(
   select bs.article, sum(bs.quantity) as sales_volume,
       rank() over (order by sum(bs.quantity) desc) as volume_rank
from assignment01.bakery_sales as bs
where bs.unit_price is not null
group by bs.article
)
select *
from ranked_product
where volume_rank <= 3;

select bs.article, sum(bs.unit_price * bs.quantity) as sales_revenue,
       rank() over (order by sum(bs.unit_price * bs.quantity) desc) as revenue_rank
from assignment01.bakery_sales as bs
where bs.unit_price is not null
group by bs.article
limit 3;



with ranked_product as(
select bs.article, sum(bs.unit_price * bs.quantity) as sales_revenue,
       rank() over (order by sum(bs.unit_price * bs.quantity) desc) as revenue_rank
from assignment01.bakery_sales as bs
where bs.unit_price is not null
group by bs.article
)
select *
from ranked_product
where revenue_rank <= 3;


with ranked_product as(
select
       extract(year from bs.sale_date) as sale_year,
       extract(month from bs.sale_date) as sale_month,
       bs.article,
       sum(bs.unit_price * bs.quantity) as sales_revenue,
       rank() over (
           partition by extract(year from bs.sale_date), extract(month from bs.sale_date)
           order by sum(bs.unit_price * bs.quantity) desc
           )
from assignment01.bakery_sales as bs
where bs.unit_price is not null
group by 1,2,3
)
select *
from ranked_product;
