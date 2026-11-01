-- 1. Placed
CREATE OR REPLACE TABLE gold.edge_placed AS
SELECT 
    DISTINCT c.customer_unique_id AS customer_id, -- distinct combination of customer and order
    o.order_id AS order_id
FROM silver.orders o
JOIN silver.customers c ON o.customer_id = c.customer_id;

-- 2. Contains
CREATE OR REPLACE TABLE gold.edge_contains AS 
SELECT 
    order_id, 
    product_id,
    COUNT(*) AS quantity, 
    SUM(price) AS total_price ,
    SUM(freight_value) AS total_freight
FROM silver.order_items
GROUP BY order_id, product_id;

-- 3. Fulfilled
CREATE OR REPLACE TABLE gold.edge_fulfilled AS 
SELECT DISTINCT
    order_id, 
    seller_id
FROM silver.order_items;

-- 4. Sells
CREATE OR REPLACE TABLE gold.edge_sells AS 
SELECT DISTINCT seller_id, product_id FROM silver.order_items;

-- 5. In Category
CREATE OR REPLACE TABLE gold.edge_in_category AS
SELECT product_id, category_en AS category FROM silver.products;

-- 6. Has Review
CREATE OR REPLACE TABLE `gold.edge_has_review` AS
SELECT r.order_id, r.review_id
FROM `silver.reviews` r
INNER JOIN `silver.orders` o ON r.order_id = o.order_id; -- inner join to filter out orders without reviews (avoids dangling edges).

-- 7. Lives In
CREATE OR REPLACE TABLE gold.edge_lives_in AS 
SELECT customer_id, state FROM gold.node_customer; -- gold.node_customer has 1 row per customer whereas silver.customers does not.

-- 8. Based In
CREATE OR REPLACE TABLE gold.edge_based_in AS 
SELECT seller_id, state FROM gold.node_seller; -- for sellers, we could even use silver.sellers since no duplicate seller_id.
