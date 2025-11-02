DROP TABLE IF EXISTS flight_data.flight_silver_parquet;

CREATE TABLE flight_data.flight_silver_parquet
WITH (
  external_location = 's3://ys-flight-data-gold/silver_parquet/',
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  partitioned_by = ARRAY['year','month']
) AS
WITH parsed AS (
  SELECT
    *,
    COALESCE(
      TRY(date_parse(FlightDate, '%d-%m-%Y')),
      TRY(date_parse(FlightDate, '%Y-%m-%d')),
      TRY(from_iso8601_date(FlightDate))
    ) AS flight_date_ts
  FROM flight_data.flight_bronze_raw
)
SELECT
  CAST(flight_date_ts AS timestamp)                                       AS flight_date,
  Operating_Airline                                                       AS operating_carrier,
  IATA_Code_Marketing_Airline                                             AS carrier,
  Origin                                                                   AS origin,
  Dest                                                                     AS destination,
  TRY_CAST(Distance AS DOUBLE)                                             AS distance,
  TRY_CAST(DepDelayMinutes AS DOUBLE)                                      AS dep_delay_minutes,
  TRY_CAST(ArrDelayMinutes AS DOUBLE)                                      AS arr_delay_minutes,
  CASE WHEN TRY_CAST(ArrDelayMinutes AS DOUBLE) > 15 THEN 1 ELSE 0 END      AS is_delayed,
  Tail_Number                                                              AS tail_number,
  CRSDepTime                                                               AS crs_dep_time,
  CRSArrTime                                                               AS crs_arr_time,
  year(flight_date_ts)                                                     AS year,
  month(flight_date_ts)                                                    AS month
FROM parsed
WHERE flight_date_ts IS NOT NULL;
