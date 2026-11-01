-- Customers
CREATE OR REPLACE TABLE gold.node_customer AS 
SELECT
    c.customer_unique_id AS customer_id,
    ANY_VALUE(c.customer_city) AS city,
    ANY_VALUE(c.customer_state) AS state,
    MIN(o.order_purchase_timestamp) AS first_purchase_at
FROM silver.customers c
LEFT JOIN silver.orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;


-- Purchases
CREATE OR REPLACE TABLE gold.node_purchase AS 
SELECT
    o.order_id AS order_id,
    o.order_status AS order_status,
    o.order_purchase_timestamp AS purchased_at,
    o.delivery_days AS delivery_days,
    o.is_late AS is_late,
    t.total_paid AS total_paid
FROM silver.orders o
LEFT JOIN (
    SELECT order_id, SUM(payment_value) AS total_paid
    FROM silver.order_payments
    GROUP BY order_id
) AS t ON t.order_id = o.order_id;

-- Products
CREATE OR REPLACE TABLE gold.node_product AS 
SELECT 
    p.product_id AS product_id,
    p.category_en AS category,
    p.product_weight AS weight_g,
    p.product_photos_qty AS photos_qty
FROM silver.products p;

-- Sellers
CREATE OR REPLACE TABLE gold.node_seller AS 
SELECT
    s.seller_id AS seller_id,
    s.seller_city AS city,
    s.seller_state AS state
FROM silver.sellers s;

-- Categories
CREATE OR REPLACE TABLE gold.node_category AS 
SELECT DISTINCT category_en AS category FROM silver.products;

-- Reviews
CREATE OR REPLACE TABLE gold.node_review AS 
SELECT
    r.review_id AS review_id,
    r.review_score AS score,
    r.review_comment_message AS message_pt,
    r.review_creation_date AS created_at
FROM silver.reviews r;

-- States
CREATE OR REPLACE TABLE `gold.node_state` AS
SELECT customer_state AS state FROM `silver.customers`
UNION DISTINCT
SELECT seller_state FROM `silver.sellers`;
