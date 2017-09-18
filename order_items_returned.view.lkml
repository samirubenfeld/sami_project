# view: order_items_returned {
#   derived_table: {
#     sql: SELECT products.brand,
#           COUNT(CASE WHEN order_items.returned_at IS NOT NULL THEN 1 ELSE NULL END) as count_returned_items
#       FROM order_items  AS order_items
#       LEFT JOIN inventory_items  AS inventory_items ON order_items.inventory_item_id = inventory_items.id
#       LEFT JOIN orders  AS orders ON order_items.order_id = orders.id
#       LEFT JOIN products  AS products ON inventory_items.product_id = products.id
#       GROUP BY 1
#       ORDER BY 2 DESC;
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: brand {
#     type: string
#     sql: ${TABLE}.brand ;;
#   }

#   dimension: count_returned_items {
#     type: number
#     sql: ${TABLE}.count_returned_items ;;
#   }

#   set: detail {
#     fields: [brand, count_returned_items]
#   }
# }
