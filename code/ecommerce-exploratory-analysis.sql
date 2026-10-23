									-- SALES TRENDS --
-- summarizing order counts, sales dollars, and profit by year --
SELECT
	order_year,
    COUNT(*) AS num_orders,
    SUM(sales_usd) AS total_sales_usd,
    ROUND(SUM(sales_usd) / COUNT(*), 2) AS sales_per_order_usd,
    SUM(profit_usd) AS total_profit_usd,
    ROUND(AVG(profit_usd), 2) AS avg_profit_per_order_usd
FROM orders
GROUP BY order_year
ORDER BY order_year ASC
;

-- number of orders and sales dollars by month --
SELECT
	order_year,
	order_month,
    COUNT(*) AS num_orders,
    ROUND(SUM(sales_usd), 0) AS total_sales_usd
FROM orders
GROUP BY
	order_year,
    order_month
ORDER BY
	order_year ASC,
    month_id ASC
;

-- total sales dollars by customer segment --
SELECT
	customer_segment,
	ROUND(SUM(sales_usd), 0) AS total_sales_usd,
    ROUND(SUM(sales_usd) / (
							SELECT SUM(sales_usd)
							FROM orders
							), 2) AS pct_of_total
FROM orders
GROUP BY customer_segment
ORDER BY SUM(sales_usd) DESC
;

-- summarizing customer discounts  --
SELECT
	COUNT(*) AS num_orders,
    ROUND(COUNT(*) / (
					  SELECT COUNT(*)
					  FROM orders
					  ), 2) AS pct_of_tot_orders,
	ROUND(AVG(discount_usd), 2) AS avg_discount_usd,
    ROUND(SUM(discount_usd), 2) AS tot_discount_usd,
    ROUND(AVG((
			   SELECT AVG(sales_usd)
			   FROM orders
			   )), 2) AS avg_sale_price_usd
FROM orders
WHERE discount_usd > 0
;

-- digging deeper into discounts applied in 2024 --
SELECT
    COUNT(*) AS num_discounts,
    ROUND(AVG(discount_usd), 2) AS avg_discount_usd,
    ROUND(SUM(discount_usd), 2) AS total_discount_usd,
    ROUND(SUM(discount_usd) / (
							   SELECT
							   SUM(sales_usd)
							   FROM orders
							   WHERE order_year = 2024
							   ), 2) AS pct_of_tot_sales_usd
FROM orders
WHERE
	order_year = 2024 AND
    discount_usd > 0
;

-- comparing sales dollars , profit, and discounts by year --
SELECT
	order_year,
    ROUND(SUM(sales_usd), 0) AS total_sales_usd,
    ROUND(SUM(profit_usd), 0) AS total_profit_usd,
    ROUND(SUM(discount_usd), 0) AS total_discounts_usd,
    ROUND(SUM(profit_usd) / SUM(sales_usd), 2) AS profit_pct_usd,
    ROUND(SUM(discount_usd) / SUM(sales_usd), 2) AS discount_pct_usd
FROM orders
GROUP BY order_year
ORDER BY order_year ASC
;
									-- PRODUCT & CATEGORY PERFORMANCE --
-- number of unique products and product categories --
SELECT
	COUNT(DISTINCT product_id) AS num_products,
    COUNT(DISTINCT product_category) AS num_product_cat
FROM products
;

-- best selling product category --
SELECT
	product_category,
    COUNT(o.sales_usd) AS num_orders,
    ROUND(SUM(o.sales_usd), 0) AS total_sales_usd,
	ROUND(AVG(o.sales_usd), 0) AS avg_sales_usd
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
GROUP BY p.product_category
ORDER BY COUNT(o.sales_usd) DESC
LIMIT 1
;

-- pct of total sales and avg profit by product category --
SELECT
	p.product_category,
	ROUND(SUM(o.sales_usd), 0) AS total_sales_usd,
    ROUND(SUM(o.sales_usd) / (
							  SELECT SUM(sales_usd)
							  FROM orders
							  ), 2) AS pct_of_total_sales_usd,
    ROUND(AVG(o.profit_usd), 0) AS avg_profit_usd
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
GROUP BY product_category
;

