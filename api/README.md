# Flight Delay Prediction API

This folder contains the FastAPI-based microservice used to serve flight delay predictions using the trained XGBoost model hosted in S3.

---

## Files Overview

| File | Purpose |
|------|----------|
| `app.py` | FastAPI app loading model + encoders from S3 and serving `/predict` |
| `requirements.txt` | Dependencies for the API |
| `Dockerfile` | Container image setup (Python + FastAPI + dependencies) |
| `README.md` | Setup and run instructions |

---

## Building & Running the Container

### 1. Build the Docker Image
```bash
sudo docker build -t flight-delay-api .
```

### 2. Run the Container
```bash
sudo docker run -d --name flight-api -p 8000:8000 flight-delay-api
```

### 3. Check if Running
```bash
sudo docker ps --filter name=flight-api --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
```

### 4. View Logs (Uvicorn startup)
```bash
sudo docker logs -f flight-api
```
## Testing the API

### Using ```curl``` (from EC2)

```bash
curl -s -X POST "http://127.0.0.1:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{"month":1,"day_of_week":1,"season":"Winter","carrier":"UA","operating_carrier":"G7","origin":"EWR","destination":"MHT","distance":1979,"dep_delay_minutes":71}'
```
### Using Browser (if Nginx reverse-proxy enabled)

```bash
http://<EC2-PUBLIC-IP>/docs
```

## Notes

The model artifacts are automatically fetched from:

```bash
s3://ys-flight-data-gold/models/xgb_flight_delay.json
s3://ys-flight-data-gold/models/label_encoders.pkl
```

Docker exposes port ```8000```.

Nginx (frontend) proxies ```/predict → http://127.0.0.1:8000/predict.```

