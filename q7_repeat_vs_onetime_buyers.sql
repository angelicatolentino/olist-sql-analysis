-- =====================================================================
-- QUESTION 7: How many customers are repeat buyers vs one-time buyers?
-- Theme: Behaviour
-- Skill used: CTE, CASE classification, window function for the share
-- =====================================================================
-- I count each person's delivered orders first in the CTE, then label
-- them in the outer query. Again this is grouped on customer_unique_id,
-- because customer_id changes with every order and would make 100% of
-- customers look like one-time buyers.

WITH Customer_Orders AS (
	SELECT
		c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Total_Orders
	FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	WHERE o.order_status = 'delivered'
	GROUP BY c.customer_unique_id
)
SELECT
	CASE
		WHEN Total_Orders = 1 THEN 'One-time buyer'
        ELSE 'Repeat buyer'
	END AS Buyer_Type,
    COUNT(*) AS Total_Customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Percent_Of_Customers
FROM Customer_Orders
GROUP BY Buyer_Type
ORDER BY Total_Customers DESC;


-- ---------------------------------------------------------------------
-- CHECKING THE ANSWER: are those repeat buyers real?
-- ---------------------------------------------------------------------
-- The query above counts anyone with 2 or more orders as a repeat buyer.
-- When I looked at the actual rows behind that number, a lot of the
-- "second" orders were placed on the SAME DAY as the first, sometimes
-- only seconds apart. Those are not people coming back. They are one
-- shopping basket split into separate order IDs because the items came
-- from different sellers.
--
-- So I used LAG to work out the gap between each customer's orders, then
-- split the results into same-day splits and genuine return visits. This
-- changed my answer, so I am including it as part of the question.

WITH Purchase_Gap AS (
	SELECT
		c.customer_unique_id,
        DATEDIFF(
			o.order_purchase_timestamp,
            LAG(o.order_purchase_timestamp) OVER (
				PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp
			)
		) AS Days_Since_Last_Purchase
	FROM orders o
	JOIN customers c
		ON o.customer_id = c.customer_id
	WHERE o.order_status = 'delivered'
)
SELECT
	CASE
		WHEN Days_Since_Last_Purchase = 0 THEN 'Same day (split order)'
        ELSE 'Genuine return visit'
	END AS Gap_Type,
    COUNT(*) AS Repeat_Purchases,
    COUNT(DISTINCT customer_unique_id) AS Customers,
    ROUND(AVG(Days_Since_Last_Purchase), 1) AS Average_Days_Between_Orders
FROM Purchase_Gap
WHERE Days_Since_Last_Purchase IS NOT NULL
GROUP BY Gap_Type;
