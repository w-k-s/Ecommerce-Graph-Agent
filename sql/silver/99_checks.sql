-- 1. silver.orders has the same row count as bronze.orders.
ASSERT (SELECT COUNT(*) FROM bronze.orders) = (SELECT COUNT(*) FROM silver.orders) AS 'silver.orders count != bronze.orders count';

-- 2. order_id is unique in silver.orders; your review key from 4.2 is unique in silver.reviews; zip_code_prefix is unique in silver.geolocation.
ASSERT (SELECT COUNT(DISTINCT order_id) FROM silver.orders) = (SELECT COUNT(*) FROM silver.orders) AS 'order_ids are not unqiue';
ASSERT NOT EXISTS (
  SELECT 1 FROM silver.reviews
  GROUP BY review_id, order_id
  HAVING COUNT(*) > 1
) AS '(review_id, order_id) is not unique in silver.reviews';
ASSERT (SELECT COUNT(DISTINCT zip_code_prefix) FROM silver.geolocation) = (SELECT COUNT(*) FROM silver.geolocation) AS 'zip_code_prefixes are not unique';

-- 3. Every order's customer_id exists in silver.customers.
ASSERT NOT EXISTS (
    SELECT 1 FROM silver.orders o
    LEFT JOIN silver.customers c 
    ON o.customer_id = c.customer_id
    WHERE c.customer_id IS NULL
) AS 'some orders have customers that dont exist';

-- 4. Every order item's product_id exists in silver.products, and every seller_id in silver.sellers.
ASSERT NOT EXISTS (
    SELECT 1 FROM silver.order_items o
    LEFT JOIN silver.products p
    ON o.product_id = p.product_id
    WHERE p.product_id IS NULL
) AS 'some order items have products that dont exist';

ASSERT NOT EXISTS (
    SELECT 1 FROM silver.order_items o
    LEFT JOIN silver.sellers s 
    ON o.seller_id = s.seller_id
    WHERE s.seller_id IS NULL
) AS 'some order items have sellers that dont exist';

-- 5. Every review_score is between 1 and 5.
ASSERT NOT EXISTS (
    SELECT 1 FROM silver.reviews
    WHERE (review_score IS NULL) OR (review_score NOT BETWEEN 1 AND 5)
) AS 'reviews must be between 1 and 5';

-- 6. No order has a NULL purchase timestamp
ASSERT NOT EXISTS (
    SELECT 1 FROM silver.orders 
    WHERE order_purchase_timestamp IS NULL
) AS 'some orders have a null purchase timestamp';