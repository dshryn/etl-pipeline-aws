from fastapi import FastAPI
from pydantic import BaseModel
import joblib, boto3, os, pandas as pd, xgboost as xgb

S3_BUCKET = "ys-flight-data-gold"
MODEL_KEY = "models/xgb_flight_delay.json"
ENC_KEY   = "models/label_encoders.pkl"
LOCAL_DIR = "/tmp/model_artifacts"

os.makedirs(LOCAL_DIR, exist_ok=True)
s3 = boto3.client("s3")

model_path = os.path.join(LOCAL_DIR, "xgb_flight_delay.json")
enc_path   = os.path.join(LOCAL_DIR, "label_encoders.pkl")

if not os.path.exists(model_path):
    s3.download_file(S3_BUCKET, MODEL_KEY, model_path)
if not os.path.exists(enc_path):
    s3.download_file(S3_BUCKET, ENC_KEY, enc_path)

bst = xgb.Booster()
bst.load_model(model_path)
encoders = joblib.load(enc_path)

app = FastAPI(title="Flight Delay Predictor")

class FlightRow(BaseModel):
    month: int
    day_of_week: int
    season: str
    carrier: str
    operating_carrier: str
    origin: str
    destination: str
    distance: float
    dep_delay_minutes: float

def encode_row(r: FlightRow):
    d = {
        "month": r.month,
        "day_of_week": r.day_of_week,
        "season": encoders.get("season", {}).get(r.season, 0),
        "carrier": encoders.get("carrier", {}).get(r.carrier, 0),
        "operating_carrier": encoders.get("operating_carrier", {}).get(r.operating_carrier, 0),
        "origin": encoders.get("origin", {}).get(r.origin, 0),
        "destination": encoders.get("destination", {}).get(r.destination, 0),
        "distance": r.distance,
        "dep_delay_minutes": r.dep_delay_minutes
    }
    return pd.DataFrame([d])

@app.post("/predict")
def predict(row: FlightRow):
    df = encode_row(row)
    dmat = xgb.DMatrix(df)
    prob = float(bst.predict(dmat)[0])
    pred = 1 if prob > 0.5 else 0
    return {"pred": int(pred), "probability": prob}
