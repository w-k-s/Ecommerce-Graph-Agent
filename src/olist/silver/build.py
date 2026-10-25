import logging
from pathlib import Path

from olist.bq import client

logger = logging.getLogger(__name__)

SQL_DIR = "./sql/silver"


def build_silver(sql_dir: Path | str = Path("sql/silver")) -> None:
    if isinstance(sql_dir, str):
        sql_dir = Path(sql_dir)
    for path in sorted(sql_dir.glob("*.sql")):
        logger.info("Running %s", path.name)
        sql = path.read_text()
        client().query(sql).result()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    build_silver()
