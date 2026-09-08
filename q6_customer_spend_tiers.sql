-- =====================================================================
-- QUESTION 6: Segment customers into spend tiers (Low / Medium / High).
-- Theme: Segmentation
-- Skill used: CASE classification inside a subquery, aggregation,
--             window function for the revenue share
-- =====================================================================
-- This works in two layers. The inner query adds up how much each person
-- spent in total and tags them with a tier using CASE. The outer query
-- then counts how many customers ended up in each tier and how much
-- money that tier is worth.
--
-- I grouped on customer_unique_id, not customer_id, because customer_id
-- is reissued for every order. Grouping on it would put everybody in the
-- Low tier no matter how much they really spent.
--
-- SUM(SUM(Lifetime_Spend)) OVER () gives me the total revenue across all
-- three tiers on every row, so I can divide each tier against it and show
-- what share of the business it carries. The inner SUM runs per tier
-- first, then the window SUM adds those totals together without
-- collapsing my three rows into one.

SELECT
	Customer_Value_Tier,
    COUNT(*) AS Total_Customers,
    ROUND(SUM(Lifetime_Spend), 2) AS Tier_Revenue,
    ROUND(AVG(Lifetime_Spend), 2) AS Average_Spend,
    ROUND(SUM(Lifetime_Spend) * 100.0 / SUM(SUM(Lifetime_Spend)) OVER (), 2) AS Percent_Of_Revenue
FROM (
	SELECT
		c.customer_unique_id,
        SUM(op.payment_value) AS Lifetime_Spend,
		CASE
			WHEN SUM(op.payment_value) >= 500 THEN 'High Value'
			WHEN SUM(op.payment_value) >= 150 THEN 'Medium Value'
			ELSE 'Low Value'
		END AS Customer_Value_Tier
	FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	JOIN order_payments op
		ON o.order_id = op.order_id
	WHERE o.order_status = 'delivered'
	GROUP BY c.customer_unique_id
) AS Customer_Spend
GROUP BY Customer_Value_Tier
ORDER BY Tier_Revenue DESC;
