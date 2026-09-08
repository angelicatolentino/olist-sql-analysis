-- =====================================================================
-- QUESTION 5: Rank the top 3 products within each category by revenue.
-- Theme: Ranking
-- Skill used: two CTEs, DENSE_RANK() with PARTITION BY
-- =====================================================================
-- This needs two steps. First I total up the revenue for every product,
-- which is the Product_Revenue CTE. Then I rank those products inside
-- their own category, which is the Ranked CTE.
--
-- PARTITION BY Product_Category is what makes the ranking restart for
-- every category. Without it I would get one long list ranked 1 to
-- 30,000 across the whole catalogue instead of a top 3 per category.
--
-- I had to do the ranking in a CTE because a window function cannot be
-- used in a WHERE clause of the same query. So I calculate the rank
-- first, then filter on it in the outer SELECT.
--
-- I picked DENSE_RANK so that if two products tie on revenue they share
-- the same rank and I still get a sensible top 3.

WITH Product_Revenue AS (
	SELECT
		COALESCE(p.product_category_name, 'Uncategorized') AS Product_Category,
        oi.product_id,
        COUNT(DISTINCT oi.order_id) AS Total_Orders,
        ROUND(SUM(oi.price), 2) AS Total_Revenue
	FROM products p
	JOIN order_items oi
		ON p.product_id = oi.product_id
	JOIN orders o
		ON oi.order_id = o.order_id
	WHERE o.order_status = 'delivered'
	GROUP BY Product_Category, oi.product_id
),
Ranked_Products AS (
	SELECT
		Product_Category,
        product_id,
        Total_Orders,
        Total_Revenue,
        DENSE_RANK() OVER (
			PARTITION BY Product_Category
            ORDER BY Total_Revenue DESC
		) AS Product_Rank
	FROM Product_Revenue
)
SELECT
	Product_Category,
    product_id,
    Total_Orders,
    Total_Revenue,
    Product_Rank
FROM Ranked_Products
WHERE Product_Rank <= 3
ORDER BY Product_Category ASC, Product_Rank ASC;
