-- June 12 2023 Class

SELECT *
FROM assignment01.bakery_sales AS bs;

--- Write a query to return sale date, sale time, ticket number, article, quantity and revenue
SELECT bs.sale_date, bs.sale_time, bs.ticket_number, bs.article, bs.quantity, bs.unit_price,
       bs.unit_price * bs.quantity AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = '150063'
ORDER BY bs.ticket_number, bs.article;


-- LIKE (WILDCARD Character with % and _)
-- CAST: change variable type
SELECT *
FROM assignment01.bakery_sales AS bs
WHERE CAST(bs.ticket_number AS TEXT) LIKE '1500__'; -- start with '1500__'; total 6 digits


SELECT *
FROM assignment01.bakery_sales AS bs
WHERE CAST(bs.ticket_number AS TEXT) LIKE '1500%'; -- no limit number of characters after 1500


SELECT bs.ticket_number, CAST(bs.ticket_number AS TEXT) AS ticket_number_string
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = 225054;


SELECT *
FROM assignment01.bakery_sales AS bs
WHERE CAST(bs.ticket_number AS TEXT) LIKE '150__1';


SELECT DISTINCT(bs.article)
FROM assignment01.bakery_sales AS bs
WHERE bs.article like '%BAGUETTE'; -- Unique items look like BAGUETTE sold by bakery

SELECT COUNT(DISTINCT(bs.article))
FROM assignment01.bakery_sales AS bs
WHERE bs.article like '%BAGUETTE'; -- %BAGUETTE: end with BARGUETTE; not include lower case as well


SELECT DISTINCT(bs.article)
FROM assignment01.bakery_sales AS bs
WHERE bs.article like 'BAGUETTE%';
SELECT COUNT(DISTINCT(bs.article))
FROM assignment01.bakery_sales AS bs
WHERE bs.article like 'BAGUETTE%'; -- BARGUETTE%: start with BARGUETTE


SELECT DISTINCT(bs.article)
FROM assignment01.bakery_sales AS bs
WHERE bs.article like '%BAGUETTE%'; -- %BAGUETTE%: return results contain word BARGUETTE, not include lowercase results

-- =(equal) , >, <, <> (not equal to)
SELECT *
FROM assignment01.bakery_sales AS bs
WHERE bs.unit_price = 1;

SELECT *
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = '150063'AND bs.unit_price < 1;

SELECT *
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = '150063'AND bs.unit_price != 12;

SELECT *
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = '150063' AND bs.unit_price >= 1 AND bs.unit_price <= 2;

-- BETWEEN
SELECT *
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = '150063' AND (bs.unit_price BETWEEN 1 AND 2);

-- GROUP BY
--- calculate total revenue for ticket 150063
SELECT bs.ticket_number, sum(bs.quantity * bs.unit_price) AS revenue
FROM assignment01.bakery_sales AS bs
WHERE bs.ticket_number = 150063
GROUP BY bs.ticket_number;

SELECT bs.ticket_number, sum(bs.quantity * bs.unit_price) AS revenue
FROM assignment01.bakery_sales AS bs
GROUP BY bs.ticket_number;

--- Calculate number of tickets by sale_date
SELECT bs.sale_date, COUNT(DISTINCT(bs.ticket_number))
FROM assignment01.bakery_sales AS bs
GROUP BY bs.sale_date
ORDER BY bs.sale_date ASC;

SELECT bs.sale_date, COUNT(DISTINCT(bs.ticket_number)) AS number_count
FROM assignment01.bakery_sales AS bs
GROUP BY bs.sale_date
ORDER BY bs.sale_date DESC;

-- DATE_PART(), EXTRACT()
SELECT bs.sale_datetime, DATE_PART('month', bs.sale_datetime) AS sale_month,
       bs.ticket_number, bs.quantity, bs.unit_price
FROM assignment01.bakery_sales AS bs;

SELECT bs.sale_datetime, DATE_PART('month', bs.sale_datetime) AS sale_month, -- numerical
       DATE_PART('year', bs.sale_datetime) AS sale_year, -- can +1 after
       DATE_PART('day', bs.sale_datetime) AS sale_day,
       EXTRACT(month FROM bs.sale_datetime) AS sale_month_extract,
       bs.ticket_number, bs.quantity, bs.unit_price
FROM assignment01.bakery_sales AS bs;

SELECT CURRENT_DATE,
       DATE_PART('year', CURRENT_DATE) AS year,
       DATE_PART('MONTH', CURRENT_DATE) AS month,
       DATE_PART('DAY', CURRENT_DATE) AS day,
       DATE_PART('DOW', CURRENT_DATE) AS day_of_week; -- default starting by Sundays

SELECT DATE_PART('year',bs.sale_date) AS sale_year,
       DATE_PART('month',bs.sale_date) AS sale_month,
       COUNT(DISTINCT (bs.ticket_number))
FROM assignment01.bakery_sales AS bs
GROUP BY 1, 2 -- 1: group by the first column; 2: second column
ORDER BY 1, 2;


WITH monthly_ticket_count AS(                                   -- transfer to a summary table; WITH: reuse the query
    SELECT DATE_PART('year',bs.sale_date) AS sale_year,
       DATE_PART('month',bs.sale_date) AS sale_month,
       COUNT(DISTINCT (bs.ticket_number)) AS ticket_count
    FROM assignment01.bakery_sales AS bs
    GROUP BY 1, 2
    ORDER BY 1, 2
)
SELECT mtc.sale_year, AVG(mtc.ticket_count)
FROM monthly_ticket_count AS mtc
GROUP BY mtc.sale_year;
