# src/olist/agent/schema.py
from olist import bq
from olist.config import settings

NODES = {
    "node_customer": "Customer",
    "node_purchase": "Purchase",
    "node_product": "Product",
    "node_seller": "Seller",
    "node_category": "Category",
    "node_review": "Review",
    "node_state": "State",
}
EDGES = {
    "edge_placed": "(Customer)-[:PLACED]->(Purchase)",
    "edge_contains": "(Purchase)-[:CONTAINS]->(Product)",
    "edge_fulfilled": "(Seller)-[:FULFILLED]->(Purchase)",
    "edge_sells": "(Seller)-[:SELLS]->(Product)",
    "edge_in_category": "(Product)-[:IN_CATEGORY]->(Category)",
    "edge_has_review": "(Purchase)-[:HAS_REVIEW]->(Review)",
    "edge_lives_in": "(Customer)-[:LIVES_IN]->(State)",
    "edge_based_in": "(Seller)-[:BASED_IN]->(State)",
}


def graph_schema_text() -> str:
    cols = bq.read_df(f"""
        SELECT table_name, column_name
        FROM `{settings.project_id}.gold.INFORMATION_SCHEMA.COLUMNS`
        WHERE table_name LIKE 'node_%' OR table_name LIKE 'edge_%'
        ORDER BY table_name, ordinal_position
    """)
    by_table = cols.groupby("table_name")["column_name"].apply(list).to_dict()

    lines = ["Node labels and their properties:"]
    for table, label in NODES.items():
        lines.append(f"- {label}: {', '.join(by_table.get(table, []))}")
    lines.append("\nEdges (direction matters) and their properties:")
    for table, pattern in EDGES.items():
        lines.append(f"- {pattern}: {', '.join(by_table.get(table, []))}")
    return "\n".join(lines)
