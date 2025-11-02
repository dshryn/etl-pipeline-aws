-- check partitioning
SHOW PARTITIONS flight_data.flight_silver_parquet;

SHOW PARTITIONS flight_data.flight_gold_ml_ready;


-- count by year/month in silver
SELECT year, month, COUNT(*) AS cnt
FROM flight_data.flight_silver_parquet
GROUP BY year, month
ORDER BY year, month;


-- check rows with null flightdate after silver
SELECT COUNT(*) FROM flight_data.flight_silver_parquet WHERE flight_date IS NULL;

