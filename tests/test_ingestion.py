import pytest

from olist.ingestion import table_name_for


@pytest.mark.parametrize(
    "filename, expected",
    [
        ("olist_customers_dataset.csv", "customers"),
        ("olist_geolocation_dataset.csv", "geolocation"),
        ("olist_order_items_dataset.csv", "order_items"),
        ("olist_order_payments_dataset.csv", "order_payments"),
        ("olist_order_reviews_dataset.csv", "order_reviews"),
        ("olist_orders_dataset.csv", "orders"),
        ("olist_products_dataset.csv", "products"),
        ("olist_sellers_dataset.csv", "sellers"),
        ("product_category_name_translation.csv", "product_category_name_translation"),
    ],
)
def test_table_name_for(filename, expected):
    assert table_name_for(filename) == expected
