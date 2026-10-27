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
