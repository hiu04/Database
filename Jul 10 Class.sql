-- July 10 Class
-- Concepts of conversion (viewers to buyers), activation (new users), reactivation (pause subscription and bring the
-- users back) and marketing channel (flyers, gift cards, emails, billboards, social media, referrals: invite friends
-- and get promotion, affiliate, influencers)

-- ML models: budget and discount (risks from new users bcs of limited information)
-- Smart Bidding models
-- CAC Cost of Acquisition
-- CLV Customer Lifetime Value
-- CCV customer Conversion Value

--- Primary key, foreign keys, surrogate keys

--- Write a query to find number of conversions (count), broken down by customer (fk_customer)
select fk_customer, count(conversion_id) as num
from fact_tables.conversions
group by fk_customer
order by 2, 1;


--- Write a query to find all customers with more than 1 conversion using HAVING
--- WHERE apply to the original table; HAVING filter the group data, apply to aggregation
select fk_customer, count(conversion_id) as num
from fact_tables.conversions
group by fk_customer
having count(conversion_id) > 1  -- after group by
order by 2, 1;

-- order number with more than 1 item
select fk_customer, count(order_number) as num
from fact_tables.conversions
group by fk_customer
having count() > 1  -- after group by
order by 2, 1;



--- identify the next(immediate) conversion data for each conversion
-- LEAD:The LEAD function is used to access data from SUBSEQUENT rows along with data from the current row.
-- partition by 把 customer 分类，再按照lead 走//
-- if no partition by,
-- 2 items after the current one rows data setting offset = 2,
-- can be negative, e.g., -1 = LAG with offest 1
select cs.conversion_id,
       cs.conversion_date,
       cs.fk_customer,
       LEAD(cs.conversion_date, 2) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion_date
from fact_tables.conversions as cs
order by 3, 2;

-- LAG : is used to access data from PREVIOUS rows along with data from the current row
select cs.conversion_id,
       cs.conversion_date,
       cs.fk_customer,
       lag(cs.conversion_date) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion_date
from fact_tables.conversions as cs
order by 3, 2;

-- write a query to get the conversion_number for each customer
-- row_number
select cs.conversion_id,
       cs.conversion_date,
       cs.fk_customer,
       ROW_NUMBER() OVER(partition by cs.fk_customer ORDER BY cs.conversion_date) AS conversion_number,
       LEAD(cs.conversion_date,2) OVER(PARTITION BY cs.fk_customer ORDER BY cs.conversion_date) AS next_conversion_date
from fact_tables.conversions as cs
order by 2, 3;

---  inner join & outer join
-- inner join, intersection
select *
from fact_tables.conversions as cs
INNER JOIN dimensions.customer_dimension as cd
ON cs.fk_customer = cd.sk_customer;

select cs.conversion_id,
       cd.first_name,
       cd.last_name,
       cs.conversion_type,
       cs.conversion_date
from fact_tables.conversions as cs
INNER JOIN dimensions.customer_dimension AS cd
ON cs.fk_customer = cd.sk_customer
order by 1, 2,3;

-- LEFT JOIN
-- keep all the data from the left table
select cs.conversion_id,
       cd.first_name,
       cd.last_name,
       cs.conversion_type,
       cs.conversion_date
from fact_tables.conversions as cs
LEFT JOIN dimensions.customer_dimension AS cd
ON cs.fk_customer = cd.sk_customer
order by 1, 2,3;

-- RIGHT JOIN
-- keep all the date from the right table, if there is no data on the left table, return null
select cs.conversion_id,
       cd.first_name,
       cd.last_name,
       cs.conversion_type,
       cs.conversion_date
from fact_tables.conversions as cs
RIGHT JOIN dimensions.customer_dimension AS cd
ON cs.fk_customer = cd.sk_customer
order by 1, 2,3;

-- FULL OUTER JOIN, include all, from both tables
select cs.conversion_id,
       cd.first_name,
       cd.last_name,
       cs.conversion_type,
       cs.conversion_date
from fact_tables.conversions as cs
FULL OUTER JOIN dimensions.customer_dimension AS cd
ON cs.fk_customer = cd.sk_customer
order by 1, 2,3;