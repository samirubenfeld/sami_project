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
    sql: ${TABLE}.sold_at != NULL ;;
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
}
