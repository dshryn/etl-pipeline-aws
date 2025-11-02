DROP TABLE IF EXISTS flight_data.flight_gold_ml_ready;

CREATE TABLE flight_data.flight_gold_ml_ready
WITH (
  external_location = 's3://ys-flight-data-gold/ml-ready/',
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  partitioned_by = ARRAY['year']
) AS
WITH base AS (
  SELECT
    flight_date,
    carrier,
    operating_carrier,
    origin,
    destination,
    distance,
    dep_delay_minutes,
    arr_delay_minutes,
    is_delayed,
    day_of_week(cast(flight_date AS date)) AS day_of_week,
    CASE
      WHEN month(cast(flight_date AS date)) IN (12,1,2) THEN 'Winter'
      WHEN month(cast(flight_date AS date)) IN (3,4,5) THEN 'Spring'
      WHEN month(cast(flight_date AS date)) IN (6,7,8) THEN 'Summer'
      ELSE 'Autumn'
    END AS season,
    month(cast(flight_date AS date)) AS month,
    year(cast(flight_date AS date))  AS year
  FROM flight_data.flight_silver_parquet
)
SELECT
  flight_date,
  carrier,
  operating_carrier,
  origin,
  destination,
  distance,
  dep_delay_minutes,
  arr_delay_minutes,
  is_delayed,
  day_of_week,
  season,
  month,
  year
FROM base
WHERE flight_date IS NOT NULL;
