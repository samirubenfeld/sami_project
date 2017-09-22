view: total_orders {
  derived_table: {
    sql: SELECT count(*) as count,
    count(DISTINCT orders.id) as distinct_orders
      FROM orders;;
  }

  dimension: distinct_orders {
    type: number
    sql: ${TABLE}.distinct_orders ;;
  }


  dimension: count {
    type: number
    sql: ${TABLE}.count ;;
    view_label: "Order Purchase Affinity"
    label: "Total Order Count"
  }

  measure: distinct_orders_count {
    type: sum
    sql: ${TABLE}.distinct_orders ;;
  }



}
