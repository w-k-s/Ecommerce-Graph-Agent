import datetime as dt
import logging
from io import BytesIO
from pathlib import Path

import pandas as pd
from google.cloud import storage

from olist.bq import client, write_df
from olist.config import settings
from olist.ingestion import table_name_for

CHUNK_SIZE = 5 * 1024 * 1024

logger = logging.getLogger(__name__)


def upload_to_landing(paths: list[Path], run_date: str | None = None) -> list[str]:
    client = storage.Client()
    bucket = client.bucket(settings.landing_bucket)
    run_date = run_date or dt.datetime.now(dt.UTC).date().isoformat()
    uris = []
    for path in paths:
        blob_name = f"olist/{run_date}/{path.name}"
        blob = bucket.blob(blob_name=blob_name, chunk_size=CHUNK_SIZE)
        if blob.exists():
            logger.info("Already uploaded: %s", blob_name)
        else:
            logger.info("Uploading %s -> gs://%s/%s", path.name, bucket.name, blob_name)
            blob.upload_from_filename(str(path), timeout=300)
        uris.append(f"gs://{settings.landing_bucket}/{blob_name}")
    return uris


def load_to_bronze(storage_uri: str) -> None:
    assert storage_uri is not None

    client = storage.Client()
    bucket = client.get_bucket(settings.landing_bucket)

    blob_name = storage_uri.removeprefix(f"gs://{settings.landing_bucket}/")

    blob = bucket.blob(blob_name=blob_name)
    bytes_data = blob.download_as_bytes()

    df = pd.read_csv(BytesIO(bytes_data), dtype=str)
    df["_ingested_at"] = pd.Timestamp.now(tz="UTC")
    df["_source_file"] = storage_uri

    table_name = table_name_for(blob_name)
    table_id = f"bronze.{table_name}"
    write_df(df, table_id=table_id)

    check_row_count(df, table_id=table_id)


def check_row_count(df, table_id):
    df_row_count = len(df)
    table_row_count = client().get_table(table_id).num_rows

    if table_row_count is None:
        raise ValueError("Unable to retrieve table row count")
    if table_row_count != df_row_count:
        raise ValueError(
            f"Dataframe row count '{df_row_count}' does not match table row count '{table_row_count}'"
        )
