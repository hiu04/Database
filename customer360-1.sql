WITH conversions AS (
    SELECT
        cd.customer_id,
        cd.first_name,
        cd.last_name,
        cs.conversion_id,
        ROW_NUMBER() OVER (PARTITION BY cd.customer_id ORDER BY cs.conversion_date) AS conversion_number,
        cs.conversion_type,
        cs.conversion_date,
        dd.year_week AS conversion_week,
        cs.conversion_channel,
        LEAD(dd.year_week) OVER (partition by cd.customer_id order by dd.year_week) as next_conversion_week
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
        o.unit_price,
        o.discount,
        o.price_paid
    FROM
        fact_tables.orders AS o
    INNER JOIN
        dimensions.date_dimension AS dd ON o.fk_order_date = dd.sk_date
    INNER JOIN
        dimensions.customer_dimension AS cd ON o.fk_customer = cd.sk_customer
    INNER JOIN
        dimensions.product_dimension AS pd ON o.fk_product = pd.sk_product
),
first_orders AS (
    SELECT
        o.customer_id,
        o.order_date AS first_order_date,
        o.order_week AS first_order_week,
        o.order_id AS first_order_id,
        o.product_name AS first_order_product,
        o.unit_price AS first_order_unit_price,
        o.discount AS first_order_discount,
        o.price_paid AS first_order_total_paid
    FROM
        orders o
    INNER JOIN (
        SELECT customer_id, MIN(order_date) as min_order_date
        FROM orders
        GROUP BY customer_id
    ) fo ON o.customer_id = fo.customer_id AND o.order_date = fo.min_order_date
),
weekly_orders AS (
    SELECT
        customer_id,
        order_week,
        SUM(unit_price) AS grand_total,
        SUM(discount) AS total_discount,
        SUM(price_paid) AS total_paid,
        SUM(SUM(price_paid)) OVER (PARTITION BY customer_id ORDER BY order_week) AS cumulative_revenue,
        SUM(SUM(price_paid)) OVER (PARTITION BY customer_id ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS cumulative_revenue_lifetime,
        COUNT(order_id) AS week_orders,
        SUM(COUNT(order_id)) OVER (PARTITION BY customer_id ORDER BY order_week) AS loyalty_lifetime
    FROM
        orders
    GROUP BY
        customer_id,
        order_week
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.conversion_id,
    c.conversion_number,
    c.conversion_type,
    c.conversion_date,
    c.conversion_week,
    c.conversion_channel,
    c.next_conversion_week,
    f.first_order_id AS first_order_number,
    f.first_order_date,
    f.first_order_week,
    f.first_order_product,
    f.first_order_total_paid,
    f.first_order_discount,
    ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY wo.order_week) AS week_counter,
    wo.order_week,
    wo.grand_total,
    wo.total_discount,
    wo.total_paid,
    wo.cumulative_revenue,
    wo.cumulative_revenue_lifetime,
    wo.week_orders AS loyalty,
    wo.loyalty_lifetime
FROM
    conversions AS c
LEFT JOIN
    first_orders AS f ON c.customer_id = f.customer_id
LEFT JOIN
    weekly_orders AS wo ON c.customer_id = wo.customer_id AND c.conversion_week <= wo.order_week
ORDER BY
    c.customer_id,
    wo.order_week;