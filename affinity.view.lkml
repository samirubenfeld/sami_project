# # include all views in this project
# include: "*.view"
#
# # include all dashboards in this project
# include: "*.dashboard"
#
# # <!-- view: orders {
# #   derived_table: {
# #     sql: select
# #         oi.order_id as id
# #         , MIN(oi.created_at) as created_at
# #         ,COUNT(distinct p.id) as distinct_products
# #         FROM order_items oi
# #         LEFT JOIN inventory_items ii ON oi.inventory_item_id = ii.id
# #         LEFT JOIN products p ON ii.product_id = p.id
# #         GROUP BY oi.order_id ;;
# #   }
# # } -->
#
# view: order_product {
#   derived_table: {
#     # persist_for: "24 hours"
#     indexes: ["order_id", "created_at"]
#     distribution_style: all
#     sql:
#       SELECT oi.inventory_item_id as order_item_id
#       , o.id as order_id
#       , o.created_at
#       , p.name as product
#       FROM order_items oi
#       JOIN orders o ON o.id = oi.order_id
#       JOIN inventory_items ii ON oi.inventory_item_id = ii.product_id
#       JOIN products p ON ii.product_id = p.id
#       GROUP BY oi.id,o.id, p.name, o.created_at
#        ;;
#   }
# }
#
# view: order_metrics {
#   derived_table: {
#     sql: SELECT oi.inventory_item_id as order_item_id
#       , SUM(oi.sale_price) over (partition by oi.order_id) as basket_sales
#       , SUM(oi.sale_price-ii.cost) over (partition by oi.order_id) as basket_margin
#         FROM order_items oi
#         LEFT JOIN inventory_items ii
#           ON oi.inventory_item_id = ii.id
#         LEFT JOIN products p
#           ON ii.product_id = p.id;;
#   }
# }
#
# view: total_order_product {
#   derived_table: {
#     # persist_for: "24 hours"
#     indexes: ["product"]
#     distribution_style: all
#     sql:
#       SELECT p.name as product
#       , count(distinct p.name||o.id) as product_order_count    -- count of orders with product, not total order items
#       , SUM(oi.sale_price) as product_sales
#       , SUM(oi.sale_price-ii.cost) as product_margin
#       , SUM(om.basket_sales) as basket_sales
#       , SUM(om.basket_margin) as basket_margin
#       , COUNT(distinct (CASE WHEN o.distinct_products=1 THEN o.id ELSE NULL END)) as product_count_purchased_alone
#       FROM order_items oi
#       JOIN ${order_metrics.SQL_TABLE_NAME} om ON oi.id = om.order_item_id
#       JOIN ${orders.SQL_TABLE_NAME} o ON o.id = oi.order_id
#       JOIN inventory_items ii ON oi.inventory_item_id = ii.id
#       JOIN products p ON ii.product_id = p.id
#       WHERE {% condition order_purchase_affinity.affinity_timeframe %} o.created_at {% endcondition %}
#       GROUP BY p.name
#        ;;
#   }
# }
#
# view: product_loyal_users {
#   derived_table: {
#     sql: SELECT
#           oi.user_id
#         from order_items oi
#         JOIN inventory_items ii ON oi.inventory_item_id = ii.id
#         JOIN products p ON ii.product_id = p.id
#         WHERE {% condition order_purchase_affinity.affinity_timeframe %} oi.created_at {% endcondition %}
#         GROUP BY oi.user_id
#         HAVING COUNT(distinct p.name) =1;;
#   }
# }
#
# view: orders_by_product_loyal_users {
#   derived_table: {
#     persist_for: "24 hours"
#     indexes: ["product"]
#     distribution_style: all
#     sql:
#        SELECT
#         p.name as product,
#         COUNT (distinct oi.order_id) as orders_by_loyal_customers
#       FROM order_items oi
#       JOIN inventory_items ii ON oi.inventory_item_id = ii.id
#       JOIN products p ON ii.product_id = p.id
#       INNER JOIN ${product_loyal_users.SQL_TABLE_NAME} plu on oi.user_id = plu.user_id
#       WHERE {% condition order_purchase_affinity.affinity_timeframe %} oi.created_at {% endcondition %}
#       GROUP BY p.name
#        ;;
#   }
# }
#
# view: total_orders {
#   derived_table: {
#     sql:
#
#       SELECT count(*) as count
#       FROM orders
#       WHERE {% condition order_purchase_affinity.affinity_timeframe %} created_at {% endcondition %}
#        ;;
#   }
#
#   dimension: count {
#     type: number
#     sql: ${TABLE}.count ;;
#     view_label: "Affinity"
#     label: "Total Order Count"
#   }
# }
#
# view: order_purchase_affinity {
#   derived_table: {
#     persist_for: "24 hours"
#     indexes: ["product_a"]
#     distribution_style: all
#     sql: SELECT product_a
#         , product_b
#         , joint_order_count
#         , top1.product_order_count as product_a_order_count   -- total number of orders with product A in them
#         , top2.product_order_count as product_b_order_count   -- total number of orders with product B in them
#         , top1.product_count_purchased_alone as product_a_count_purchased_alone
#         , top2.product_count_purchased_alone as product_b_count_purchased_alone
#         , ISNULL(loy1.orders_by_loyal_customers,0) as product_a_count_orders_by_loyal_customers
#         , ISNULL(loy2.orders_by_loyal_customers,0) as product_b_count_orders_by_loyal_customers
#         , top1.product_sales as product_a_product_sales
#         , top2.product_sales as product_b_product_sales
#         , top1.product_margin as product_a_product_margin
#         , top2.product_margin as product_b_product_margin
#         , top1.basket_sales as product_a_basket_sales
#         , top2.basket_sales as product_b_basket_sales
#         , top1.basket_margin as product_a_basket_margin
#         , top2.basket_margin as product_b_basket_margin
#         FROM (
#           SELECT op1.product as product_a
#           , op2.product as product_b
#           , count(*) as joint_order_count
#           FROM ${order_product.SQL_TABLE_NAME} as op1
#           JOIN ${order_product.SQL_TABLE_NAME} op2
#           ON op1.order_id = op2.order_id
#           AND op1.order_item_id <> op2.order_item_id            -- ensures we do not match on the same order items in the same order, which would corrupt our frequency metrics
#           WHERE {% condition affinity_timeframe %} op1.created_at {% endcondition %}
#           AND {% condition affinity_timeframe %} op2.created_at {% endcondition %}
#           GROUP BY product_a, product_b
#         ) as prop
#         JOIN ${total_order_product.SQL_TABLE_NAME} as top1 ON prop.product_a = top1.product
#         JOIN ${total_order_product.SQL_TABLE_NAME} as top2 ON prop.product_b = top2.product
#         LEFT JOIN ${orders_by_product_loyal_users.SQL_TABLE_NAME} as loy1 ON prop.product_a = loy1.product
#         LEFT JOIN ${orders_by_product_loyal_users.SQL_TABLE_NAME} as loy2 ON prop.product_a = loy2.product
#         ORDER BY product_a, joint_order_count DESC, product_b
#          ;;
#   }
#
#   filter: affinity_timeframe {
#     type: date
#   }
#
#   dimension: product_a {
#     type: string
#     sql: ${TABLE}.product_a ;;
#   }
#
#   dimension: product_b {
#     type: string
#     sql: ${TABLE}.product_b ;;
#   }
#
#   dimension: joint_order_count {
#     description: "How many times item A and B were purchased in the same order"
#     type: number
#     sql: ${TABLE}.joint_order_count ;;
#     value_format: "#"
#   }
#
#   dimension: product_a_order_count {
#     description: "Total number of orders with product A in them, during specified timeframe"
#     type: number
#     sql: ${TABLE}.product_a_order_count ;;
#     value_format: "#"
#   }
#
#   dimension: product_b_order_count {
#     description: "Total number of orders with product B in them, during specified timeframe"
#     type: number
#     sql: ${TABLE}.product_b_order_count ;;
#     value_format: "#"
#   }
#
#   #  Frequencies
#   dimension: product_a_order_frequency {
#     description: "How frequently orders include product A as a percent of total orders"
#     type: number
#     sql: 1.0*${product_a_order_count}/${total_orders.count} ;;
#     value_format: "0.00%"
#   }
#
#   dimension: product_b_order_frequency {
#     description: "How frequently orders include product B as a percent of total orders"
#     type: number
#     sql: 1.0*${product_b_order_count}/${total_orders.count} ;;
#     value_format: "0.00%"
#   }
#
#
#   dimension: joint_order_frequency {
#     description: "How frequently orders include both product A and B as a percent of total orders"
#     type: number
#     sql: 1.0*${joint_order_count}/${total_orders.count} ;;
#     value_format: "0.00%"
#   }
#
#   # Affinity Metrics
#
#   dimension: add_on_frequency {
#     description: "How many times both Products are purchased when Product A is purchased"
#     type: number
#     sql: 1.0*${joint_order_count}/${product_a_order_count} ;;
#     value_format: "0.00%"
#   }
#
#   dimension: lift {
#     description: "The likelihood that buying product A drove the purchase of product B"
#     type: number
#     sql: 1*${joint_order_frequency}/(${product_a_order_frequency} * ${product_b_order_frequency}) ;;
#   }
#
#   dimension: product_a_count_purchased_alone {
#     type: number
#     hidden: yes
#     sql: ${TABLE}.product_a_count_purchased_alone ;;
#   }
#
#   dimension: product_a_percent_purchased_alone {
#     description: "The % of times product A is purchased alone, over all transactions containing product A"
#     type: number
#     sql: 1.0*${product_a_count_purchased_alone}/(CASE WHEN ${product_a_order_count}=0 THEN NULL ELSE ${product_a_order_count} END);;
#     value_format_name: percent_1
#   }
#
#   dimension: product_a_count_orders_by_loyal_customers {
#     type: number
#     hidden: yes
#     sql: ${TABLE}.product_a_count_orders_by_loyal_customers ;;
#   }
#
#   dimension: product_a_percent_customer_loyalty{
#     description: "% of times product A is purchased by customers who only bought product A in the timeframe"
#     type: number
#     sql: 1.0*${product_a_count_orders_by_loyal_customers}/(CASE WHEN ${product_a_order_count}=0 THEN NULL ELSE ${product_a_order_count} END) ;;
#     value_format_name: percent_1
#   }
#
#   dimension: product_b_count_purchased_alone {
#     type: number
#     hidden: yes
#     sql: ${TABLE}.product_b_count_purchased_alone ;;
#   }
#
#   dimension: product_b_percent_purchased_alone {
#     description: "The % of times product B is purchased alone, over all transactions containing product B"
#     type: number
#     sql: 1.0*${product_b_count_purchased_alone}/(CASE WHEN ${product_b_order_count}=0 THEN NULL ELSE ${product_b_order_count} END);;
#     value_format_name: percent_1
#   }
#
#   dimension: product_b_count_orders_by_loyal_customers {
#     type: number
#     hidden: yes
#     sql: ${TABLE}.product_b_count_orders_by_loyal_customers ;;
#   }
#
#   dimension: product_b_percent_customer_loyalty{
#     description: "% of times product B is purchased by customers who only bought product B in the timeframe"
#     type: number
#     sql: 1.0*${product_b_count_orders_by_loyal_customers}/(CASE WHEN ${product_b_order_count}=0 THEN NULL ELSE ${product_b_order_count} END) ;;
#     value_format_name: percent_1
#   }
#
# ## Do not display unless users have a solid understanding of  statistics and probability models
#   dimension: jaccard_similarity {
#     description: "The probability both items would be purchased together, should be considered in relation to total order count, the highest score being 1"
#     type: number
#     sql: 1.0*${joint_order_count}/(${product_a_order_count} + ${product_b_order_count} - ${joint_order_count}) ;;
#     value_format: "#,##0.#0"
#   }
#
#   # Sales Metrics - Totals
#
#   dimension: product_a_total_sales {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product A - Sales"
#     type: number
#     sql: ${TABLE}.product_a_product_sales ;;
#     value_format_name: usd
#   }
#
#   dimension: product_a_total_basket_sales {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product A - Sales"
#     type: number
#     sql: ${TABLE}.product_a_basket_sales ;;
#     value_format_name: usd
#   }
#
#   dimension: product_a_total_rest_of_basket_sales {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product A - Sales"
#     type: number
#     sql: ${product_a_total_basket_sales}-ISNULL(${product_a_total_sales},0) ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_total_sales {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product B - Sales"
#     type: number
#     sql: ${TABLE}.product_b_product_sales ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_total_basket_sales {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product B - Sales"
#     type: number
#     sql: ${TABLE}.product_b_basket_sales ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_total_rest_of_basket_sales {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product B - Sales"
#     type: number
#     sql: ${product_b_total_basket_sales}-ISNULL(${product_b_total_sales},0) ;;
#     value_format_name: usd
#   }
#
#   # Margin Metrics - Totals
#
#   dimension: product_a_total_margin {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product A - Margin"
#     type: number
#     sql: ${TABLE}.product_a_product_margin ;;
#     value_format_name: usd
#   }
#
#   dimension: product_a_total_basket_margin {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product A - Margin"
#     type: number
#     sql: ${TABLE}.product_a_basket_margin ;;
#     value_format_name: usd
#   }
#
#   dimension: product_a_total_rest_of_basket_margin {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product A - Margin"
#     type: number
#     sql: ${product_a_total_basket_margin}-ISNULL(${product_a_total_margin},0) ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_total_margin {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product B - Margin"
#     type: number
#     sql: ${TABLE}.product_b_product_margin ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_total_basket_margin {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product B - Margin"
#     type: number
#     sql: ${TABLE}.product_b_basket_margin ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_total_rest_of_basket_margin {
#     view_label: "Sales and Margin - Total"
#     group_label: "Product B - Margin"
#     type: number
#     sql: ${product_b_total_basket_margin}-ISNULL(${product_b_total_margin},0) ;;
#     value_format_name: usd
#   }
#
#   # Sales Metrics - Average
#
#   dimension: product_a_average_sales {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product A - Sales"
#     type: number
#     sql: 1.0*${product_a_total_sales}/${product_a_order_count} ;;
#     value_format_name: usd
#   }
#
#   dimension: product_a_average_basket_sales {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product A - Sales"
#     type: number
#     sql: 1.0*${product_a_total_basket_sales}/${product_a_order_count} ;;
#     value_format_name: usd
#   }
#
#   dimension: product_a_average_rest_of_basket_sales {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product A - Sales"
#     type: number
#     sql: 1.0*${product_a_total_rest_of_basket_sales}/${product_a_order_count} ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_average_sales {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product B - Sales"
#     type: number
#     sql: 1.0*${product_b_total_sales}/${product_b_order_count} ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_average_basket_sales {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product B - Sales"
#     type: number
#     sql: 1.0*${product_b_total_basket_sales}/${product_b_order_count} ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_average_rest_of_basket_sales {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product B - Sales"
#     type: number
#     sql: 1.0*${product_b_total_rest_of_basket_sales}/${product_b_order_count} ;;
#     value_format_name: usd
#   }
#
#   # Margin Metrics - Average
#
#   dimension: product_a_average_margin {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product A - Margin"
#     type: number
#     sql: 1.0*${product_a_total_margin}/${product_a_order_count} ;;
#     value_format_name: usd
#   }
#
#   dimension: product_a_average_basket_margin {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product A - Margin"
#     type: number
#     sql: 1.0*${product_a_total_basket_margin}/${product_a_order_count} ;;
#     value_format_name: usd
#     drill_fields: [product_a, product_a_percent_purchased_alone, product_a_percent_customer_loyalty]
#   }
#
#   dimension: product_a_average_rest_of_basket_margin {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product A - Margin"
#     type: number
#     sql: 1.0*${product_a_total_rest_of_basket_margin}/${product_a_order_count} ;;
#     value_format_name: usd
#     drill_fields: [product_a, product_a_percent_purchased_alone, product_a_percent_customer_loyalty]
#   }
#
#   dimension: product_b_average_margin {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product B - Margin"
#     type: number
#     sql: 1.0*${product_b_total_margin}/${product_b_order_count} ;;
#     value_format_name: usd
#   }
#
#   dimension: product_b_average_basket_margin {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product B - Margin"
#     type: number
#     sql: 1.0*${product_b_total_basket_margin}/${product_b_order_count} ;;
#     value_format_name: usd
#     drill_fields: [product_b, product_b_percent_purchased_alone, product_b_percent_customer_loyalty]
#   }
#
#   dimension: product_b_average_rest_of_basket_margin {
#     view_label: "Sales and Margin - Average"
#     group_label: "Product B - Margin"
#     type: number
#     sql: 1.0*${product_b_total_rest_of_basket_margin}/${product_b_order_count} ;;
#     value_format_name: usd
#     drill_fields: [product_b, product_b_percent_purchased_alone, product_b_percent_customer_loyalty]
#   }
#
#   # Aggregate Measures - ONLY TO BE USED WHEN FILTERING ON AN AGGREGATE DIMENSION (E.G. BRAND_A, CATEGORY_A)
#
#
#   # measure: aggregated_joint_order_count {
#   #   description: "Only use when filtering on a rollup of product items, such as brand_a or category_a"
#   #   type: sum
#   #   sql: ${joint_order_count} ;;
#   # }
# }
