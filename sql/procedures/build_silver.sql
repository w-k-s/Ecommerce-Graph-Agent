CREATE OR REPLACE PROCEDURE pipeline.build_silver() 
BEGIN 
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
    SELECT 
        *,
        TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS delivery_days,
        (order_delivered_customer_date > order_estimated_delivery_date) AS is_late
    FROM typed;


    CREATE OR REPLACE TABLE silver.reviews AS 
    SELECT 
    review_id, 
    order_id, 
    NULLIF(TRIM(review_comment_title),'') AS review_comment_title,
    NULLIF(TRIM(review_comment_message),'') AS review_comment_message,
    SAFE_CAST(review_score AS INT64) AS review_score,
    SAFE_CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
    SAFE_CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp,   
    ROW_NUMBER() OVER (
        PARTITION BY review_id, order_id
        ORDER BY SAFE_CAST(review_answer_timestamp AS TIMESTAMP) DESC
    ) AS rn
    FROM bronze.order_reviews
    QUALIFY rn  = 1
    ORDER BY review_id ASC;

    CREATE OR REPLACE FUNCTION silver.clean_city(x STRING)
    RETURNS STRING
    AS (
        NULLIF(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
                NORMALIZE(TRIM(LOWER(x)), NFD), 
            r'\p{M}', 
            ''),
            r'\s+',
            ' '),
        r"[^a-z0-9]'",
        ' '),
        '')
    );

    CREATE OR REPLACE TABLE silver.customers AS 
    SELECT 
    customer_id,
    customer_unique_id,
    LPAD(TRIM(customer_zip_code_prefix), 5,'0') AS customer_zip_code_prefix,
    silver.clean_city(customer_city) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
    FROM bronze.customers;

    CREATE OR REPLACE TABLE silver.sellers AS 
    SELECT 
    seller_id,
    LPAD(TRIM(seller_zip_code_prefix), 5,'0') AS seller_zip_code_prefix,
    silver.clean_city(seller_city) AS seller_city,
    UPPER(TRIM(seller_state)) AS seller_state
    FROM bronze.sellers;

    CREATE OR REPLACE TABLE silver.geolocation AS 
    WITH points AS ( 
    SELECT 
        SAFE_CAST(geolocation_lat AS FLOAT64) AS lat,
        SAFE_CAST(geolocation_lng AS FLOAT64) AS lng,
        LPAD(TRIM(geolocation_zip_code_prefix), 5,'0') AS zip_code_prefix,
        silver.clean_city(geolocation_city) AS city,
        UPPER(TRIM(geolocation_state)) AS state
    FROM bronze.geolocation
    )
    SELECT 
    points.zip_code_prefix AS zip_code_prefix, 
    AVG(lat) AS lat,
    AVG(lng) AS lng,
    APPROX_TOP_COUNT(city, 1)[OFFSET(0)].value  AS city,
    APPROX_TOP_COUNT(state, 1)[OFFSET(0)].value AS state,
    COUNT(*) AS n_points,
    FROM points
    WHERE points.lat BETWEEN -33.75 AND 5.27
    AND points.lng BETWEEN -73.99 AND -34.79 
    GROUP BY points.zip_code_prefix;

    CREATE OR REPLACE TABLE silver.products AS
    SELECT 
    product_id,
    p.product_category_name AS category_pt,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category_en,
    SAFE_CAST(product_name_lenght AS INT) AS  product_name_length,
    SAFE_CAST(product_description_lenght AS INT) AS product_description_length,
    SAFE_CAST(product_photos_qty AS INT) AS product_photos_qty,
    SAFE_CAST(product_weight_g AS INT) AS product_weight,
    SAFE_CAST(product_length_cm AS INT) AS product_length_cm,
    SAFE_CAST(product_height_cm AS INT) AS product_height_cm,
    SAFE_CAST(product_width_cm AS INT) AS product_width_cm
    FROM bronze.products AS p
    LEFT JOIN bronze.product_category_name_translation t ON p.product_category_name = t.product_category_name;

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
END;