-- best selling and most profitable products --
SELECT
	p.product_id,
    p.product_category,
    p.product_name,
    SUM(o.sales_usd) AS total_sales_usd,
    ROUND(AVG(o.profit_usd), 2) AS avg_profit_usd
FROM products p
JOIN orders o
	ON p.product_id = o.product_id
GROUP BY product_id
ORDER BY SUM(o.sales_usd) DESC
LIMIT 10
;

									-- REGIONAL SALES PERFORMANCE --
-- sales and profit by region --
SELECT
	customer_region,
    ROUND(SUM(sales_usd), 2) AS total_sales_usd,
    ROUND(SUM(sales_usd) / (
							SELECT SUM(sales_usd)
							FROM orders
							), 2) AS pct_of_total,
	ROUND(AVG(profit_usd), 2) AS avg_profit
FROM orders
GROUP BY customer_region
ORDER BY SUM(sales_usd) DESC
;

-- top 10 states by total sales dollars --
SELECT
	customer_state,
    ROUND(SUM(sales_usd), 0) AS total_sales_usd,
    ROUND(SUM(sales_usd) / (
							SELECT SUM(sales_usd)
							FROM orders
							), 2) AS pct_of_total
FROM orders
GROUP BY customer_state
ORDER BY SUM(sales_usd) DESC
LIMIT 10
;

-- leading categories in top selling state (California) --
SELECT
	customer_state,
    p.product_category,
    ROUND(SUM(o.sales_usd), 0) AS total_sales_usd,
    ROUND(SUM(o.sales_usd) / (
							  SELECT SUM(sales_usd)
							  FROM orders
							  WHERE customer_state = 'California'
							  ), 2) AS pct_of_total_usd
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
WHERE o.customer_state = 'California'
GROUP BY p.product_category
;

-- eight least profitable states in terms of avg profit per order --
SELECT
	customer_state,
    ROUND(AVG(profit_usd), 2) AS avg_profit
FROM orders
GROUP BY customer_state
ORDER BY avg_profit ASC
LIMIT 8
;

-- eight most profitable states in terms of avg profit per order --
SELECT
	customer_state,
    ROUND(AVG(profit_usd), 2) AS avg_profit
FROM orders
GROUP BY customer_state
ORDER BY avg_profit DESC
LIMIT 8
;

									-- SHIPPING TIMELINESS --
-- summarize delivery outcomes by delivery result --
SELECT
	delivery_result,
    COUNT(*) AS num_orders,
    ROUND(COUNT(*) / (
					  SELECT COUNT(*)
					  FROM orders
					  ), 2) AS pct_of_total_orders
FROM orders
GROUP BY delivery_result
ORDER BY delivery_result ASC
;

-- average scheduled vs average actual shipping time --
SELECT
	ROUND(AVG(est_ship_days), 1) AS sch_days,
    ROUND(AVG(actual_ship_days), 1) AS act_days
FROM orders
;

-- shipping variance by region --
SELECT
	customer_region,
    ROUND(AVG(est_ship_days), 2) AS sch_days,
    ROUND(AVG(actual_ship_days), 2) AS act_days,
    ROUND(AVG(est_ship_days) - AVG(actual_ship_days), 2) AS avg_ship_days_var
FROM orders
GROUP BY customer_region
ORDER BY avg_ship_days_var DESC
;

-- six least favorable shipping variances by state --
SELECT
	customer_state,
    ROUND(AVG(est_ship_days), 2) AS sch_days,
    ROUND(AVG(actual_ship_days), 2) AS act_days,
    AVG(est_ship_days) - AVG(actual_ship_days) AS avg_ship_days_var
FROM orders
GROUP BY customer_state
ORDER BY avg_ship_days_var ASC
LIMIT 6
;

-- six most favorable shipping variances by state --
SELECT
	customer_state,
    ROUND(AVG(est_ship_days), 2) AS sch_days,
    ROUND(AVG(actual_ship_days), 2) AS act_days,
    AVG(est_ship_days) - AVG(actual_ship_days) AS avg_ship_days_var
FROM orders
GROUP BY customer_state
ORDER BY avg_ship_days_var DESC
LIMIT 6