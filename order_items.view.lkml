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
      hour,
      day_of_month,
      day_of_week,
      day_of_week_index,
      fiscal_month_num,
      fiscal_quarter,
      fiscal_quarter_of_year,
      fiscal_year,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  measure: returned_items_distinct {
  type: count_distinct
  sql: ${TABLE}.id;;
  filters: {
    field: returned_date
    value: "-NULL"
  }
}

  measure: percent_returned {
    type: number
    sql: 100.0 * ${returned_items_distinct} / NULLIF(${count}, 0) ;;
    value_format: "0.00"
  }



  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
  }

  measure: gross_margin {
    description: "How much an item sold for minus the cost of that item."
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost};;
  }

  measure: average_gross_margin {
    description: "Average of how much an item sold for minus the cost of that item."
    type: average
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost};;
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
      products.name,
      order_id,
      inventory_item_id
    ]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: cumulative_total_revenue {
    type: running_total
    sql: ${total_sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
  }


  measure: least_expensive_item {
    type: min
    value_format_name: usd
    sql: ${sale_price} ;;
  }

  measure: most_expensive_item {
    type: max
    value_format_name: usd
    sql: ${sale_price} ;;
  }

  dimension: random_value {
    type:  number
    sql: ROUND(RAND()*100, 0) ;;
  }
}
