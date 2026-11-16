
SELECT
    c.category_id,
    c.display_name AS category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT i.commerce_item_id) AS total_items,
    SUM(i.quantity) AS total_quantity
FROM dcspp_order o
JOIN dcspp_order_item oi
    ON oi.order_id = o.order_id
JOIN dcspp_item i
    ON i.commerce_item_id = oi.commerce_items
JOIN dcs_cat_chldprd cp
    ON cp.child_prd_id = i.product_id
JOIN dcs_category c
    ON c.category_id = cp.category_id
WHERE o.submitted_date IS NOT NULL
AND o.submitted_date >=
    TO_DATE('2026-10-01', 'YYYY-MM-DD')
AND o.submitted_date <
    TO_DATE('2026-11-01', 'YYYY-MM-DD')  
GROUP BY
    c.category_id,
    c.display_name
ORDER BY total_orders DESC;

------------------------- Primary:
SELECT
    c.category_id,
    c.display_name AS category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(i.quantity) AS units_sold,
    ROUND(SUM(ip.raw_total_price), 2) AS gross_revenue,
    ROUND(
        SUM(ip.raw_total_price) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS avg_revenue_per_order,
    ROUND(
        SUM(i.quantity) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS avg_units_per_order
FROM dcspp_order o
JOIN dcspp_order_item oi
    ON oi.order_id = o.order_id
JOIN dcspp_item i
    ON i.commerce_item_id = oi.commerce_items
JOIN dcspp_item_price ip
    ON ip.amount_info_id = i.price_info
JOIN dcs_cat_chldprd cp
    ON cp.child_prd_id = i.product_id
JOIN dcs_category c
    ON c.category_id = cp.category_id
WHERE o.submitted_date >= DATE '2025-11-16'
  AND o.submitted_date <  DATE '2026-11-16'
GROUP BY
    c.category_id,
    c.display_name
ORDER BY gross_revenue DESC;

------------------------ Metrics
WITH category_metrics AS (
    SELECT
        c.category_id,
        c.display_name AS category_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(i.quantity) AS units_sold,
        SUM(ip.raw_total_price) AS gross_revenue
    FROM dcspp_order o
    JOIN dcspp_order_item oi
        ON oi.order_id = o.order_id
    JOIN dcspp_item i
        ON i.commerce_item_id = oi.commerce_items
    JOIN dcspp_item_price ip
        ON ip.amount_info_id = i.price_info
    JOIN dcs_cat_chldprd cp
        ON cp.child_prd_id = i.product_id
    JOIN dcs_category c
        ON c.category_id = cp.category_id
    WHERE o.submitted_date >= DATE '2025-11-16'
      AND o.submitted_date < DATE '2026-11-16'
    GROUP BY
        c.category_id,
        c.display_name
)
SELECT
    category_id,
    category_name,
    total_orders,
    units_sold,
    ROUND(gross_revenue, 2) AS gross_revenue,
    ROUND(
        gross_revenue / NULLIF(total_orders, 0), 2
    ) AS avg_order_value,
    ROUND(
        units_sold / NULLIF(total_orders, 0), 2
    ) AS avg_units_per_order,
    ROUND(
        gross_revenue * 100 /
        NULLIF(SUM(gross_revenue) OVER (), 0), 2
    ) AS revenue_percentage
FROM category_metrics
ORDER BY gross_revenue DESC;

--------------------- Monthly Sales

SELECT
    TO_CHAR(o.submitted_date, 'YYYY-MM') AS sales_month,
    c.display_name AS category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(i.quantity) AS units_sold,
    ROUND(SUM(ip.raw_total_price), 2) AS revenue
FROM dcspp_order o
JOIN dcspp_order_item oi
    ON oi.order_id = o.order_id
JOIN dcspp_item i
    ON i.commerce_item_id = oi.commerce_items
JOIN dcspp_item_price ip
    ON ip.amount_info_id = i.price_info
JOIN dcs_cat_chldprd cp
    ON cp.child_prd_id = i.product_id
JOIN dcs_category c
    ON c.category_id = cp.category_id
WHERE o.submitted_date >= DATE '2025-11-16'
  AND o.submitted_date < DATE '2026-11-16'
GROUP BY
    TO_CHAR(o.submitted_date, 'YYYY-MM'),
    c.display_name
ORDER BY
    sales_month,
    revenue DESC;

-------------- 

High level Business Summary:

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(i.quantity) AS total_units_sold,
    ROUND(SUM(ip.raw_total_price), 2) AS gross_revenue,
    ROUND(
        SUM(ip.raw_total_price) /
        NULLIF(COUNT(DISTINCT o.order_id), 0), 2
    ) AS average_order_value
FROM dcspp_order o
JOIN dcspp_order_item oi
    ON oi.order_id = o.order_id
JOIN dcspp_item i
    ON i.commerce_item_id = oi.commerce_items
JOIN dcspp_item_price ip
    ON ip.amount_info_id = i.price_info
WHERE o.submitted_date >= DATE '2025-11-16'
  AND o.submitted_date < DATE '2026-11-16';





