# Olist SQL Analysis

## Overview

This project analyses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) using MySQL 8.0. Olist is an online marketplace in Brazil that connects small sellers to buyers through the major shopping platforms.

The dataset covers **96,478 delivered orders worth R$15,422,462**, placed between **October 2016 and August 2018**, across six related tables: `orders`, `order_items`, `customers`, `order_payments`, `order_reviews` and `sellers`.

The question I set out to answer: **Olist's revenue grew sharply through 2017, then stopped growing in 2018. What caused the growth, why did it stall, and where should the business focus next?**

### Data quality notes

Three things needed handling before any analysis was trustworthy:

- **`customer_id` is not the customer.** The table gives a new one for every order, so there are 99,441 of them but only 96,096 real people. Every customer question uses `customer_unique_id` instead. Using `customer_id` would make every single customer look like a first-time buyer.
- **`order_items` and `order_payments` count different things.** One row in the first is an *item*, one row in the second is a *payment*. Joining them together doubles up the money. So I use `order_items.price` for product and category questions, and `order_payments.payment_value` for order and customer questions.
- **The earliest months are incomplete.** November 2016 has no delivered orders at all, and December 2016 has a single order worth R$19.62. Comparing against that produced a 649,979% month-over-month increase, so the trend queries are filtered to January 2017 onward.

---

## Business Questions

| # | Question | Theme |
|---|---|---|
| Q1 | Who are the top 10 customers by total amount spent? | Top Customers |
| Q2 | What is the monthly revenue trend across the dataset? | Revenue Trends |
| Q3 | What is the month-over-month change in revenue? | Revenue Trends |
| Q4 | Which product categories generate the most revenue? | Ranking |
| Q5 | Rank the top 3 products within each category by revenue. | Ranking |
| Q6 | Segment customers into spend tiers (Low / Medium / High). | Segmentation |
| Q7 | How many customers are repeat vs one-time buyers? | Behaviour |
| Q8 | What percentage of total revenue comes from the top category? | Behaviour |

---

## Key Findings

### 1. The growth came from more customers, not bigger orders, and it has stopped

Sales went from R$127,546 in January 2017 up to R$1,153,528 in November 2017, which is nine times bigger in ten months. The number of orders grew the same way, from 750 to 7,289. But the average amount people spent per order never changed, it just stayed between R$146 and R$170 the whole time.

So all of that growth came from more people buying, not from people spending more. In 2017 the monthly growth ran between +45% and +112%. From February 2018 the numbers moved between -10% and +16%, and the ups and downs mostly cancelled each other out. **No month ever beat the November 2017 peak again.**

### 2. Almost nobody comes back

Q7 shows 90,557 people who bought only once, against 2,801 who looked like they came back. But when I checked the gap between their orders, **890 of those second orders happened on the same day as the first**, sometimes only seconds apart. Those are not people coming back. That is one shopping basket getting split into separate orders because the items came from different sellers.

The real number is **2,015 customers, which is 2.2%**, and they took an average of **110.7 days** to come back.

This is exactly why the growth stopped. With almost nobody returning, the business has to find a whole new set of buyers every month, and then even more on top of that, just to grow. That only works while it keeps finding more and more new people.

### 3. No single category or customer group carries the business

The biggest category, `beleza_saude` (health and beauty), is only **9.33% of product sales**. The customer tiers are spread out too, at 42.7% Medium, 31.8% Low and 25.5% High. Nothing here is big enough to build a plan around.

And there is something else. Since 97% of customers only buy once, their total spend is really just their first order. **So these tiers are not loyalty groups at all, they are order size groups.** A "High Value" customer spending R$923 is not a loyal customer, it is someone who bought one expensive thing and left. Q1 proves it, because the highest spending customer in the whole dataset (R$13,664) placed only one order.

---

## Recommendations

### 1. Make the first order bigger instead of building a loyalty program

Since most people only buy once, their first order is basically all the money we will ever get from them. So the goal should be to make that one order bigger. Add product bundles, suggested add-ons at checkout, and free shipping once the customer spends a bit more than the R$159.86 average. A points card would not help much because there are hardly any repeat customers to give points to.

### 2. Reach out to customers 60 to 75 days after they buy

The few customers who do come back take about 110.7 days to do it. So we should reach out before that, while they still remember us, instead of waiting until they are gone. Start with the Low Value group, because at 61,804 customers spending R$79.29 each it is by far the biggest group, so even a small improvement there is worth more than a big one at the top.

---

## Tools & Skills

**Tools:** MySQL 8.0, MySQL Workbench, Microsoft Excel

**SQL skills demonstrated:**

- Multi-table `INNER JOIN` and `LEFT JOIN` across 3+ tables
- Aggregation with `GROUP BY`, `SUM`, `COUNT DISTINCT`, `AVG`, `MIN`, `MAX`
- `CASE` statement classification for customer tiers and buyer types
- Subqueries in the `FROM` clause
- Common Table Expressions (`WITH`), including multiple chained CTEs
- Window functions: `DENSE_RANK()`, `LAG()`, and `SUM() OVER ()` for share-of-total
- `DATE_FORMAT` and `DATEDIFF` for time-based analysis
- Handling nulls with `COALESCE`
- Understanding table grain to avoid fan-out errors in joins

---

## Files

| File | Contents |
|---|---|
| `q1_top_customers.sql` | Top 10 customers by total spend |
| `q2_monthly_revenue_trend.sql` | Monthly revenue, orders and average order value |
| `q3_month_over_month_change.sql` | Month-over-month change using `LAG()` |
| `q4_top_categories_by_revenue.sql` | Top 10 categories by revenue |
| `q5_top_3_products_per_category.sql` | Top 3 products per category using `DENSE_RANK()` |
| `q6_customer_spend_tiers.sql` | Low / Medium / High segmentation |
| `q7_repeat_vs_onetime_buyers.sql` | Repeat vs one-time buyers, plus the split-order check |
| `q8_top_category_revenue_share.sql` | Top category's share of product revenue |
| `One_Page_Insight_Summary.pdf` | One-page written summary of findings and recommendations |
| `/screenshots` | Query results as run in MySQL Workbench |

Every `.sql` file includes comments explaining why the query is written the way it is, not just what it does.

---

*Cristine Angelica Marie Serrano Tolentino*
