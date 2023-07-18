-- Jul 17 Class

select * from dimensions.customer_dimension as cd; -- # 5 rows

select * from dimensions.product_dimension as pd; --  # 47 rows

select * from dimensions.customer_dimension as cd
cross join dimensions.product_dimension as pd; -- # 235 rows

--- Cross Join
select cd.first_name, cd.last_name, pd.product_name
from dimensions.customer_dimension as cd
cross join dimensions.product_dimension as pd;

-- same as the previous code
select cd.first_name, cd.last_name, pd.product_name
from dimensions.customer_dimension as cd, dimensions.product_dimension as pd; -- change cross join to ','

select cd.first_name,
       cd.last_name,
       pd.product_name,
       dd.year   -- return duplicate rows since there are multiple rows have dd.year == 2019 but 365 days in 2019
from dimensions.customer_dimension as cd,
     dimensions.product_dimension as pd,
     dimensions.date_dimension as dd;

--- Left Join
select cs.conversion_id,
       cs.conversion_date,
       cs.conversion_type,
       cd.first_name,
       cd.last_name
       from fact_tables.conversions as cs
left join dimensions.customer_dimension as cd
    on cs.fk_customer = cd.sk_customer; -- null value in the end since cd table has records not in cs


--- Union All
select cd.first_name, cd.last_name
from dimensions.customer_dimension as cd
UNION ALL
select cd.first_name, cd.last_name
from dimensions.customer_dimension as cd;


select cd.first_name, cd.last_name
from dimensions.customer_dimension as cd
UNION ALL
select cd.first_name, cd.last_name
from dimensions.customer_dimension as cd
UNION ALL
select cd.first_name, cd.last_name
from dimensions.customer_dimension as cd;

--- Union (unique)
select cd.first_name, cd.last_name
from dimensions.customer_dimension as cd
UNION
select cd.first_name, cd.last_name
from dimensions.customer_dimension as cd;

--- Join in common tables (with statement)
with activations as (
select cs.conversion_id,
       cs.conversion_date,
       cs.conversion_type,
       cd.first_name,
       cd.last_name
from fact_tables.conversions as cs
left join dimensions.customer_dimension as cd
on cs.fk_customer = cd.sk_customer
where cs.conversion_type = 'activation')
select * from activations;


with activations as (
select cs.conversion_id,
       cs.conversion_date,
       cs.conversion_type,
       cd.first_name,
       cd.last_name
from fact_tables.conversions as cs
left join dimensions.customer_dimension as cd on cs.fk_customer = cd.sk_customer
where cs.conversion_type = 'activation'),
reactivations as (
select cs.conversion_id,
       cs.conversion_date,
       cs.conversion_type,
       cd.first_name,
       cd.last_name
from fact_tables.conversions as cs
left join dimensions.customer_dimension as cd on cs.fk_customer = cd.sk_customer
where cs.conversion_type = 'reactivation')
select * from activations
union all
select * from reactivations;

