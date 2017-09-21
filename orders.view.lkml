view: orders {
  sql_table_name: demo_db.orders ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }


  dimension_group: created {
    type: time
    timeframes: [
      raw,
      hour,
      day_of_month,
      day_of_week,
      day_of_week_index,
      day_of_year,
      hour_of_day,
      fiscal_month_num,
      fiscal_quarter,
      fiscal_quarter_of_year,
      fiscal_year,
      time,
      date,
      week,
      month,
      month_name,
      month_num,
      quarter,
      quarter_of_year,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }


  dimension: status_alt {
    type: string
    sql: ${TABLE}.status ;;
  }


  dimension: status {
    sql: ${TABLE}.status ;;
    html:
    {% if value == 'pending' %}
      <div style="color: black; background-color: lightblue; border: 2px; font-weight: bold; font-size:100%; text-align:center">{{ rendered_value }}</div>
    {% elsif value == 'complete' %}
      <div style="color: black; background-color: lightgreen; border: 2px; font-weight: bold; font-size:100%; text-align:center">{{ rendered_value }}</div>
    {% else %}
      <div style="color: black; background-color: #FFC300; border: 2px; font-weight: bold; font-size:100%; text-align:center">{{ rendered_value }}</div>
    {% endif %}
;;
    # drill_fields: [products.brand, product.category, order_items.count]
  }

  measure: cancelled_items_distinct {
    type: count_distinct
    sql: ${TABLE}.id;;
    drill_fields: [
      id,
      users.full_name,
      order_items.returned_date,
      order_items.sale_price,
      products.name,
      products.item_name,
      order_items.order_id,
      order_items.inventory_item_id
    ]
    filters: {
      field: status
      value: "cancelled"
    }
  }

  dimension: is_complete {
    type: yesno
    sql: ${status} = 'complete' ;;
  }

  dimension: is_pending {
    type: yesno
    sql: ${status} = 'pending' ;;
  }

  dimension: is_cancelled {
    type: yesno
    sql: ${status} = 'cancelled' ;;
  }


  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: number_of_unique_customers {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: number_of_unique_orders {
    type: count_distinct
    sql: ${id} ;;
  }

  measure: count_growth {
    type: percent_of_previous
    sql: ${count} ;;
  }

  measure: count_running_total {
    type: running_total
    sql: ${count} ;;
  }


  measure: count_distinct {
    type: count_distinct
    sql: ${user_id} ;;
  }


  measure: count {
    type: count
    drill_fields: [id, status, order_items.sale_price, products.brand, product.category, users.full_name, users.id]
  }


  # # TEMPLATED FILTER IN A DIMENSION

  # filter: timeframe {
  #   suggestions: ["Daily", "Weekly", "Monthly", "Yearly"]
  # }

  # dimension: variable_timeframe {
  #   sql: CASE
  #       WHEN {% condition timeframe %} 'Daily' {% endcondition %} THEN TO_CHAR(${created_date},'YYYY-MM-DD')
  #       WHEN {% condition timeframe %} 'Weekly' {% endcondition %} THEN ${created_week}
  #       WHEN {% condition timeframe %} 'Monthly' {% endcondition %} THEN ${created_month}
  #       WHEN {% condition timeframe %} 'Yearly' {% endcondition %} THEN TO_CHAR(${created_year}, '9999')
  #     END
  #     ;;
  # }


}
