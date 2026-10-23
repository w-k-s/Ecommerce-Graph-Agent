import pytest

from olist.text import normalize_city


@pytest.mark.parametrize(
    "name, expected",
    [("São Paulo", "sao paulo"), (" RIO  de Janeiro ", "rio de janeiro"), (None, None)],
)
def test_normalize_city(name, expected):
    assert normalize_city(name) == expected
