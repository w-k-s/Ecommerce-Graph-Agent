CREATE OR REPLACE TABLE silver.products AS
SELECT 
  product_id,
  p.product_category_name AS category_pt,
  COALESCE(t.product_category_name_english, p.product_category_name) AS category_en,
  SAFE_CAST(product_name_lenght AS INT) AS  product_name_length,
  SAFE_CAST(product_description_lenght AS INT) AS product_description_length,
  SAFE_CAST(product_photos_qty AS INT) AS product_photos_qty,
  SAFE_CAST(product_weight_g AS INT) AS product_weight,
  SAFE_CAST(product_length_cm AS INT) AS product_length_cm,
  SAFE_CAST(product_height_cm AS INT) AS product_height_cm,
  SAFE_CAST(product_width_cm AS INT) AS product_width_cm
FROM bronze.products AS p
LEFT JOIN bronze.product_category_name_translation t ON p.product_category_name = t.product_category_name;