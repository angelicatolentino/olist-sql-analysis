-- =====================================================================
-- QUESTION 8: What percentage of total revenue comes from the top
--             category?
-- Theme: Behaviour
-- Skill used: CTE, window function over the whole result set
-- =====================================================================
-- The trick here is getting the grand total onto every row so I can
-- divide against it. SUM(Total_Revenue) OVER () with empty brackets adds
-- up every category in the result without collapsing my rows.
--
-- Window functions run before LIMIT, so the percentages are calculated
-- against ALL the categories even though I only display the top five.
-- The answer to the question is the first row.
--
-- I used order_items.price rather than payment_value for the same reason
-- as Question 4: mixing items and payments in one query multiplies the
-- totals against each other.

WITH Category_Revenue AS (
	SELECT
		COALESCE(p.product_category_name, 'Uncategorized') AS Product_Category,
        SUM(oi.price) AS Total_Revenue
	FROM products p
	JOIN order_items oi
		ON p.product_id = oi.product_id
	JOIN orders o
		ON oi.order_id = o.order_id
	WHERE o.order_status = 'delivered'
	GROUP BY Product_Category
)
SELECT
	Product_Category,
    ROUND(Total_Revenue, 2) AS Category_Revenue,
    ROUND(SUM(Total_Revenue) OVER (), 2) AS All_Categories_Revenue,
    ROUND(Total_Revenue * 100.0 / SUM(Total_Revenue) OVER (), 2) AS Percent_Of_Total
FROM Category_Revenue
ORDER BY Category_Revenue DESC
LIMIT 5;
