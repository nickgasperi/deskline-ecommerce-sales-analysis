-- this project's data cleaning and prep was performed in Excel --
-- but after loading the data into the DBMS, I realized I forgot to add a numeric month column --

-- create column --
ALTER TABLE orders
ADD month_id TINYINT
;

-- add values based on existing `order_month` column
UPDATE orders
SET month_id = CASE
	WHEN order_month = 'Jan' THEN 1
    WHEN order_month = 'Feb' THEN 2
    WHEN order_month = 'Mar' THEN 3
    WHEN order_month = 'Apr' THEN 4
    WHEN order_month = 'May' THEN 5
    WHEN order_month = 'Jun' THEN 6
    WHEN order_month = 'Jul' THEN 7
    WHEN order_month = 'Aug' THEN 8
    WHEN order_month = 'Sep' THEN 9
    WHEN order_month = 'Oct' THEN 10
    WHEN order_month = 'Nov' THEN 11
    WHEN order_month = 'Dec' THEN 12
END
;