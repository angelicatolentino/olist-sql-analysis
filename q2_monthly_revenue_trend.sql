-- =====================================================================
-- QUESTION 2: What is the monthly revenue trend across the dataset?
-- Theme: Revenue Trends
-- Skill used: DATE_FORMAT, GROUP BY on a derived column, aggregation
-- =====================================================================
-- DATE_FORMAT turns each order date into a YYYY-MM label, so I can group
-- every order into the month it belongs to.
--
-- I sorted by month instead of by revenue so the result reads as a trend
-- from start to finish. If I want to find the best and worst month
-- instead, I just change the last line to ORDER BY total_revenue DESC.
--
-- I added avg_order_value because the trend alone does not tell me why
-- revenue moved. If revenue grows while this column stays flat, the
-- growth came from more customers and not from bigger orders.
--
-- I filtered to January 2017 onward, the same as Question 3, so the two
-- results cover the same period. The dataset technically starts in
-- October 2016, but November 2016 has no delivered orders and December
-- 2016 has only one order worth R$19.62. Those months make the trend
-- look like it collapsed and recovered when really the platform was just
-- starting up.

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(op.payment_value), 2) AS total_revenue,
    ROUND(SUM(op.payment_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
	AND o.order_purchase_timestamp >= '2017-01-01'
GROUP BY sales_month
ORDER BY sales_month ASC;
