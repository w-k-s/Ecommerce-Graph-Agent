CREATE OR REPLACE PROPERTY GRAPH gold.olist_graph
    NODE TABLES (
        gold.node_customer AS node_customer KEY (customer_id) LABEL Customer,
        gold.node_seller AS node_seller KEY (seller_id) LABEL Seller,
        gold.node_state AS node_state KEY (state) LABEL State,
        gold.node_purchase AS node_purchase KEY (order_id) LABEL Purchase,
        gold.node_product AS node_product KEY (product_id) LABEL Product,
        gold.node_category AS node_category KEY (category) LABEL Category,
        gold.node_review AS node_review KEY (review_id) LABEL Review
    )
    EDGE TABLES (
        gold.edge_placed AS placed KEY (customer_id, order_id)
        SOURCE KEY (customer_id) REFERENCES node_customer (customer_id)
        DESTINATION KEY (order_id) REFERENCES node_purchase (order_id)
        LABEL PLACED,
        gold.edge_contains AS contains KEY (order_id, product_id)
        SOURCE KEY (order_id) REFERENCES node_purchase (order_id)
        DESTINATION KEY (product_id) REFERENCES node_product (product_id)
        LABEL CONTAINS,
        gold.edge_fulfilled AS fulfilled KEY (seller_id, order_id)
        SOURCE KEY (seller_id) REFERENCES node_seller (seller_id)
        DESTINATION KEY (order_id) REFERENCES node_purchase (order_id)
        LABEL FULFILLED,
        gold.edge_has_review AS has_review KEY (order_id, review_id)
        SOURCE KEY (order_id) REFERENCES node_purchase (order_id)
        DESTINATION KEY (review_id) REFERENCES node_review (review_id)
        LABEL HAS_REVIEW,
        gold.edge_lives_in AS lives_in KEY (customer_id, state)
        SOURCE KEY (customer_id) REFERENCES node_customer (customer_id)
        DESTINATION KEY (state) REFERENCES node_state (state)
        LABEL LIVES_IN,
        gold.edge_based_in AS based_in KEY (seller_id, state)
        SOURCE KEY (seller_id) REFERENCES node_seller (seller_id)
        DESTINATION KEY (state) REFERENCES node_state (state)
        LABEL BASED_IN,
        gold.edge_sells AS sells KEY (seller_id, product_id)
        SOURCE KEY (seller_id) REFERENCES node_seller (seller_id)
        DESTINATION KEY (product_id) REFERENCES node_product (product_id)
        LABEL SELLS,
        gold.edge_in_category AS in_category KEY (product_id, category)
        SOURCE KEY (product_id) REFERENCES node_product (product_id)
        DESTINATION KEY (category) REFERENCES node_category (category)
        LABEL IN_CATEGORY
    );