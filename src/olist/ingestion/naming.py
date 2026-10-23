from pathlib import Path


def table_name_for(path: Path | str) -> str:
    if isinstance(path, str):
        path = Path(path)
    file_name = path.stem
    return file_name.removeprefix("olist_").removesuffix("_dataset")
