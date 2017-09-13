view: order_items {
  sql_table_name: demo_db.order_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: inventory_item_id {
    type: number
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }


  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }


  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
  }

  dimension: price_range {
    case: {
      when: {
        sql: ${sale_price} < 20 ;;
        label: "Inexpensive"
      }
      when: {
        sql: ${sale_price} >= 20 AND ${sale_price} < 100 ;;
        label: "Normal"
      }
      when: {
        sql: ${sale_price} >= 100 ;;
        label: "Expensive"
      }
      else: "Unknown"
    }
  }



  measure: count {
    type: count
    drill_fields: [
      id,
      returned_time,
      sale_price,
      products.name
    ]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
  }

  # measure: total_profit {
  #   type: number
  #   sql: ${total_sale_price} - ${products.total_cost} ;;
  # }

  measure: least_expensive_item {
    type: min
    sql: ${sale_price} ;;
  }

  measure: most_expensive_item {
    type: max
    sql: ${sale_price} ;;
  }
}
