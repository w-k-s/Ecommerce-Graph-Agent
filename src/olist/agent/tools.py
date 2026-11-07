from google.cloud.bigquery import QueryJobConfig
from google.api_core.exceptions import BadRequest
from langchain_core.tools import tool
from olist.bq import client

MAX_BYTES = 1_000_000_000
FORBIDDEN_WORDS = [
    "CREATE ",
    "INSERT ",
    "DELETE ",
    "TRUNCATE ",
    "MERGE ",
    "UPDATE ",
    "DROP ",
    "ALTER ",
]


@tool
def run_gql(query: str) -> str:
    """Run a read-only GQL query against gold.olist_graph and return up to
    50 rows as CSV. Returns a message starting with ERROR if the query is
    invalid; fix the query and call again."""

    if not query.startswith("GRAPH "):
        return "Invalid graph query. Graph query must start with GRAPH followed by graph name"

    if any(word.lower() in query.lower() for word in FORBIDDEN_WORDS):
        return "Read-only queries are permitted"

    _client = client()
    try:
        _client.query(
            query=query, job_config=QueryJobConfig(dry_run=True, use_query_cache=False)
        ).result()
    except BadRequest as e:
        return f"Exception occured with running query. Details: {e.message}"

    job = _client.query(
        query, job_config=QueryJobConfig(maximum_bytes_billed=MAX_BYTES)
    ).result()

    df = job.to_dataframe().head(50)
    return df.to_csv(index=False) if len(df) else "The query returned no rows."
