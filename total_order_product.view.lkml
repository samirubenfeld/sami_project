# view: total_order_product {
#   derived_table: {
#     indexes: ["product"]
#     sql: SELECT p.item_name as product
#       , count(distinct p.item_name, o.id) as product_order_count    -- count of orders with product, not total number of product ordered
#       FROM order_items oi
#       JOIN orders o ON o.id = oi.order_id
#       JOIN inventory_items ii ON oi.inventory_item_id = ii.id
#       JOIN products p ON ii.product_id = p.id
#       WHERE {% condition order_purchase_affinity.affinity_timeframe %} o.created_at {% endcondition %}
#       GROUP BY p.item_name
#       ;;
#   }
# }
