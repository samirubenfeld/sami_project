view: orders {
  sql_table_name: demo_db.orders ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  filter: timeframe_picker {
    type: string
    suggestions: ["Date", "Week", "Month"]
  }

  #EXTRACT(MONTH FROM date_column)

  dimension: reporting_period {
    group_label: "Order Date"
    sql: CASE
        WHEN EXTRACT(YEAR FROM ${created_raw}) = EXTRACT(YEAR FROM current_date)
        AND ${created_raw} < CURRENT_DATE
        THEN 'This Year to Date'

        WHEN EXTRACT(YEAR FROM ${created_raw}) + 1 = EXTRACT(YEAR FROM current_date)
        AND DAYOFYEAR(${created_raw}) <= DAYOFYEAR(current_date)
        THEN 'Last Year to Date'

      END
       ;;
  }

  dimension: is_week_day {
    type: yesno
    sql: ${created_day_of_week_index} >=0 AND ${created_day_of_week_index}<= 4 ;;
  }

  measure: count_last_28d {
    label: "Count Sold in Trailing 28 Days"
    type: count_distinct
    sql: ${id} ;;
    hidden: yes
    filters:
    {
      field: created_date
      value: "28 days"
    }
  }

  dimension: created_formatted {
    type: date
    sql: ${TABLE}.created_at;;
    label: "Date - formatted"
    group_label: "Created Date"
    html:

       {% if is_week_day._value == "Yes" %}
         <p style="color: white; background-color: #EC407A; font-size:100%; text-align:center">{{ rendered_value }}</p
       {% else %}
         <p> {{ value }} </p>
       {% endif %} ;;
  }

  dimension: dynamic_timeframe {
    type: string
    sql:
    CASE
    WHEN {% condition timeframe_picker %} 'Date' {% endcondition %} THEN ${orders.created_date}
    WHEN {% condition timeframe_picker %} 'Week' {% endcondition %} THEN ${orders.created_week}
    WHEN {% condition timeframe_picker %} 'Month' {% endcondition %} THEN ${orders.created_month}
    END ;;
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
    drill_fields: [count_viz, id,
      users.full_name,
      order_items.returned_date,
      order_items.sale_price,
      products.name,
      products.item_name,
      order_items.order_id,
      order_items.inventory_item_id
    ]
  }

  measure: event_day_count {
    type: count_distinct
    sql: ${created_date} ;;
  }



#   measure: count_last_28d {
#     type: count
#     hidden: yes
#     filters: {
#       field: created_date
#       value: "28 days"
#     }
#   }


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


  dimension: status_new {
    type: string
    sql: ${TABLE}.status ;;
    html:
      {% if value == 'complete' %}
        <div style="background-color:#D5EFEE">{{ value }}</div>
      {% elsif value == 'pending' %}
        <div style="background-color:#FCECCC">{{ value }}</div>
      {% elsif value == 'cancelled' %}
        <div style="background-color:#EFD5D6">{{ value }}</div>
      {% endif %}
      ;;
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


  dimension: is_weekend {
    type: yesno
    sql: ${created_day_of_week} = 'Saturday' OR ${created_day_of_week} = 'Sunday' ;;
  }

  dimension: weekend_named {
    case: {
      when: {
        sql: ${created_day_of_week_index} = '5' OR ${created_day_of_week_index} = '6' ;;
        label: "Is Weekend"
      }
      else: "Is Weekday"
    }
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
    value_format: "0.000,\" K\""
  }


  measure: count_viz {
    type: count_distinct
    sql: ${id} ;;
    drill_fields: [orders.created_date, order_items.total_sale_price]
    link: {
      label: "Show as scatter plot"
      url: "
      {% assign vis_config = '{
      \"stacking\"                  : \"\",
      \"show_value_labels\"         : false,
      \"label_density\"             : 25,
      \"legend_position\"           : \"center\",
      \"x_axis_gridlines\"          : true,
      \"y_axis_gridlines\"          : true,
      \"show_view_names\"           : false,
      \"limit_displayed_rows\"      : false,
      \"y_axis_combined\"           : true,
      \"show_y_axis_labels\"        : true,
      \"show_y_axis_ticks\"         : true,
      \"y_axis_tick_density\"       : \"default\",
      \"y_axis_tick_density_custom\": 5,
      \"show_x_axis_label\"         : false,
      \"show_x_axis_ticks\"         : true,
      \"x_axis_scale\"              : \"auto\",
      \"y_axis_scale_mode\"         : \"linear\",
      \"show_null_points\"          : true,
      \"point_style\"               : \"circle\",
      \"ordering\"                  : \"none\",
      \"show_null_labels\"          : false,
      \"show_totals_labels\"        : false,
      \"show_silhouette\"           : false,
      \"totals_color\"              : \"#808080\",
      \"type\"                      : \"looker_scatter\",
      \"interpolation\"             : \"linear\",
      \"series_types\"              : {},
      \"colors\": [
      \"palette: Santa Cruz\"
      ],
      \"series_colors\"             : {},
      \"x_axis_datetime_tick_count\": null,
      \"trend_lines\": [
      {
      \"color\"             : \"#000000\",
      \"label_position\"    : \"left\",
      \"period\"            : 30,
      \"regression_type\"   : \"average\",
      \"series_index\"      : 1,
      \"show_label\"        : true,
      \"label_type\"        : \"string\",
      \"label\"             : \"30 day moving average\"
      }
      ]
      }' %}
      {{ link }}&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis&limit=5000"
    }
  }


  measure: count_distinct {
    type: count_distinct
    sql: ${id} ;;
    drill_fields: [orders.created_date, order_items.total_sale_price]
    link: {
      label: "Show as line plot"
      url: "
      {% assign vis_config = '{
      \"stacking\"                  : \"\",
      \"show_value_labels\"         : false,
      \"label_density\"             : 25,
      \"legend_position\"           : \"center\",
      \"x_axis_gridlines\"          : true,
      \"y_axis_gridlines\"          : true,
      \"show_view_names\"           : false,
      \"limit_displayed_rows\"      : false,
      \"y_axis_combined\"           : true,
      \"show_y_axis_labels\"        : true,
      \"show_y_axis_ticks\"         : true,
      \"y_axis_tick_density\"       : \"default\",
      \"y_axis_tick_density_custom\": 5,
      \"show_x_axis_label\"         : false,
      \"show_x_axis_ticks\"         : true,
      \"x_axis_scale\"              : \"auto\",
      \"y_axis_scale_mode\"         : \"linear\",
      \"show_null_points\"          : true,
      \"point_style\"               : \"none\",
      \"ordering\"                  : \"none\",
      \"show_null_labels\"          : false,
      \"show_totals_labels\"        : false,
      \"show_silhouette\"           : false,
      \"totals_color\"              : \"#808080\",
      \"type\"                      : \"looker_area\",
      \"interpolation\"             : \"linear\",
      \"series_types\"              : {},
      \"colors\": [
      \"palette: Default\"
      ],
      \"series_colors\"             : {},
      \"x_axis_datetime_tick_count\": null,
      \"trend_lines\": [
      {
      \"color\"             : \"#38A6A5\",
      \"label_position\"    : \"left\",
      \"period\"            : 30,
      \"regression_type\"   : \"average\",
      \"series_index\"      : 1,
      \"show_label\"        : true,
      \"label_type\"        : \"string\",
      \"label\"             : \"30 day moving average\"
      },
      {
      \"color\"             : \"#EDAD08\",
      \"label_position\"    : \"right\",
      \"period\"            : 7,
      \"regression_type\"   : \"average\",
      \"series_index\"      : 1,
      \"show_label\"        : true,
      \"label_type\"        : \"string\",
      \"label\"             : \"7 day moving average\"
      }
      ]
      }' %}
      {{ link }}&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis&limit=5000"
    }
  }



  measure: count_distinct_users {
    type: count_distinct
    sql: ${user_id} ;;
  }




  measure: count {
    label: "Count of Orders"
    type: count
    drill_fields: [count_viz, id, status, order_items.sale_price, products.brand, products.category, users.full_name, users.id]

  }


  dimension_group: today {
    type: time
    hidden: yes
    timeframes: [day_of_month, month, month_num, date, raw]
    sql: current_date ;;
  }

  ## Derive how many days are in each month to use in our calculation
  dimension: days_in_month {
    hidden: yes
    type: number
    sql:  CASE
          WHEN ${today_month_num} IN (4,6,9,11) THEN 30
          WHEN ${today_month_num} = 2 THEN 28
          ELSE 31
          END ;;
  }

  dimension: sale_price {
    hidden: yes
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  measure: total_sales {
    type: sum
    value_format_name: "usd_0"
    sql: ${sale_price} ;;
  }

  filter: date_filter {
    description: "Use this date filter in combination with the timeframes dimension for dynamic date filtering"
    type: date
  }


  dimension_group: filter_start_date {
    type: time
    timeframes: [raw]
    sql: CASE WHEN {% date_start date_filter %} IS NULL THEN '1970-01-01' ELSE NULLIF({% date_start date_filter %}, 0)::timestamp END;;
# MySQL: CASE WHEN {% date_start date_filter %} IS NULL THEN '1970-01-01' ELSE  TIMESTAMP(NULLIF({% date_start date_filter %}, 0)) END;;
  }

  dimension_group: filter_end_date {
    type: time
    timeframes: [raw]
    sql: CASE WHEN {% date_end date_filter %} IS NULL THEN CURRENT_DATE ELSE NULLIF({% date_end date_filter %}, 0)::timestamp END;;
# MySQL: CASE WHEN {% date_end date_filter %} IS NULL THEN NOW() ELSE TIMESTAMP(NULLIF({% date_end date_filter %}, 0)) END;;
  }

  dimension: interval {
    type: number
    sql: DATEDIFF(seconds, ${filter_start_date_raw}, ${filter_end_date_raw});;
# MySQL: TIMESTAMPDIFF(second, ${filter_end_date_raw}, ${filter_start_date_raw});;
  }

  dimension: previous_start_date {
    type: date
    sql: DATEADD(seconds, -${interval}, ${filter_start_date_raw}) ;;
# MySQL: DATE_ADD(${filter_start_date_raw}, interval ${interval} second) ;;
  }

  dimension: timeframes {
    # description: "Use this field in combination with the date filter field for dynamic date filtering”
  suggestions: ["period","previous period"]
  type: string
  case:  {
    when:  {
      sql: ${created_raw} BETWEEN ${filter_start_date_raw} AND  ${filter_end_date_raw};;
      label: "Period"
    }
    when: {
      sql: ${created_raw} BETWEEN ${previous_start_date} AND ${filter_start_date_raw} ;;
      label: "Previous Period"
    }
    else: "Not in time period"
  }
}







}
