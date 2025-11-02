# End-to-end ETL Data Pipeline on AWS

An ETL pipeline that ingests public flight delay data, implements a medallion architecture for pipelining on AWS, trains a predictive model, and serves predictions via a web interface.

## Project Summary

This project ingests public flight delay CSV data (2018–2024), implements a medallion pipeline (Bronze -> Silver -> Gold), trains a classifier predicting flight delay probability, exposes the trained model via a FastAPI service inside Docker, and serves a small frontend (single-page HTML with Chart.js) via nginx reverse-proxying to the API.
The gold layer data is also visualized using PowerBI through ODBC Driver, connecting Athena to local PowerBI.

**Main Goals:**
- Clean and partition the raw dataset for fast querying (Athena + Parquet)
- Build aggregated gold tables used for dashboards and ML features
- Train a lightweight XGBoost model and store the model artifacts in S3
- Visualize gold layer data on PowerBI
- Serve predictions with a reproducible Docker+nginx deployment
  

## Architecture

![Architecture Diagram](/architecture-overview.png)

**Components:**
- **Data Storage**: Amazon S3 (medallion buckets: Bronze, Silver, Gold)
- **Query Engine**: Amazon Athena (CTAS / UNLOAD / SQL)
- **ML Training**: SageMaker notebook or local Jupyter on EC2
- **Serving**: EC2 instance running Docker + FastAPI + XGBoost
- **Frontend**: nginx serving static HTML with chart feature
- **Visualization**: PowerBI dashboard based on gold summary tables
- **IAM**: IAM users/roles with S3 & Athena permissions

## Step-by-Step Workflow (Exact Sequence to Reproduce, High-Level)

1. **Upload Raw Data**: Place CSV in `s3://ys-flight-data-bronze/raw/flight-delay-2018-2024.csv`
2. **Create Athena Database**: Execute `CREATE DATABASE flight_data`
3. **Create Bronze Table**: Run `/athena/bronze_create.sql`
4. **Data Validation**: Execute sample queries to verify data quality
5. **Create Silver Layer**: Execute `/athena/silver_ctas.sql`
6. **Create Gold ML-ready Table**: Execute `/athena/gold_ml_ready_ctas.sql`
7. **Create Aggregated Tables**: Execute airline and route summary CTAS queries
8. **Export for ML**: Use UNLOAD statements to create training datasets
9. **Model Training**: Run `/notebooks/flight_ml_notebook.ipynb`
10. **Deploy API**: Build Docker image and run container on EC2
11. **Configure Frontend**: Set up nginx with static files and reverse proxy
12. **Testing**: Validate predictions and dashboard functionality
13. **Data Visualization**: Connect PowerBI to Athena using ODBC driver to load final gold tables

## Deployment & Runtime

**EC2 Instance:** `flight-delay-api` (t3.micro)
- Docker container running FastAPI on port 8000
- nginx serving frontend and reverse-proxying API calls
- IAM role with S3 read access for model loading

**SageMaker Notebook:** `flight-ml-notebook` (optional, for training)

**Athena Workgroup:** Results location set to `s3://ys-flight-data-gold/query-results/`

## Troubleshooting & Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `HIVE_COLUMN_ORDER_MISMATCH` | Partition keys not last in CTAS | Ensure partition columns are last in SELECT |
| `HIVE_PATH_ALREADY_EXISTS` | Target S3 path exists | Remove existing folder or use new path |
| `HIVE_TOO_MANY_OPEN_PARTITIONS` | Too many partitions in one CTAS | Reduce partition count or write in batches |
| `INVALID_FUNCTION_ARGUMENT` | Mixed date formats in CSV | Use TRY()/TRY_PARSE in Athena queries |
| `ArrowInvalid: outside base dir` | PyArrow S3 path format issue | Use consistent S3 URI formats |
| AWS Permission Denied | IAM policies missing | Attach required S3+Athena policies |


## Costs & Free-Tier Recommendations

- Use `t3.micro` EC2 instances for development
- Configure S3 lifecycle policies to archive/delete old data
- Stop SageMaker notebook instances when not in use
- Use Athena only for necessary queries (cost per TB scanned)
- Consider AWS Free Tier limits for new accounts

## What's Done, What's Remaining, Next Steps

**Completed:**
- End-to-end medallion pipeline implementation
- XGBoost model training and evaluation
- FastAPI service with Docker deployment
- Frontend with prediction interface
- Basic PowerBI dashboard integration

**Next Steps:**
- Add automated model retraining pipeline
- Implement CI/CD for API deployment
- Add monitoring and logging
- Expand frontend with more visualizations

## Where to Find Artifacts and Important Assets

- **SQL Scripts**: `/athena/` (bronze/silver/gold CTAS + UNLOAD + insight queries)
- **Notebook**: `/notebooks/flight_ml_notebook.ipynb`
- **API Source**: `/api/`
- **Frontend**: `/fe/index.html`
- **nginx Config**: `/nginx/flight-api.conf`
- **Models**: `s3://ys-flight-data-gold/models/` (xgb_flight_delay.json, label_encoders.pkl)
- **Athena Results**: `s3://ys-flight-data-gold/query-results/`

## Credits

**Dataset:** Kaggle "Flight delay dataset (2018–2024)" - https://www.kaggle.com/datasets/shubhamsingh42/flight-delay-dataset-2018-2024/data

**Code & Implementation:** Developed as part of this end-to-end pipeline.

---

## Final Note

This repository contains all the canonical queries and code used in production. Keep the `/athena/` SQL files updated as the source of truth for table creation, and maintain the notebook reproducibility.