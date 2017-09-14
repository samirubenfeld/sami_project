view: inventory_items {
  sql_table_name: demo_db.inventory_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost;;
    value_format_name: usd
  }


  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_month,
      day_of_week,
      day_of_year,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: sold {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_month,
      day_of_week,
      day_of_week_index,
      hour_of_day,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.sold_at ;;
  }

  dimension: days_in_inventory {
    type: number
    sql: DATEDIFF(${sold_date}, ${created_date}) ;;
  }

  dimension: is_sold {
    type: yesno
    sql: ${TABLE}.sold_at IS NOT NULL ;;
  }

  measure: sold_items_distinct {
    type: count_distinct
    sql: ${TABLE}.id;;
    filters: {
      field: sold_date
      value: "-NULL"
    }
  }

  measure: percent_sold {
    type: number
    sql: 100.0 * ${sold_items_distinct} / NULLIF(${count}, 0) ;;
    value_format: "0.00"
  }

  measure: number_on_hand {
    type: count
    filters: {
      field: is_sold
      value: "No"
    }
  }

  measure: count_last_28d {
    type: count
    hidden: yes
    filters: {
      field: created_date
      value: "28 days"
    }
  }

  measure: count_last_90d {
    type: count
    hidden: yes
    filters: {
      field: created_date
      value: "90 days"
    }
  }

  measure: count {
    type: count
    drill_fields: [id, products.item_name, products.id, order_items.count]
  }

  measure: total_cost {
    type: sum
    sql: ${cost} ;;
    value_format_name: usd
  }

  measure: total_profit {
    type: number
    sql: ${order_items.total_revenue} - ${inventory_items.total_cost} ;;
    value_format_name: usd
  }

}
