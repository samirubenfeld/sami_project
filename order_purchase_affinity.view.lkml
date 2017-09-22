view: order_purchase_affinity {
  derived_table: {
    indexes: ["product_a"]
    sql:
        SELECT product_a
        , product_b
        , joint_frequency
        , top1.product_frequency as product_a_frequency
        , top2.product_frequency as product_b_frequency
        FROM (
          SELECT op1.product as product_a
          , op2.product as product_b
          , count(*) as joint_frequency
        FROM (
          SELECT o.id as order_id
        , oi.inventory_item_id as inventory_item_id
        , p.item_name as product
        FROM order_items oi
        JOIN orders o ON o.id = oi.order_id
        JOIN inventory_items ii ON oi.inventory_item_id = ii.id
        JOIN products p ON ii.product_id = p.id
        GROUP BY order_id, item_name) as op1
          JOIN (
          SELECT o.id as order_id
        , oi.inventory_item_id as inventory_item_id
        , p.item_name as product
        FROM order_items oi
        JOIN orders o ON o.id = oi.order_id
        JOIN inventory_items ii ON oi.inventory_item_id = ii.id
        JOIN products p ON ii.product_id = p.id
        GROUP BY order_id, item_name) as op2
        ON op1.order_id = op2.order_id
          GROUP BY product_a, product_b
        ) as prop
        JOIN (
        SELECT p.item_name as product, count(distinct p.item_name, o.id) as product_frequency
        FROM order_items oi
        JOIN orders o ON o.id = oi.order_id
        JOIN inventory_items ii ON oi.inventory_item_id = ii.id
        JOIN products p ON ii.product_id = p.id
        GROUP BY p.item_name) as top1
        ON prop.product_a = top1.product
        JOIN (
      SELECT p.item_name as product, count(distinct p.item_name, o.id) as product_frequency
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      JOIN inventory_items ii ON oi.inventory_item_id = ii.id
      JOIN products p ON ii.product_id = p.id
      GROUP BY p.item_name) as top2 ON prop.product_b = top2.product
        ORDER BY product_a, joint_frequency DESC, product_b;;
  }


  filter: affinity_timeframe {
    type: date
  }

  dimension: product_a {
    type: string
    sql: ${TABLE}.product_a ;;
  }

  dimension: product_b {
    type: string
    sql: ${TABLE}.product_b ;;
  }

  dimension: joint_order_count {
    description: "How many times item A and B were purchased in the same order"
    type: number
    sql: ${TABLE}.joint_order_count ;;
    value_format: "#"
  }

  dimension: product_a_order_count {
    description: "Total number of orders with product A in them, during specified timeframe"
    type: number
    sql: ${TABLE}.product_a_order_count ;;
    value_format: "#"
  }

  dimension: product_b_order_count {
    description: "Total number of orders with product B in them, during specified timeframe"
    type: number
    sql: ${TABLE}.product_b_order_count ;;
    value_format: "#"
  }

  #  Frequencies
  dimension: product_a_order_frequency {
    description: "How frequently orders include product A as a percent of total orders"
    type: number
    sql: 1.0*${product_a_order_count}/${total_orders.count} ;;
    value_format: "#.00%"
  }

  dimension: product_b_order_frequency {
    description: "How frequently orders include product B as a percent of total orders"
    type: number
    sql: 1.0*${product_b_order_count}/${total_orders.count} ;;
    value_format: "#.00%"
  }

  dimension: joint_order_frequency {
    description: "How frequently orders include both product A and B as a percent of total orders"
    type: number
    sql: 1.0*${joint_order_count}/${total_orders.count} ;;
    value_format: "#.00%"
  }

  # Affinity Metrics

  dimension: add_on_frequency {
    description: "How many times both Products are purchased when Product A is purchased"
    type: number
    sql: 1.0*${joint_order_count}/${product_a_order_count} ;;
    value_format: "#.00%"
  }

  dimension: lift {
    description: "The likelihood that buying product A drove the purchase of product B"
    type: number
    sql: ${joint_order_frequency}/(${product_a_order_frequency} * ${product_b_order_frequency}) ;;
    value_format: "#,##0.#0"
  }

  ## Do not display unless users have a solid understanding of  statistics and probability models
  dimension: jaccard_similarity {
    description: "The probability both items would be purchased together, should be considered in relation to total order count, the highest score being 1"
    type: number
    sql: 1.0*${joint_order_count}/(${product_a_order_count} + ${product_b_order_count} - ${joint_order_count}) ;;
    value_format: "0.00"
  }

  # Aggregate Measures - ONLY TO BE USED WHEN FILTERING ON AN AGGREGATE DIMENSION (E.G. BRAND_A, CATEGORY_A)

  measure: aggregated_joint_order_count {
    description: "Only use when filtering on a rollup of product items, such as brand_a or category_a"
    type: sum
    sql: ${joint_order_count} ;;
  }

}
