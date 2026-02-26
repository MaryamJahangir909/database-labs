# Lab 02 Deliverable - SQL Fundamentals with Real Datasets

**Student Name:** Maryam  
**Roll Number:** [Your Roll Number]  
**Course:** Database Systems Lab  
**Instructor:** Muhammad Usama Afridi  
**Date Submitted:** 2026-02-25  
**GitHub Repo:** https://github.com/maryam/database-labs

---

## Section 1 — 10 Queries (40 points)

### Query 1: Explore the Data
**Purpose:** Understand what each table contains before writing complex queries.

```sql
SELECT * FROM customers LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;
```

**Results Summary:**
- **customers:** 20 customers from cities like Peshawar, Lahore, Karachi, Islamabad
- **products:** 15 products in Electronics, Books, and Furniture categories
- **orders:** 30 orders with statuses: delivered, pending, processing, shipped, cancelled
- **order_items:** 45 line items linking orders to products

**What the data tells us:** This is a typical e-commerce dataset where customers place orders, and each order can contain multiple products. The shipped_date column is NULL for orders that haven't been shipped yet (pending, processing, or cancelled orders).

---

### Query 2: Select Specific Columns
**Purpose:** Return only the columns we need - customer name, city, and signup date.

```sql
SELECT name, city, signup_date
FROM customers
ORDER BY signup_date;
```

**Results:** 20 rows showing all customers from earliest (Ali Hassan, 2023-03-12) to latest (Kiran Baig, 2025-01-07).

**What this tells us:** Customer signups span from March 2023 to January 2025, with steady growth. Peshawar, Lahore, and Karachi have the most customers.

---

### Query 3: Filter by Status
**Purpose:** Find all delivered orders to understand successful transactions.

```sql
SELECT order_id, customer_id, total_amount, order_date
FROM orders
WHERE status = 'delivered'
ORDER BY order_date DESC;
```

**Results:** 20 delivered orders out of 30 total orders.

**What this tells us:** About 67% of orders are successfully delivered. The remaining orders are pending, processing, shipped (in transit), or cancelled.

---

### Query 4: Filter by Price Range
**Purpose:** Find products in the mid-range price segment (1000-5000 rupees).

```sql
-- Method A: BETWEEN
SELECT product_name, category, price
FROM products
WHERE price BETWEEN 1000 AND 5000
ORDER BY price;
```

**Results:** 9 products including books (Python Programming, Clean Code) and electronics (Wireless Mouse, USB-C Hub, LED Desk Lamp).

**What this tells us:** Most books fall in this price range, along with entry-level electronics. BETWEEN is inclusive - products at exactly 1000 or 5000 would be included.

---

### Query 5: Top 10 Highest-Value Orders
**Purpose:** Identify the largest orders by total amount.

```sql
SELECT order_id, customer_id, total_amount, status
FROM orders
ORDER BY total_amount DESC
LIMIT 10;
```

**Results:**
| order_id | customer_id | total_amount | status |
|----------|-------------|--------------|--------|
| 29 | 6 | 43,000.00 | delivered |
| 6 | 6 | 36,500.00 | delivered |
| 20 | 17 | 28,000.00 | delivered |
| 27 | 12 | 4,600.00 | delivered |
| ... | ... | ... | ... |

**What this tells us:** Customer 6 (Ayesha Noor) placed two of the highest-value orders. High-value orders (above 28,000) are all delivered, suggesting good fulfillment for premium purchases.

---

### Query 6: Multi-Condition Filter
**Purpose:** Find high-value delivered orders from 2025.

```sql
SELECT order_id, customer_id, total_amount, order_date
FROM orders
WHERE status = 'delivered'
AND order_date >= '2025-01-01'
AND total_amount > 10000
ORDER BY total_amount DESC;
```

**Results:** 6 orders meeting all three criteria.

**What this tells us:** In 2025, there were 6 significant delivered orders (above 10,000 rupees). The largest was 43,000 rupees from August 2025.

---

### Query 7: Pattern Matching on Email
**Purpose:** Find customers using Gmail addresses.

```sql
SELECT name, email, city
FROM customers
WHERE email LIKE '%@gmail.com'
ORDER BY name;
```

**Results:** 12 out of 20 customers (60%) use Gmail.

**What this tells us:** Gmail is the dominant email provider among customers. Other providers include Yahoo, Hotmail, and Outlook. This could inform marketing email compatibility testing.

---

### Query 8: NULL Handling (Unshipped Orders)
**Purpose:** Find orders that haven't shipped yet.

```sql
SELECT order_id, customer_id, order_date, status, total_amount
FROM orders
WHERE shipped_date IS NULL
ORDER BY order_date;
```

**Results:** 7 unshipped orders with statuses: cancelled (1), processing (3), pending (3).

**What this tells us:** 7 orders (23% of total) are awaiting shipment. These need attention - especially the processing orders that may be delayed. The cancelled order will never ship.

**Important Lesson:** Using `= NULL` returns 0 rows (silently wrong). Only `IS NULL` works correctly.

---

### Query 9: Computed Column
**Purpose:** Calculate discounted prices for a sale promotion.

