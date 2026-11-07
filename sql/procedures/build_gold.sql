CREATE OR REPLACE PROCEDURE pipeline.build_gold() 
BEGIN
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

    CREATE OR REPLACE PROPERTY GRAPH gold.olist_graph
    NODE TABLES (
        gold.node_customer AS node_customer KEY (customer_id) LABEL Customer,
        gold.node_seller AS node_seller KEY (seller_id) LABEL Seller,
        gold.node_state AS node_state KEY (state) LABEL State,
        gold.node_purchase AS node_purchase KEY (order_id) LABEL Purchase,
        gold.node_product AS node_product KEY (product_id) LABEL Product,
        gold.node_category AS node_category KEY (category) LABEL Category,
        gold.node_review AS node_review KEY (review_id) LABEL Review
    )
    EDGE TABLES (
        gold.edge_placed AS placed KEY (customer_id, order_id)
        SOURCE KEY (customer_id) REFERENCES node_customer (customer_id)
        DESTINATION KEY (order_id) REFERENCES node_purchase (order_id)
        LABEL PLACED,
        gold.edge_contains AS order_contains KEY (order_id, product_id)
        SOURCE KEY (order_id) REFERENCES node_purchase (order_id)
        DESTINATION KEY (product_id) REFERENCES node_product (product_id)
        LABEL ORDER_CONTAINS,
        gold.edge_fulfilled AS fulfilled KEY (seller_id, order_id)
        SOURCE KEY (seller_id) REFERENCES node_seller (seller_id)
        DESTINATION KEY (order_id) REFERENCES node_purchase (order_id)
        LABEL FULFILLED,
        gold.edge_has_review AS has_review KEY (order_id, review_id)
        SOURCE KEY (order_id) REFERENCES node_purchase (order_id)
        DESTINATION KEY (review_id) REFERENCES node_review (review_id)
        LABEL HAS_REVIEW,
        gold.edge_lives_in AS lives_in KEY (customer_id, state)
        SOURCE KEY (customer_id) REFERENCES node_customer (customer_id)
        DESTINATION KEY (state) REFERENCES node_state (state)
        LABEL LIVES_IN,
        gold.edge_based_in AS based_in KEY (seller_id, state)
        SOURCE KEY (seller_id) REFERENCES node_seller (seller_id)
        DESTINATION KEY (state) REFERENCES node_state (state)
        LABEL BASED_IN,
        gold.edge_sells AS sells KEY (seller_id, product_id)
        SOURCE KEY (seller_id) REFERENCES node_seller (seller_id)
        DESTINATION KEY (product_id) REFERENCES node_product (product_id)
        LABEL SELLS,
        gold.edge_in_category AS in_category KEY (product_id, category)
        SOURCE KEY (product_id) REFERENCES node_product (product_id)
        DESTINATION KEY (category) REFERENCES node_category (category)
        LABEL IN_CATEGORY
    );
END;