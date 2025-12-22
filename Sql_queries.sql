-- ============================================================================
-- OLIST BRAZILIAN E-COMMERCE DASHBOARD
-- SQL QUERIES: 25 BUSINESS QUESTIONS
-- ============================================================================
-- These queries answer 25 distinct business questions
-- They demonstrate analytical thinking and SQL expertise
-- ============================================================================

-- ============================================================================
-- SECTION 1: REVENUE & SALES QUESTIONS (Q1-Q4)
-- ============================================================================

-- Q1: What is our total revenue? What's the trend?
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month DESC;

-- Q2: Which product categories drive the most revenue?
SELECT 
    ct.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(oi.order_item_sequence) AS items_sold,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_price,
    ROUND((ROUND(SUM(oi.price)::NUMERIC, 2) / (SELECT ROUND(SUM(oi2.price)::NUMERIC, 2) FROM order_items oi2) * 100)::NUMERIC, 2) AS revenue_share_pct
FROM products p
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY ct.product_category_name_english
ORDER BY revenue DESC;

-- Q3: What are our top 10 products by revenue?
SELECT 
    p.product_id,
    p.product_name_length,
    ct.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS times_ordered,
    SUM(oi.price) AS total_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_price,
    SUM(oi.freight_value) AS total_freight
FROM products p
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name_length, ct.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;

-- Q4: What is the average order value? Is it growing?
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2) AS avg_order_value,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month DESC;

-- ============================================================================
-- SECTION 2: PRODUCT PERFORMANCE QUESTIONS (Q5-Q8)
-- ============================================================================

-- Q5: Which products have the highest/lowest ratings?
SELECT 
    p.product_id,
    ct.product_category_name_english,
    COUNT(DISTINCT or2.review_id) AS review_count,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_rating,
    COUNT(CASE WHEN or2.review_score >= 4 THEN 1 END) AS positive_reviews,
    COUNT(CASE WHEN or2.review_score <= 2 THEN 1 END) AS negative_reviews
FROM products p
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
WHERE or2.review_id IS NOT NULL
GROUP BY p.product_id, ct.product_category_name_english
HAVING COUNT(DISTINCT or2.review_id) >= 5
ORDER BY avg_rating DESC;

-- Q6: Do heavier products have higher shipping costs?
SELECT 
    p.product_weight_g,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(AVG(oi.freight_value)::NUMERIC, 2) AS avg_freight,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
WHERE p.product_weight_g IS NOT NULL
GROUP BY p.product_weight_g
ORDER BY p.product_weight_g DESC
LIMIT 20;

-- Q7: Which product categories have the most reviews?
SELECT 
    ct.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT or2.review_id) AS total_reviews,
    ROUND((COUNT(DISTINCT or2.review_id)::NUMERIC / COUNT(DISTINCT oi.order_id) * 100)::NUMERIC, 2) AS review_rate_pct,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_score
FROM category_translation ct
JOIN products p ON ct.product_category_name = p.product_category_name
JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY ct.product_category_name_english
ORDER BY review_rate_pct DESC;

-- Q8: What is the ROI by product category? (Revenue vs Shipping Cost)
SELECT 
    ct.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS revenue,
    ROUND(SUM(oi.freight_value)::NUMERIC, 2) AS shipping_cost,
    ROUND((SUM(oi.price) - SUM(oi.freight_value))::NUMERIC, 2) AS net_revenue,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_satisfaction
FROM category_translation ct
JOIN products p ON ct.product_category_name = p.product_category_name
JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY ct.product_category_name_english
ORDER BY net_revenue DESC;

-- ============================================================================
-- SECTION 3: DELIVERY & OPERATIONAL QUESTIONS (Q9-Q12)
-- ============================================================================

-- Q9: What percentage of orders are delivered on time?
SELECT 
    CASE 
        WHEN o.order_delivered_customer_date IS NULL THEN 'Not Delivered'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND((COUNT(DISTINCT o.order_id)::NUMERIC / (SELECT COUNT(*) FROM orders) * 100)::NUMERIC, 2) AS pct_of_total
FROM orders o
GROUP BY delivery_status
ORDER BY order_count DESC;

-- Q10: What's the average delivery time? How does it vary by state?
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(AVG(CAST((o.order_delivered_customer_date - o.order_purchase_timestamp) AS NUMERIC))::NUMERIC, 1) AS avg_delivery_days,
    MIN(CAST((o.order_delivered_customer_date - o.order_purchase_timestamp) AS NUMERIC)) AS min_days,
    MAX(CAST((o.order_delivered_customer_date - o.order_purchase_timestamp) AS NUMERIC)) AS max_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- Q11: Are late deliveries correlated with low reviews?
SELECT 
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_performance,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_review_score,
    COUNT(CASE WHEN or2.review_score >= 4 THEN 1 END) AS positive_reviews,
    COUNT(CASE WHEN or2.review_score <= 2 THEN 1 END) AS negative_reviews
FROM orders o
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
WHERE or2.review_score IS NOT NULL AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_performance
ORDER BY avg_review_score DESC;

-- Q12: Is satisfaction changing over time?
SELECT 
    DATE_TRUNC('month', or2.review_creation_date) AS month,
    COUNT(DISTINCT or2.review_id) AS review_count,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_score,
    COUNT(CASE WHEN or2.review_score >= 4 THEN 1 END) AS positive_reviews,
    COUNT(CASE WHEN or2.review_score <= 2 THEN 1 END) AS negative_reviews
FROM order_reviews or2
GROUP BY DATE_TRUNC('month', or2.review_creation_date)
ORDER BY month DESC;

