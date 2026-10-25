import logging

from olist.ingestion import download, load_to_bronze, upload_to_landing


def main():
    logging.basicConfig(level=logging.INFO)
    paths = download()
    storage_uris = upload_to_landing(paths)
    for uri in storage_uris:
        load_to_bronze(uri)


if __name__ == "__main__":
    main()
