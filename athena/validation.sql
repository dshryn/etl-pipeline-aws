-- bronze csv

SELECT * FROM flight_data.flight_bronze_raw LIMIT 5;

SELECT COUNT(*) FROM flight_data.flight_bronze_raw;

-- check date parse candidates
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN TRY(date_parse(FlightDate, '%d-%m-%Y')) IS NOT NULL THEN 1 ELSE 0 END) AS dd_mm_yyyy_rows
FROM flight_data.flight_bronze_raw;

-- search for flight date values that fail common parsers
SELECT FlightDate, COUNT(*) AS cnt
FROM flight_data.flight_bronze_raw
WHERE TRY(date_parse(FlightDate, '%d-%m-%Y')) IS NULL
  AND TRY(date_parse(FlightDate, '%Y-%m-%d')) IS NULL
  AND TRY(from_iso8601_date(FlightDate)) IS NULL
GROUP BY FlightDate
ORDER BY cnt DESC
LIMIT 50;




-- silver ctas
SELECT COUNT(*) FROM flight_data.flight_silver_parquet;

SELECT year, month, COUNT(*) FROM flight_data.flight_silver_parquet GROUP BY year, month ORDER BY year, month LIMIT 20;

SELECT * FROM flight_data.flight_silver_parquet LIMIT 5;




-- gold ctas
SELECT COUNT(*) FROM flight_data.flight_gold_ml_ready;

SELECT year, COUNT(*) FROM flight_data.flight_gold_ml_ready GROUP BY year ORDER BY year;

SELECT * FROM flight_data.flight_gold_ml_ready LIMIT 10;

