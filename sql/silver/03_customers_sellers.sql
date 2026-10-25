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

