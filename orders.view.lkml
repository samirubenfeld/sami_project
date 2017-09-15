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


  # dimension: status {
  #   type: string
  #   sql: ${TABLE}.status ;;
  # }

  dimension: status {
    sql: ${TABLE}.status ;;
    html:
    {% if value == 'pending' %}
      <p style="color: black; background-color: lightblue; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% elsif value == 'complete' %}
      <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% else %}
      <p style="color: black; background-color: orange; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% endif %}
;;
  }

  dimension: is_complete {
    type: yesno
    sql: ${status} = 'complete' ;;
  }

  dimension: is_pending {
    type: yesno
    sql: ${status} = 'pending' ;;
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


  measure: count_distinct {
    type: count_distinct
    sql: ${user_id} ;;
  }


  measure: count {
    type: count
    drill_fields: [id, user_id, products.sku, status, order.id, products.brand, product.category, users.last_name, users.first_name, users.id, order_items.count]
  }
}
