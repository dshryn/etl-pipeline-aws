DROP TABLE IF EXISTS flight_data.flight_gold_route_summary;

CREATE TABLE flight_data.flight_gold_route_summary
WITH (
  external_location = 's3://ys-flight-data-gold/aggregated/route_summary/',
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  partitioned_by = ARRAY['year']
) AS
SELECT
  origin,
  destination,
  COUNT(*) AS flights,
  AVG(arr_delay_minutes) AS avg_arr_delay,
  SUM(CASE WHEN is_delayed=1 THEN 1 ELSE 0 END) AS delayed_count,
  year
FROM flight_data.flight_gold_ml_ready
GROUP BY origin, destination, year;
