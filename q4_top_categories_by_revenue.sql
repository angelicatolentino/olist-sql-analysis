-- =====================================================================
-- QUESTION 4: Which product categories generate the most revenue?
-- Theme: Ranking
-- Skill used: 3-table INNER JOIN, GROUP BY, COALESCE, ORDER BY with LIMIT
-- =====================================================================
-- This is the query I had to be most careful with. My first instinct was
-- to use payment_value, the way I did for the monthly revenue question.
-- That would have been wrong here.
--
-- One order can contain several items AND be paid across several payment
-- rows. If I join order_items and order_payments together, each payment
-- repeats once per item and the revenue comes out far higher than it
-- really is. Since this question is about categories, I used
-- order_items.price, which belongs to the individual item.
--
-- Some products have no category filled in, so COALESCE labels those
-- 'Uncategorized' instead of leaving a blank row in my result.

SELECT
	COALESCE(p.product_category_name, 'Uncategorized') AS Product_Category,
    COUNT(DISTINCT oi.order_id) AS Total_Orders,
    ROUND(SUM(oi.price), 2) AS Total_Revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT oi.order_id), 2) AS Revenue_Per_Order
FROM products p
JOIN order_items oi
	ON p.product_id = oi.product_id
JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY Product_Category
ORDER BY Total_Revenue DESC
LIMIT 10;
