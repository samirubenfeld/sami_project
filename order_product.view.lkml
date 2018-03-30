view: order_product {
  derived_table: {
    indexes: ["order_id", "created_at"]
    sql: SELECT o.id as order_id
      , oi.id as order_item_id
      , o.created_at
      , oi.inventory_item_id as inventory_item_id
      , p.item_name as product
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      JOIN inventory_items ii ON oi.inventory_item_id = ii.id
      JOIN products p ON ii.product_id = p.id
      GROUP BY order_id, item_name, created_at
       ;;
  }
}
