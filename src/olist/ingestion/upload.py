import datetime as dt
from pathlib import Path

from google.cloud import storage

from olist.config import settings


def upload_to_landing(paths: list[Path], run_date: str | None) -> list[str]:
    client = storage.Client()
    bucket = client.get_bucket(settings.landing_bucket)
    run_date = run_date or dt.datetime.now(dt.UTC).today().isoformat()
    uris = []
    for path in paths:
        blob_name = f"olist/{run_date}/{path.name}"
        blob = bucket.blob(blob_name=blob_name)
        blob.upload_from_filename(str(path))
        uris.append(f"gs://{settings.landing_bucket}/{blob_name}")
    return uris
