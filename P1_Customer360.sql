-- P1 - Customer360
-- Group 5: Xiaoyu Ma, Wanqiu Jiang, Xiaoyu Deng

WITH conversions AS (
    SELECT
        cd.customer_id,
        cs.conversion_id,
        cs.conversion_date,
        dd.year_week AS conversion_week,
        ROW_NUMBER() OVER (PARTITION BY cd.customer_id ORDER BY cs.conversion_date) AS conversion_number,
        cs.conversion_type,
        cs.conversion_channel,
        LEAD(cs.conversion_date) OVER (PARTITION BY cd.customer_id ORDER BY cs.conversion_date) AS next_conversion_date
    FROM
        fact_tables.conversions AS cs
    INNER JOIN
        dimensions.customer_dimension AS cd ON cs.fk_customer = cd.sk_customer
    INNER JOIN
        dimensions.date_dimension AS dd ON cs.conversion_date = dd.date
),
orders AS (
    SELECT
        cd.customer_id,
        o.order_id,
        o.order_date,
        dd.year_week AS order_week,
        pd.product_name,
        o.price_paid,
        o.discount
    FROM
        fact_tables.orders AS o
    INNER JOIN
        dimensions.date_dimension AS dd ON o.order_date = dd.date
    INNER JOIN
        dimensions.customer_dimension AS cd ON o.fk_customer = cd.sk_customer
    INNER JOIN
        dimensions.product_dimension AS pd ON o.fk_product = pd.sk_product
),
first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        MIN(order_week) AS first_order_week,
        MIN(order_id) AS first_order_id,
        MIN(product_name) AS first_order_product,
        MIN(price_paid) AS first_order_total_paid,
        MIN(discount) AS first_order_discount
    FROM
        orders
    GROUP BY
        customer_id
),
weekly_orders AS (
    SELECT
        customer_id,
        order_week,
        SUM(price_paid) AS week_revenue,
        SUM(discount) AS week_discounts,
        SUM(SUM(price_paid)) OVER (PARTITION BY customer_id ORDER BY order_week) AS cumulative_revenue,
        COUNT(order_id) AS loyalty
    FROM
        orders
    GROUP BY
        customer_id,
        order_week
)
SELECT
    c.*,
    f.first_order_date,
    f.first_order_week,
    f.first_order_id,
    f.first_order_product,
    f.first_order_total_paid,
    f.first_order_discount,
    w.order_week,
    w.week_revenue,
    w.week_discounts,
    w.cumulative_revenue,
    w.loyalty
FROM
    conversions AS c
INNER JOIN
    first_orders AS f ON c.customer_id = f.customer_id
INNER JOIN
    weekly_orders AS w ON c.customer_id = w.customer_id AND c.conversion_week <= w.order_week
ORDER BY
    c.customer_id,
    w.order_week;