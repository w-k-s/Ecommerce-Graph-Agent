CREATE OR REPLACE TABLE silver.orders AS
WITH typed AS (
    SELECT 
        order_id,
        customer_id,
        order_status,
        SAFE_CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
        SAFE_CAST(order_approved_at AS TIMESTAMP) AS order_approved_at,
        SAFE_CAST(order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
        SAFE_CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
        SAFE_CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date
    FROM bronze.orders
)
SELECT (
    *,
    TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS delivery_days,
    (order_delivered_customer_date > order_estimated_delivery_date) AS is_late
)
FROM typed;