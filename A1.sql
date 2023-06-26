-- 1.Identify the items with the highest and lowest (non-zero) unit price?
--- Find the highest and lowest (non-zero) price
SELECT MAX(bs.unit_price),  MIN(bs.unit_price)
FROM assignment01.bakery_sales AS bs
WHERE bs.unit_price > 0; -- max price = 60; min price = 0.07

SELECT bs.article
FROM  assignment01.bakery_sales AS bs
WHERE bs.unit_price = 60; -- highest price:DIVERS PATISSERIE

SELECT bs.article
FROM  assignment01.bakery_sales AS bs
WHERE bs.unit_price = 0.07; -- lowest price:DIVERS SANDWICHS

-- 2.Write a SQL query to report the second most sold item from the bakery table. If there is no second most sold item,
-- the query should report NULL.
select bs.article
from assignment01.bakery_sales AS bs
group by bs.article
order by sum(bs.quantity) desc
limit 1 offset 1; -- CROISSANT

-- 3.Write a SQL query to report the top 3 most sold items for every month in 2022 including their monthly sales.
with monthly_rank as (
select extract(month from bs.sale_date) as month, bs.article, sum(bs.quantity) as monthly_sales,
       row_number() over (partition by extract(month from bs.sale_date) order by sum(bs.quantity) desc) as rank
from assignment01.bakery_sales as bs
where extract(year from bs.sale_date) = 2022
group by extract(month from bs.sale_date), bs.article
order by extract(month from bs.sale_date), sum(bs.quantity) desc)
select month, article
from monthly_rank
where rank <= 3;

-- 4.Write a SQL query to report all the tickets with 5 or more articles in August 2022 including the number of articles
-- in each ticket.
with ticket_August as(
    select bs.article, bs.ticket_number, sum(bs.quantity) as number_of_article
    from assignment01.bakery_sales AS bs
    where extract(month from bs.sale_date) = 8 and extract(year from bs.sale_date) = 2022
    group by bs.article, bs.ticket_number
    )
select ticket_August.ticket_number, ticket_August.number_of_article
from ticket_August
where ticket_August.number_of_article >= 5;


-- 5.Write a SQL query to calculate the average sales per day in August 2022?
with t as(
select extract(day from sale_date) as day, unit_price, quantity, (unit_price * quantity) as sales_per_ticket
      from assignment01.bakery_sales as bs
      where extract(month from sale_date) = 8 and extract(year from sale_date) = 2022
      )
select t.day, round(avg(sales_per_ticket),4) as daily_avg_sales
from t
group by t.day;


-- 6.Write a SQL query to identify the day of the week with more sales?
select extract(dow from sale_date) as day_of_week, sum(quantity)
from assignment01.bakery_sales as bs
group by day_of_week
order by sum(quantity) desc
limit 1; -- Sundays

-- 7.What time of the day is the traditional Baguette more popular?
with t as (select sale_date, sum(quantity)
      from assignment01.bakery_sales as bs
      where article = 'TRADITIONAL BAGUETTE'
      group by sale_date
      order by sum(quantity) desc
      )
select t.sale_date
from t
limit 1; --2022-08-14(drop the query)

with t as (select extract(hour from bs.sale_datetime) as hour, sum(bs.quantity)
      from assignment01.bakery_sales as bs
      where bs.article = 'TRADITIONAL BAGUETTE'
      group by extract(hour from bs.sale_datetime)
      order by sum(bs.quantity) desc
      )
select t.hour
from t
limit 1; -- 11AM

--8.Write a SQL query to find the articles with the lowest sales in each month?

with monthly_sales as(
    select extract(year from sale_date) as year,
    extract (month from sale_date) as month,
    article, sum(unit_price * quantity) as sales,
    rank() over (partition by extract(year from sale_date),extract (month from sale_date)
        order by sum(unit_price * quantity)) as rank
    from assignment01.bakery_sales as bs
    group by extract(year from bs.sale_date),extract(month from bs.sale_date), bs.article
    )
select ms.year, ms.month, ms.article
from monthly_sales as ms
where ms.rank =1;


--9.Write a query to calculate the percentage of sales for each item between 2022-01-01 and 2022-01-31
with total_sales as (
    select sum(bs.quantity * bs.unit_price) as total_sales
    from assignment01.bakery_sales as bs
    where extract(month from sale_date) = 1 and extract(year from sale_date) = 2022
)
select bs.article, (sum(bs.quantity * bs.unit_price) / ts.total_sales) * 100 as percentage
from assignment01.bakery_sales as bs, total_sales as ts
where extract(month from bs.sale_date) = 1 and extract(year from bs.sale_date) = 2022
group by bs.article, ts.total_sales;



-- 10.The order rate is computed by dividing the volume of a specific article divided by the total amount of items
-- ordered in a specific date. Calculate the order rate for the Banette for every month during 2022.
with daily_amount as  (
    select extract(month from bs.sale_date) as month,
           extract(day from bs.sale_date) as day,
           sum(bs.quantity) as daily_total
    from assignment01.bakery_sales as bs
    where extract(year from bs.sale_date) = 2022
    group by extract(month from bs.sale_date), extract(day from bs.sale_date)
)
select extract(month from bs.sale_date) as month,
       extract(day from bs.sale_date) as day,
       sum(bs.quantity) as daily_banette, da.daily_total as daily_total,
       (cast(sum(bs.quantity) as float) / da.daily_total)  as order_rate
from assignment01.bakery_sales as bs
join daily_amount as da on extract(month from bs.sale_date) = da.month and extract(day from bs.sale_date) = da.day
where extract(year from bs.sale_date) = 2022 and bs.article = 'BANETTE'
group by extract(month from bs.sale_date), extract(day from bs.sale_date), da.daily_total
order by extract(month from bs.sale_date), extract(day from bs.sale_date);
