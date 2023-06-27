-- Write a SQL query to calculate the worst three performing products with a non-zero unit prize in the dataset (use sales volume as your metric)
with  sales_volume_table as (
select bs.article, sum(bs.quantity) as sales_volume,
       dense_rank() over (order by sum(bs.quantity) )as sales_volume_rank
from assignment01.bakery_sales as bs
where bs.unit_price != 0
group by bs.article
order by sum(bs.quantity)
)
select * from sales_volume_table
where sales_volume_rank <= 3;

-- Write a SQL query to calculate net revenue and sales volumes (quantity) broken down by year and by quarter
-- Hint: you can use EXTRACT(quarter FROM ...) or DATE_PART('quarter', ...)

select extract(year from bs.sale_date) as year,
       extract(quarter from bs.sale_date),
       sum(bs.quantity * bs.unit_price) as net_revenue,
       sum(quantity) as sales_volume
from assignment01.bakery_sales as bs
group by extract(year from bs.sale_date), extract(quarter from bs.sale_date)
order by extract(year from bs.sale_date), extract(quarter from bs.sale_date);

-- Write a SQL query to identify the month(s) of the year with the lowest amount of orders for all the types of Baguette in the dataset
with number_rank as (
select extract(year from bs.sale_date) as year,
       extract(month from bs.sale_date) as month,
       sum(bs.quantity) as sales_volume,
       count(bs.ticket_number) as number_order,
       dense_rank() over (partition by  extract(year from bs.sale_date)
           order by count(bs.ticket_number)) as number_order_rank
from assignment01.bakery_sales as bs
where upper(bs.article) like '%BAGUETTE%'
group by extract(year from bs.sale_date),extract(month from bs.sale_date))
select * from number_rank where number_order_rank = 1;

-- Write a query to identify the top 3 performing products for each year and month using revenue as your metric
-- (see image below for the expected output)
with revenue_rank as (
select extract(year from bs.sale_date) as year,
       extract(month from bs.sale_date) as month,
       bs.article,
       sum(bs.quantity * bs.unit_price) as sales_revenue,
       rank() over (partition by extract(year from bs.sale_date), extract(month from bs.sale_date)
           order by sum(bs.quantity * bs.unit_price) desc) as revenue_rank
from assignment01.bakery_sales as bs
where bs.unit_price is not null and bs.quantity is not null
group by extract(year from bs.sale_date),extract(month from bs.sale_date),bs.article
)
select *
from revenue_rank
where revenue_rank <= 3;