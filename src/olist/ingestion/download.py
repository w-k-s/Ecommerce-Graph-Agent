from pathlib import Path

from kaggle.api.kaggle_api_extended import KaggleApi

DATASET = "olistbr/brazilian-ecommerce"


def download(dest=Path("data/raw")):

    dest.mkdir(parents=True, exist_ok=True)

    kaggle = KaggleApi()
    kaggle.authenticate()
    kaggle.dataset_download_files(dataset=DATASET, path=dest, unzip=True, force=True)
    return sorted(dest.glob("*.csv"))
