-- =====================================================================
-- QUESTION 3: What is the month-over-month change in revenue?
-- Theme: Revenue Trends
-- Skill used: CTE, LAG() window function, percentage calculation
-- =====================================================================
-- I could not calculate this in one step. First I needed one row per
-- month, so I built that as a CTE. Then LAG pulls the previous month's
-- revenue onto the current month's row, which lets me subtract one from
-- the other.
--
-- The first row comes back NULL for the change columns. That is correct,
-- because the first month has no month before it to compare against.
--
-- I filtered to January 2017 onward. October and December 2016 are the
-- only earlier months with any delivered orders, and December 2016 holds
-- a single order worth R$19.62. Comparing the next month against that
-- produced a 649,979% increase, which is arithmetically correct but
-- meaningless. November 2016 has no delivered orders at all. The
-- platform was only starting up, so the trend is only worth reading from
-- 2017 onward.
--
-- I multiplied by 100.0 instead of 100 so MySQL returns a decimal
-- percentage instead of rounding it down to a whole number.

WITH Monthly_Revenue AS (
	SELECT
		DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sales_month,
        ROUND(SUM(op.payment_value), 2) AS total_revenue
	FROM orders o
	JOIN order_payments op
		ON o.order_id = op.order_id
	WHERE o.order_status = 'delivered'
		AND o.order_purchase_timestamp >= '2017-01-01'
	GROUP BY sales_month
)
SELECT
	sales_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue,
    ROUND(
		total_revenue - LAG(total_revenue) OVER (ORDER BY sales_month), 2
	) AS change_in_revenue,
    ROUND(
		(total_revenue - LAG(total_revenue) OVER (ORDER BY sales_month)) * 100.0
        / LAG(total_revenue) OVER (ORDER BY sales_month), 2
	) AS percent_change
FROM Monthly_Revenue
ORDER BY sales_month ASC;
