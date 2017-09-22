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

  dimension: days_in_inventory_tiered {
    type: tier
    style: relational
    tiers: [0,10,20,30,50,100]
    sql: ${days_in_inventory};;
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
    drill_fields: [id, products.brand, products.category, products.item_name, products.id, created_date, order_items.count]
  }
#
#   filter: date_filter {
#     description: "Use this date filter in combination with the timeframes dimension for dynamic date filtering"
#     type: date
#   }
#
#   dimension_group: filter_start_date {
#     type: time
#     timeframes: [raw,date]
#     sql: CASE WHEN {% date_start date_filter %} IS NULL THEN '1970-01-01' ELSE CAST({% date_start date_filter %} AS DATE) END;;
#   }
#
#   dimension_group: filter_end_date {
#     type: time
#     timeframes: [raw,date]
#     sql: CASE WHEN {% date_end date_filter %} IS NULL THEN CURRENT_DATE ELSE CAST({% date_end date_filter %} AS DATE) END;;
#   }
#
#   dimension: interval {
#     type: number
#     sql: DATEDIFF(${filter_start_date_raw}, ${filter_end_date_raw});;
#   }
#
#   dimension: previous_start_date {
#     type: string
#     sql: DATE_ADD(${filter_start_date_raw}, INTERVAL ${interval} DAY) ;;
#   }
#
#   dimension: filter_end_date_test {
#     sql: ${filter_end_date_date} ;;
#   }
#
#   dimension: is_current_period {
#     type: yesno
#     sql: ${sold_date} >= ${filter_start_date_date} AND ${sold_date} < ${filter_end_date_date} ;;
#   }
#   dimension: is_previous_period {
#     type: yesno
#     sql: ${sold_date} >= ${previous_start_date} AND ${sold_date} < ${filter_start_date_date} ;;
#   }
#
#   dimension: timeframes {
#     description: "Use this field in combination with the date filter field for dynamic date filtering"
#     suggestions: ["period","previous period"]
#     type: string
#     case:  {
#       when:  {
#         sql: ${is_current_period} = true;;
#         label: "Selected Period"
#       }
#       when: {
#         sql: ${is_previous_period} = true;;
#         label: "Previous Period"
#       }
#       else: "Not in time period"
#     }
#   }
#
#   measure: selected_period_order_cost {
#     type: sum
#     sql: ${TABLE}.total_cost ;;
#     filters: {
#       field: is_current_period
#       value: "yes"
#     }
#     value_format_name: decimal_1
#   }
#   measure: previous_period_order_cost {
#     type: sum
#     sql: ${TABLE}.total_cost ;;
#     filters: {
#       field: is_previous_period
#       value: "yes"
#     }
#     value_format_name: decimal_1
#   }

  measure: total_cost {
    type: sum
    sql: ${cost} ;;
    value_format_name: usd
  }


  measure: average_cost {
    type: average
    sql:  ${cost} ;;
    value_format_name:  usd
  }

#   measure: total_profit {
#     type: number
#     sql: ${order_items.total_sale_price} - ${inventory_items.total_cost} ;;
#     value_format_name: usd
#   }

}