-- ============================================================================
-- SECTION 4: CUSTOMER INSIGHTS QUESTIONS (Q13-Q17)
-- ============================================================================

-- Q13: What is our customer acquisition trend?
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.customer_id) AS new_customers_ordering,
    COUNT(DISTINCT o.order_id) AS orders
FROM orders o
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month DESC;

-- Q14: Which states/cities generate the most revenue?
SELECT 
    c.customer_state,
    c.customer_city,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS revenue,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state, c.customer_city
ORDER BY revenue DESC
LIMIT 20;

-- Q15: What is customer lifetime value? Who are VIP customers?
SELECT 
    c.customer_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS lifetime_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_spent,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2) AS avg_order_value,
    MIN(DATE(o.order_purchase_timestamp)) AS first_order_date,
    MAX(DATE(o.order_purchase_timestamp)) AS last_order_date,
    CAST((MAX(DATE(o.order_purchase_timestamp)) - MIN(DATE(o.order_purchase_timestamp))) AS INT) AS customer_age_days,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_review_score
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY c.customer_id, c.customer_city, c.customer_state
ORDER BY total_spent DESC
LIMIT 100;

-- Q16: What is the repeat purchase rate?
WITH customer_order_counts AS (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time Buyer'
        WHEN order_count BETWEEN 2 AND 3 THEN '2-3 Orders'
        WHEN order_count BETWEEN 4 AND 5 THEN '4-5 Orders'
        ELSE '6+ Orders'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND((COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM customer_order_counts) * 100)::NUMERIC, 2) AS pct_of_customers
FROM customer_order_counts
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- Q17: Customer geographic distribution (map analysis)
SELECT 
    c.customer_state,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- ============================================================================
-- SECTION 5: SELLER PERFORMANCE QUESTIONS (Q18-Q20)
-- ============================================================================

-- Q18: Which sellers generate the most revenue?
SELECT 
    s.seller_id,
    s.seller_state,
    s.seller_city,
    COUNT(DISTINCT oi.order_id) AS orders,
    SUM(oi.order_item_sequence) AS items_sold,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_item_price,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_rating,
    COUNT(DISTINCT or2.review_id) AS total_reviews
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY s.seller_id, s.seller_state, s.seller_city
ORDER BY revenue DESC
LIMIT 20;

-- Q19: Do sellers in certain states perform better?
SELECT 
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS seller_count,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_price,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_rating
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;

-- Q20: Do sellers with more products have higher revenue?
SELECT 
    s.seller_id,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS revenue,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_rating
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY s.seller_id
ORDER BY unique_products DESC
LIMIT 20;

-- ============================================================================
-- SECTION 6: PAYMENT & FINANCIAL QUESTIONS (Q21-Q22)
-- ============================================================================

-- Q21: What payment methods do customers prefer?
SELECT 
    op.payment_type,
    COUNT(DISTINCT op.order_id) AS orders,
    ROUND(SUM(op.payment_value)::NUMERIC, 2) AS total_value,
    ROUND(AVG(op.payment_value)::NUMERIC, 2) AS avg_payment,
    ROUND((COUNT(DISTINCT op.order_id)::NUMERIC / (SELECT COUNT(DISTINCT order_id) FROM order_payments) * 100)::NUMERIC, 2) AS pct_of_orders
FROM order_payments op
GROUP BY op.payment_type
ORDER BY orders DESC;

-- Q22: Is there a correlation between installments and order value?
SELECT 
    op.payment_installments,
    COUNT(DISTINCT op.order_id) AS orders,
    ROUND(AVG(op.payment_value)::NUMERIC, 2) AS avg_order_value,
    ROUND(SUM(op.payment_value)::NUMERIC, 2) AS total_value,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_review_score
FROM order_payments op
LEFT JOIN orders o ON op.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY op.payment_installments
ORDER BY payment_installments ASC;

-- ============================================================================
-- SECTION 7: SATISFACTION QUESTIONS (Q23-Q25)
-- ============================================================================

-- Q23: What's our overall satisfaction score?
SELECT 
    COUNT(DISTINCT or2.review_id) AS total_reviews,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_score,
    COUNT(CASE WHEN or2.review_score = 5 THEN 1 END) AS five_star,
    COUNT(CASE WHEN or2.review_score = 4 THEN 1 END) AS four_star,
    COUNT(CASE WHEN or2.review_score = 3 THEN 1 END) AS three_star,
    COUNT(CASE WHEN or2.review_score = 2 THEN 1 END) AS two_star,
    COUNT(CASE WHEN or2.review_score = 1 THEN 1 END) AS one_star
FROM order_reviews or2;

-- Q24: Which categories get the lowest ratings?
SELECT 
    ct.product_category_name_english,
    COUNT(DISTINCT or2.review_id) AS review_count,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_rating,
    COUNT(CASE WHEN or2.review_score >= 4 THEN 1 END) AS positive_reviews_pct,
    COUNT(CASE WHEN or2.review_score <= 2 THEN 1 END) AS negative_reviews_pct
FROM order_reviews or2
LEFT JOIN orders o ON or2.order_id = o.order_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE or2.review_score IS NOT NULL
GROUP BY ct.product_category_name_english
ORDER BY avg_rating ASC;

-- Q25: What's the relationship between shipping cost and review score?
SELECT 
    ROUND(oi.freight_value, -1)::INT AS freight_bucket,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_score,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_item_price
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
WHERE oi.freight_value > 0
GROUP BY ROUND(oi.freight_value, -1)
ORDER BY freight_bucket ASC;

-- ============================================================================
-- END OF 25 BUSINESS QUESTIONS
-- ============================================================================