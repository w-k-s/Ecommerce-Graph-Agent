
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