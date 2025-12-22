-- ============================================================================
-- OLIST BRAZILIAN E-COMMERCE DASHBOARD
-- SQL VIEWS FOR POWER BI
-- 8 Production Views for Analytics
-- ============================================================================

-- VIEW 1: Product Performance
-- Purpose: Product-level KPIs with ratings, revenue, and order counts
CREATE VIEW v_product_performance AS
SELECT 
    p.product_id,
    p.product_category_name,
    ct.product_category_name_english AS category_english,
    p.product_name_length,
    p.product_weight_g,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT oi.order_item_sequence) AS total_items_sold,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_price,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(oi.freight_value)::NUMERIC, 2) AS total_freight_cost,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_gross_revenue,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_review_score,
    COUNT(DISTINCT or2.review_id) AS total_reviews,
    ROUND((COUNT(DISTINCT or2.review_id)::NUMERIC / NULLIF(COUNT(DISTINCT oi.order_id), 0) * 100)::NUMERIC, 2) AS review_rate_pct
FROM products p
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY p.product_id, p.product_category_name, ct.product_category_name_english, 
         p.product_name_length, p.product_weight_g
ORDER BY total_revenue DESC;

-- ============================================================================

-- VIEW 2: Category Performance
-- Purpose: Category-level aggregations with profitability and satisfaction
CREATE VIEW v_category_performance AS
SELECT 
    ct.product_category_name_english AS category,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT oi.order_item_sequence) AS total_items_sold,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(oi.freight_value)::NUMERIC, 2) AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_gross_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_item_price,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_review_score,
    ROUND((COUNT(DISTINCT or2.review_id)::NUMERIC / NULLIF(COUNT(DISTINCT oi.order_id), 0) * 100)::NUMERIC, 2) AS review_rate_pct
FROM category_translation ct
LEFT JOIN products p ON ct.product_category_name = p.product_category_name
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY ct.product_category_name_english
ORDER BY total_revenue DESC;

-- ============================================================================

-- VIEW 3: Daily Sales Trends
-- Purpose: Time-series sales data at order date granularity
CREATE VIEW v_daily_sales AS
SELECT 
    DATE(o.order_purchase_timestamp) AS order_date,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS order_month,
    TO_CHAR(o.order_purchase_timestamp, 'Mon') AS month_name,
    EXTRACT(QUARTER FROM o.order_purchase_timestamp) AS order_quarter,
    TO_CHAR(o.order_purchase_timestamp, 'Day') AS day_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT oi.order_item_sequence) AS total_items,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(oi.freight_value)::NUMERIC, 2) AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_gross_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_item_price,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    COUNT(DISTINCT op.payment_type) AS payment_methods_used
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN order_payments op ON o.order_id = op.order_id
GROUP BY DATE(o.order_purchase_timestamp)
ORDER BY order_date DESC;

-- ============================================================================

-- VIEW 4: Order Delivery Analysis
-- Purpose: Delivery metrics, status, and variance tracking
CREATE VIEW v_order_delivery AS
SELECT 
    o.order_id,
    o.customer_id,
    DATE(o.order_purchase_timestamp) AS order_date,
    o.order_status,
    DATE(o.order_delivered_customer_date) AS delivery_date,
    CAST((o.order_delivered_customer_date::DATE - o.order_purchase_timestamp::DATE) AS INT) AS delivery_days,
    CAST((o.order_estimated_delivery_date::DATE - o.order_delivered_customer_date::DATE) AS INT) AS delivery_variance_days,
    CASE 
        WHEN o.order_delivered_customer_date IS NULL THEN 'Not Delivered'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS order_total,
    COUNT(oi.order_item_sequence) AS items_in_order,
    or2.review_score
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY o.order_id, o.customer_id, o.order_purchase_timestamp, o.order_status, 
         o.order_delivered_customer_date, o.order_estimated_delivery_date, or2.review_score
ORDER BY order_date DESC;

-- ============================================================================

-- VIEW 5: Seller Performance
-- Purpose: Seller-level KPIs with revenue and ratings
CREATE VIEW v_seller_performance AS
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT oi.order_item_sequence) AS total_items_sold,
    ROUND(SUM(oi.price)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(oi.freight_value)::NUMERIC, 2) AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_gross_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2) AS avg_item_price,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_review_score,
    COUNT(DISTINCT or2.review_id) AS total_reviews,
    ROUND((CAST(SUM(CASE WHEN or2.review_score >= 4 THEN 1 ELSE 0 END) AS NUMERIC) 
           / NULLIF(COUNT(DISTINCT or2.review_id), 0) * 100)::NUMERIC, 2) AS positive_review_pct
FROM sellers s
LEFT JOIN order_items oi ON s.seller_id = oi.seller_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC;

-- ============================================================================

-- VIEW 6: Customer Behavior & Lifetime Value
-- Purpose: Customer-level metrics for CLV and segmentation
CREATE VIEW v_customer_behavior AS
SELECT 
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_spent,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2) AS avg_order_value,
    MIN(DATE(o.order_purchase_timestamp)) AS first_order_date,
    MAX(DATE(o.order_purchase_timestamp)) AS last_order_date,
    CAST((MAX(DATE(o.order_purchase_timestamp)) - MIN(DATE(o.order_purchase_timestamp))) AS INT) AS customer_lifetime_days,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_review_score,
    COUNT(DISTINCT or2.review_id) AS total_reviews
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN order_reviews or2 ON o.order_id = or2.order_id
GROUP BY c.customer_id, c.customer_unique_id, c.customer_city, c.customer_state
ORDER BY total_spent DESC;

-- ============================================================================

-- VIEW 7: Review & Satisfaction Analysis
-- Purpose: Review trends and satisfaction metrics over time
CREATE VIEW v_review_analysis AS
SELECT 
    DATE(or2.review_creation_date) AS review_date,
    EXTRACT(MONTH FROM or2.review_creation_date) AS review_month,
    EXTRACT(YEAR FROM or2.review_creation_date) AS review_year,
    or2.review_score,
    COUNT(DISTINCT or2.review_id) AS review_count,
    COUNT(DISTINCT CASE WHEN or2.review_comment_message IS NOT NULL THEN or2.review_id END) AS comments_count,
    ROUND(AVG(or2.review_score)::NUMERIC, 2) AS avg_score
FROM order_reviews or2
GROUP BY DATE(or2.review_creation_date), review_month, review_year, or2.review_score
ORDER BY review_date DESC;

-- ============================================================================

-- VIEW 8: Payment Method Analysis
-- Purpose: Payment type adoption and order value by payment method
CREATE VIEW v_payment_analysis AS
SELECT 
    op.payment_type,
    COUNT(DISTINCT op.order_id) AS total_orders,
    ROUND(SUM(op.payment_value)::NUMERIC, 2) AS total_payment_value,
    ROUND(AVG(op.payment_value)::NUMERIC, 2) AS avg_payment_value,
    ROUND(AVG(op.payment_installments)::NUMERIC, 2) AS avg_installments,
    ROUND((COUNT(DISTINCT op.order_id)::NUMERIC / (SELECT COUNT(DISTINCT order_id) FROM order_payments) * 100)::NUMERIC, 2) AS payment_type_pct
FROM order_payments op
GROUP BY op.payment_type
ORDER BY total_orders DESC;

-- ============================================================================
-- Verify all views created
-- Run: SELECT * FROM information_schema.views WHERE table_schema = 'public';
-- ============================================================================