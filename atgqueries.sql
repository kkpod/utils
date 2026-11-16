
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
