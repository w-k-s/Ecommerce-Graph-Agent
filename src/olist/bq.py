import pandas as pd
from google.cloud import bigquery

from olist.config import settings

_client: bigquery.Client | None = None


def client() -> bigquery.Client:
    global _client
    if _client is None:
        _client = bigquery.Client(
            project=settings.project_id, location=settings.bq_location
        )
    return _client


def run_sql(sql: str) -> None:
    client().query(sql).result()


def read_df(sql: str) -> pd.DataFrame:
    return client().query(sql).to_dataframe()


def write_df(df: pd.DataFrame, table_id: str) -> None:
    client().load_table_from_dataframe(
        dataframe=df,
        destination=table_id,
        job_config=bigquery.LoadJobConfig(write_disposition="WRITE_TRUNCATE"),
    ).result()
