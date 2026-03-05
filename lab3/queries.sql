-- ============================================================
-- Lab 03: Advanced SQL - Aggregations & Analytics
-- Author: Maryam Jahangir
-- Roll No: 16
-- Date: 2026-03-05
-- Database: lab1_db
-- ============================================================

-- ============================================================
-- Query 1: Overall Business Summary
-- Purpose: KPI summary showing total orders, revenue, avg order value, 
--          and largest order for delivered orders only
-- ============================================================
SELECT 
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    MAX(total_amount) AS largest_order
FROM orders
WHERE status = 'delivered';

-- ============================================================
-- Query 2: Revenue by Product Category
-- Purpose: Find how much revenue each product category has generated
--          across all order items
-- ============================================================
SELECT 
    p.category,
    COUNT(DISTINCT oi.order_id) AS orders_containing,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- ============================================================
-- Query 3: Monthly Order Volume and Revenue
-- Purpose: Time-series aggregation showing orders and revenue per month
-- ============================================================
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    COUNT(*) AS num_orders,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- ============================================================
-- Query 4: HAVING - Active Cities
-- Purpose: Find all cities where customers placed more than 2 orders total
-- ============================================================
SELECT 
    c.city,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
HAVING COUNT(o.order_id) > 2
ORDER BY total_orders DESC;

-- ============================================================
-- Query 5: Device Performance with HAVING
-- Purpose: Find devices with average session duration above 15 minutes
--          and at least 5 sessions
-- ============================================================
SELECT 
    device,
    COUNT(*) AS total_sessions,
    ROUND(AVG(duration_mins), 2) AS avg_duration,
    SUM(CASE WHEN converted THEN 1 ELSE 0 END) AS conversions,
    ROUND(
        100.0 * SUM(CASE WHEN converted THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS conversion_rate_pct
FROM user_sessions
GROUP BY device
HAVING COUNT(*) >= 5
   AND AVG(duration_mins) > 15
ORDER BY conversion_rate_pct DESC;

-- ============================================================
-- Query 6: Ranking Orders with ROW_NUMBER
-- Purpose: For each customer, rank their orders from largest to smallest
-- ============================================================
SELECT 
    customer_id,
    order_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id 
        ORDER BY total_amount DESC
    ) AS rank_within_customer
FROM orders
ORDER BY customer_id, rank_within_customer;

-- Extended: Find each customer's single highest-value order
WITH ranked_orders AS (
    SELECT 
        customer_id,
        order_id,
        order_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY total_amount DESC
        ) AS rank_within_customer
    FROM orders
)
SELECT 
    customer_id,
    order_id,
    order_date,
    total_amount,
    rank_within_customer
FROM ranked_orders
WHERE rank_within_customer = 1
ORDER BY total_amount DESC;

-- ============================================================
-- Query 7: Overall Revenue Ranking with RANK
-- Purpose: Compare RANK vs DENSE_RANK when there are ties
-- ============================================================
SELECT 
    order_id,
    customer_id,
    total_amount,
    RANK() OVER (ORDER BY total_amount DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY total_amount DESC) AS dense_rank
FROM orders
ORDER BY total_amount DESC
LIMIT 15;

-- ============================================================
-- Query 8: Month-over-Month Revenue Trend with LAG
-- Purpose: Show monthly revenue and comparison to previous month
-- ============================================================
WITH monthly_revenue AS (
    SELECT 
        TO_CHAR(order_date, 'YYYY-MM') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'delivered'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month,
    revenue - LAG(revenue) OVER (ORDER BY month) AS absolute_change,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) 
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        1
    ) AS pct_change
FROM monthly_revenue
ORDER BY month;

-- ============================================================
-- Query 9: Customer Value Segmentation using CTEs
-- Purpose: Classify customers into value tiers and analyze distribution
-- ============================================================
WITH customer_spend AS (
    SELECT 
        c.customer_id,
        c.name,
        c.city,
        COALESCE(SUM(o.total_amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o 
        ON c.customer_id = o.customer_id
        AND o.status = 'delivered'
    GROUP BY c.customer_id, c.name, c.city
),
customer_tiers AS (
    SELECT 
        *,
        CASE
            WHEN total_spent > 30000 THEN 'VIP'
            WHEN total_spent > 10000 THEN 'High Value'
            WHEN total_spent > 0 THEN 'Active'
            ELSE 'Never Purchased'
        END AS tier
    FROM customer_spend
)
SELECT 
    tier,
    COUNT(*) AS num_customers,
    ROUND(SUM(total_spent), 2) AS tier_revenue,
    ROUND(
        100.0 * SUM(total_spent) 
        / NULLIF(SUM(SUM(total_spent)) OVER (), 0),
        1
    ) AS revenue_share_pct
FROM customer_tiers
GROUP BY tier
ORDER BY tier_revenue DESC;

-- ============================================================
-- Query 10: Session-to-Purchase Funnel Analysis
-- Purpose: Compare browsing behaviour to purchase behaviour
--          to identify churn risk
-- ============================================================
WITH session_summary AS (
    SELECT 
        customer_id,
        COUNT(*) AS total_sessions,
        SUM(pages_viewed) AS total_pages,
        ROUND(AVG(duration_mins), 2) AS avg_duration,
        SUM(CASE WHEN converted THEN 1 ELSE 0 END) AS converted_sessions
    FROM user_sessions
    GROUP BY customer_id
),
order_summary AS (
    SELECT 
        customer_id,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_spent
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
),
combined AS (
    SELECT 
        c.name,
        c.city,
        s.total_sessions,
        s.total_pages,
        s.avg_duration,
        s.converted_sessions,
        COALESCE(o.total_orders, 0) AS total_orders,
        COALESCE(o.total_spent, 0) AS total_spent
    FROM session_summary s
    JOIN customers c ON s.customer_id = c.customer_id
    LEFT JOIN order_summary o ON s.customer_id = o.customer_id
)
SELECT 
    name,
    city,
    total_sessions,
    total_pages,
    avg_duration,
    total_orders,
    total_spent,
    ROUND(
        CASE WHEN total_sessions > 0 
             THEN 100.0 * total_orders / total_sessions 
             ELSE 0 
        END, 1
    ) AS orders_per_100_sessions
FROM combined
ORDER BY total_sessions DESC, orders_per_100_sessions ASC;

-- ============================================================
-- End of Lab 03 Queries
-- ============================================================
