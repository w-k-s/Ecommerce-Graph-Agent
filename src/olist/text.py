import re

from unidecode import unidecode


def normalize_city(name: str) -> str | None:
    if name is None:
        return None
    result = unidecode(name).lower().strip()
    return re.sub(r"\s+", " ", result)
