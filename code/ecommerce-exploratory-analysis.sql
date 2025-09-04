									-- SALES --
-- orders, sales, and profit stats by year --
SELECT
	order_year,
    COUNT(*) AS num_orders,
    SUM(sales_usd) AS sales_dollars,
    SUM(sales_usd) / COUNT(*) AS avg_order_sales,
    SUM(profit_usd) AS total_profit,
    AVG(profit_usd) AS avg_order_profit
FROM orders
GROUP BY order_year
ORDER BY order_year ASC
;

-- orders and sales by month --
SELECT
	order_year,
	order_month,
    COUNT(*) AS num_orders,
    SUM(sales_usd) AS total_sales
FROM orders
GROUP BY
	order_year,
    order_month
ORDER BY
	order_year ASC,
    month_id ASC
;

-- sales by customer_segment --
SELECT
	customer_segment,
	SUM(sales_usd) AS total_sales,
    SUM(sales_usd) / (
							SELECT SUM(sales_usd)
                            FROM orders
                            ) AS pct_of_total
FROM orders
GROUP BY customer_segment
ORDER BY total_sales DESC
;

-- frequency, total, and avg value of discounts --
SELECT
	COUNT(*) AS num_orders,
    COUNT(*) / (
				SELECT COUNT(*)
                FROM orders
                ) AS pct_of_tot,
	AVG(discount_usd) AS avg_discount,
    SUM(discount_usd) AS tot_discount_value,
    AVG((
		SELECT AVG(sales_usd)
        FROM orders
        )) as avg_sale_price
FROM orders
WHERE discount_usd > 0
;

-- count, sum, avg, and pct of tot sales discounts in 2024 --
SELECT
    COUNT(*) AS num_discounts,
    AVG(discount_usd) AS avg_discount,
    SUM(discount_usd) AS total_discount_value,
    SUM(discount_usd) / (
						 SELECT
                         SUM(sales_usd)
                         FROM orders
                         WHERE order_year = 2024
                         ) AS pct_of_tot_sales
FROM orders
WHERE order_year = 2024
	AND discount_usd > 0
;

-- sales, profit, discount by year --
SELECT
	SUM(sales_usd) AS total_sales,
    SUM(profit_usd) AS total_profit,
    SUM(discount_usd) AS total_discounts,
    SUM(profit_usd) / SUM(sales_usd) AS profit_pct,
    SUM(discount_usd) / SUM(sales_usd) AS discount_pct
FROM orders
;
									-- PRODUCTS/CATEGORY --
-- number of products and product categories --
SELECT
	COUNT(DISTINCT product_id) AS num_products,
    COUNT(DISTINCT product_category) AS num_product_cat
FROM products
;

-- best selling product category --
SELECT
    COUNT(o.sales_usd) AS num_orders,
    SUM(o.sales_usd) AS total_sales,
	AVG(o.sales_usd) AS avg_sales,
    p.product_category
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
GROUP BY p.product_category
ORDER BY num_orders DESC
;

-- pct of total sales and avg profit by product category --
SELECT
	p.product_category,
	SUM(o.sales_usd) AS total_sales,
    SUM(o.sales_usd) / (
								SELECT SUM(sales_usd)
                                FROM orders
							  ) AS pct_of_total,
    AVG(o.profit_usd) AS avg_profit
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
    SUM(o.sales_usd) AS total_sales,
    AVG(o.profit_usd) AS avg_profit
FROM products p
JOIN orders o
	ON p.product_id = o.product_id
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10
;

									-- REGION --
-- sales and profit by region --
SELECT
	customer_region,
    SUM(sales_usd) AS total_sales,
    SUM(sales_usd) / (
							SELECT SUM(sales_usd)
                            FROM orders
                            ) AS pct_of_total,
	AVG(profit_usd) AS avg_profit
FROM orders
GROUP BY customer_region
ORDER BY total_sales DESC
;

-- sales by state --
SELECT
	customer_state,
    SUM(sales_usd) AS total_sales,
    SUM(sales_usd) / (
							SELECT SUM(sales_usd)
                            FROM orders
							) AS pct_of_total
FROM orders
GROUP BY customer_state
ORDER BY total_sales DESC
LIMIT 10
;

-- leading categories in California --
SELECT
	p.product_category,
    SUM(o.sales_usd) AS total_sales,
    SUM(o.sales_usd) / (
						SELECT SUM(sales_usd)
                        FROM orders
                        WHERE customer_state = 'California'
                        ) AS pct_of_total
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
WHERE o.customer_state = 'California'
GROUP BY p.product_category
;

-- leading products in California --
-- most and least profitable states --
-- switch sorting in ORDER BY clause to find most and least --
SELECT
	customer_state,
    AVG(profit_usd) AS avg_profit
FROM orders
GROUP BY customer_state
ORDER BY avg_profit ASC
;

									-- SHIPPING --
-- delivery classifications --
SELECT
	delivery_status,
    COUNT(*) AS num_orders,
    COUNT(*) / (
				SELECT COUNT(*)
                FROM orders
                ) AS pct_of_total
FROM orders
GROUP BY delivery_status
ORDER BY pct_of_total DESC
;

-- scheduled vs actual shipping time --
SELECT
	AVG(est_ship_days) AS sch_days,
    AVG(actual_ship_days) AS act_days
FROM orders
;

-- shipping variance by region --
SELECT
	customer_region,
    AVG(est_ship_days)-AVG(actual_ship_days) AS avg_time_diff
FROM orders
GROUP BY customer_region
ORDER BY avg_time_diff DESC
;

-- shipping variance by state --
SELECT
	customer_state,
    AVG(est_ship_days)-AVG(actual_ship_days) AS avg_time_diff
FROM orders
GROUP BY customer_state
ORDER BY avg_time_diff ASC
LIMIT 5
;