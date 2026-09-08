-- =====================================================================
-- QUESTION 1: Who are the top 10 customers by total amount spent?
-- Theme: Top Customers
-- Skill used: multi-table JOIN, GROUP BY, SUM, ORDER BY with LIMIT
-- =====================================================================
-- I grouped on customer_unique_id, not customer_id. The customers table
-- issues a new customer_id for every order, so grouping on that would
-- give me one row per order and every customer would look identical.
-- customer_unique_id is the actual person.
--
-- I also used MAX on the city and state columns. A customer_unique_id
-- can appear with more than one address, and MAX just picks one so the
-- query still runs under strict mode. The city is only there for
-- context, it is not part of the ranking.

SELECT
	c.customer_unique_id,
    MAX(c.customer_city) AS Customer_City,
    MAX(c.customer_state) AS Customer_State,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    ROUND(SUM(op.payment_value), 2) AS Total_Spent
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_payments op
	ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY Total_Spent DESC
LIMIT 10;
