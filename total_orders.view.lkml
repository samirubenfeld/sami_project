view: total_orders {
  derived_table: {
    sql: SELECT count(*) as count
      FROM orders;;
  }

  dimension: count {
    type: number
    sql: ${TABLE}.count ;;
    view_label: "Order Purchase Affinity"
    label: "Total Order Count"
  }
}