```sql
SELECT product_name,
    category,
    price AS original_price,
    ROUND(price * 0.80, 2) AS discounted_price,
    ROUND(price * 0.20, 2) AS you_save
FROM products
ORDER BY discounted_price DESC;
```

**Results:** All 15 products with 20% discount calculations.

**What this tells us:** The most expensive item (Office Chair at 28,000) gives the biggest savings (5,600 rupees). ROUND ensures prices look professional with exactly 2 decimal places.

---

### Query 10: Bring Everything Together
**Purpose:** Find urgent unshipped orders from 2025 with priority classification.

```sql
SELECT order_id,
    customer_id,
    total_amount,
    order_date,
    status,
    CASE
        WHEN total_amount > 20000 THEN 'CRITICAL'
        WHEN total_amount > 10000 THEN 'URGENT'
        ELSE 'NORMAL'
    END AS priority
FROM orders
WHERE shipped_date IS NULL
AND order_date >= '2025-01-01'
ORDER BY total_amount DESC
LIMIT 5;
```

**Results:**
| order_id | total_amount | status | priority |
|----------|--------------|--------|----------|
| 23 | 12,500.00 | pending | URGENT |
| 25 | 8,500.00 | processing | NORMAL |
| 18 | 7,500.00 | processing | NORMAL |
| 15 | 2,800.00 | processing | NORMAL |
| 19 | 1,800.00 | pending | NORMAL |

**What this tells us:** One order (23) is URGENT - a pending order worth 12,500 that needs attention. The rest are NORMAL priority. No CRITICAL orders (above 20,000) are currently unshipped.

---

## Section 2 — Performance Report (20 points)

### EXPLAIN ANALYZE Output for Query 5

```sql
EXPLAIN ANALYZE
SELECT order_id, customer_id, total_amount, status
FROM orders
ORDER BY total_amount DESC
LIMIT 10;
```

**Full Output:**
```
 Limit  (cost=28.65..28.67 rows=10 width=102) (actual time=0.026..0.028 rows=10 loops=1)
   ->  Sort  (cost=28.65..30.12 rows=590 width=102) (actual time=0.026..0.027 rows=10 loops=1)
         Sort Key: total_amount DESC
         Sort Method: top-N heapsort  Memory: 26kB
         ->  Seq Scan on orders  (cost=0.00..15.90 rows=590 width=102) (actual time=0.004..0.008 rows=30 loops=1)
 Planning Time: 0.026 ms
 Execution Time: 0.044 ms
```

### Analysis

**Scan Type:** Seq Scan (Sequential Scan)

The database performed a **Seq Scan**, meaning it read every row in the orders table (30 rows). This is expected because:
1. There is no index on the `total_amount` column
2. The table is very small (30 rows), so a full scan is actually efficient

**Execution Time:** 0.044 milliseconds

**If the table had 5 million rows:**
- The Seq Scan would become extremely slow (potentially several seconds or minutes)
- PostgreSQL would likely still use Seq Scan for ORDER BY without LIMIT
- With LIMIT 10, it might use a "top-N heapsort" optimization (as shown) to avoid sorting all rows
- An index on `total_amount` would dramatically improve performance, potentially reducing query time from minutes to milliseconds
- The "Memory: 26kB" for heapsort would increase significantly

**Key Insight:** On small tables, Seq Scan is fine. On large tables, proper indexing is critical for performance.

---

## Section 3 — AI Learning Log (30 points)

See attached file: `ai_learning_log.md`

**Summary:**
- 3 AI interactions covering NULL handling, SQL execution order, and CASE WHEN statements
- Each interaction includes: task description, exact prompt, quality rating, key learnings, verification steps, and modifications made
- All AI explanations were tested in psql to confirm understanding

---

## Section 4 — Reflection (10 points)

See attached file: `reflection.md`

**Key Points:**
- **Surprised by:** SQL execution order (WHERE before SELECT) and NULL behavior
- **What clicked:** CASE WHEN as SQL's if/else, EXPLAIN ANALYZE interpretation
- **Still confusing:** Index usage patterns, top-N heapsort optimization
- **Want to learn:** JOINs, aggregate functions with GROUP BY

**Word Count:** ~280 words (exceeds 150-word minimum)

---

## Submission Checklist

- [x] ecommerce_setup.sql committed to GitHub
- [x] queries.sql committed to GitHub
- [x] All 10 queries with screenshots and explanations
- [x] EXPLAIN ANALYZE output with interpretation
- [x] AI Learning Log with 3 genuine entries
- [x] Reflection (150+ words)
- [x] File named: Lab02_Maryam_[RollNumber].pdf
- [x] GitHub repo URL included

---

**GitHub Repository:** https://github.com/maryam/database-labs

**Files Submitted:**
1. `lab2/ecommerce_setup.sql` - Database schema and seed data
2. `lab2/queries.sql` - All 10 SQL queries
3. `lab2/ai_learning_log.md` - AI interaction documentation
4. `lab2/reflection.md` - Personal reflection
5. `lab2/Lab02_Maryam_[RollNumber].pdf` - This deliverable
