-- kpis
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 1) AS profit_margin_pct
FROM orders;

-- sales_by_category
SELECT
    category,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 1) AS margin_pct
FROM orders
GROUP BY category
ORDER BY sales DESC;

-- profit_by_subcategory
SELECT
    sub_category,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY sub_category
ORDER BY profit DESC;

-- loss_making_subcategories
SELECT
    sub_category,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY profit;

-- sales_by_region
SELECT
    region,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY region
ORDER BY sales DESC;

-- yearly_sales
SELECT
    strftime('%Y', order_date) AS year,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY year
ORDER BY year;

-- top_customers
SELECT
    customer_name,
    ROUND(SUM(sales), 2) AS sales,
    COUNT(DISTINCT order_id) AS orders
FROM orders
GROUP BY customer_name
ORDER BY sales DESC
LIMIT 10;

-- discount_impact
SELECT
    CASE
        WHEN discount = 0 THEN '1. No discount'
        WHEN discount <= 0.2 THEN '2. Up to 20%'
        WHEN discount <= 0.4 THEN '3. 21-40%'
        ELSE '4. Over 40%'
    END AS discount_band,
    COUNT(*) AS order_lines,
    ROUND(AVG(profit), 2) AS avg_profit
FROM orders
GROUP BY discount_band
ORDER BY discount_band;

-- top_product_per_category
WITH ranked AS (
    SELECT
        category,
        product_name,
        ROUND(SUM(sales), 2) AS sales,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) AS rnk
    FROM orders
    GROUP BY category, product_name
)
SELECT category, product_name, sales
FROM ranked
WHERE rnk = 1;

-- date_range
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order, COUNT(*) AS rows_in_2018
FROM orders
WHERE order_date >= '2018-01-01';

-- discount_by_subcategory
SELECT sub_category,
       ROUND(AVG(discount) * 100, 1) AS avg_discount_pct,
       ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY sub_category
ORDER BY avg_discount_pct DESC;