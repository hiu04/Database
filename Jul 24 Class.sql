-- Jul 24 Class

-- Static

-- Dynamic info (RFM: Recency, Frequency, Monetary)
select cd.customer_id,
       cd.first_name,
       cd.last_name,
       cs.conversion_id,
       row_number() over (partition by cd.customer_id order by cs.conversion_date) as conversion_number,
       cs.conversion_type,
       cs.conversion_date,
       dd.year_week as conversion_week,
       lead(cs.conversion_date) over (partition by cd.customer_id order by cs.conversion_date) as next_conversion_date,
       lead(dd.year_week) over (partition by cd.customer_id order by cs.conversion_date) as next_conversion_week,
       cs.conversion_channel
from fact_tables.conversions as cs
inner join dimensions.customer_dimension as cd
on cs.fk_customer = cd.sk_customer
inner join dimensions.date_dimension as dd
on cs.fk_conversion_date = dd.sk_date
where cd.customer_id = 333;

-- if two inner join change to left join, the base table is the first one conversions table

select cd.customer_id,
       cd.first_name,
       cd.last_name,
       o.order_number,
       o.order_date,
       dd.year_week as order_week,
       lead(dd.year_week) over(partition by cd.customer_id order by dd.year_week) as next_order_week,
       o.price_paid
from fact_tables.orders as o
inner join dimensions.date_dimension as dd
on o.fk_order_date = dd.sk_date
inner join dimensions.customer_dimension as cd
on o.fk_customer = cd.sk_customer
order by cd.customer_id, o.order_date;


select cd.customer_id,
       cd.first_name,
       cd.last_name,
       o.order_number,
       o.order_date,
       dd.year_week as order_week,
       lead(dd.year_week) over (partition by cd.customer_id order by dd.year_week) as next_conversion_week,
       pd.product_name,
       o.price_paid
from fact_tables.orders as o
inner join dimensions.date_dimension as dd
on o.fk_order_date = dd.sk_date
inner join dimensions.customer_dimension as cd
on o.fk_customer = cd.sk_customer
inner join dimensions.product_dimension as pd
on o.fk_product = pd.sk_product
where cd.customer_id = 111
order by cd.customer_id, o.order_date;

