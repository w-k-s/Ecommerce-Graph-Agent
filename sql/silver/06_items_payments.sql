CREATE OR REPLACE TABLE silver.order_items AS
SELECT 
  order_id,
  SAFE_CAST(order_item_id AS INT64) AS order_item_id,
  product_id,
  seller_id,
  SAFE_CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
  SAFE_CAST(price AS NUMERIC) AS price,
  SAFE_CAST(freight_value AS NUMERIC) AS freight_value
FROM bronze.order_items;

CREATE OR REPLACE TABLE silver.order_payments AS
SELECT 
  order_id,
  SAFE_CAST(payment_sequential AS INT) AS payment_sequential,
  NULLIF(TRIM(payment_type),'not_defined') AS payment_type,
  SAFE_CAST(payment_installments AS INT) AS payment_installments,
  SAFE_CAST(payment_value AS NUMERIC) AS payment_value,
FROM bronze.order_payments;
