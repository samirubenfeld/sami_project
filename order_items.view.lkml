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


  filter: category_count_picker {
    description: "Use with the Category Count measure"
    type: string
    suggest_explore: order_items
    suggest_dimension: products.category
  }

  measure: category_count {
    description: "Use with the Category Count Picker filter-only field"
    type: sum
    sql:
    CASE
      WHEN {% condition category_count_picker %} ${products.category} {% endcondition %}
      THEN 1
      ELSE 0
    END
  ;;
  }


  dimension: was_returned {
    type: yesno
    sql: ${TABLE}.returned_at IS NOT NULL ;;
  }


  dimension_group: returned {
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
      minute,
      month,
      month_name,
      month_num,
      quarter,
      quarter_of_year,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  measure: returned_sale_price {
    type: sum
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
    drill_fields: [users.id, users.state, products.id, products.item_name, order_items.sale_price, returned_date, users.full_name, users.email]

    filters: {
      field: returned_date
      value: "-NULL"
    }
  }

  measure: lost_revenue {
    type: sum
    sql: ${TABLE}.sale_price * -1;;
    value_format_name: usd
    drill_fields: [users.id, users.state, products.id, products.item_name, order_items.sale_price, returned_date, users.full_name, users.email]

    filters: {
      field: returned_date
      value: "-NULL"
    }
  }

  filter: test {
    type: string
  }
measure: html_test {
  type: number
  html: {% if _filters['test'] == 'a' %}
  {{returned_sale_price._rendered_value}}
  {% else %}
  {{lost_revenue._rendered_value}}
  {% endif %} ;;
  sql: ${lost_revenue} ;; #can be anything you want
}


  measure: returned_sale_price_distinct {
    type: sum_distinct
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
    drill_fields: [users.id, products.id, returned_date, users.first_name, users.last_name]

    filters: {
      field: returned_date
      value: "-NULL"
    }
  }





  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd

  }

  dimension: gross_profit {
    description: "How much an item sold for minus the cost of that item."
    type: number
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


#MEASURES

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

  measure: returned_items_distinct {
    type: count_distinct
    sql: ${TABLE}.id;;
    drill_fields: [
      id,
      users.full_name,
      returned_date,
      sale_price,
      products.name,
      products.item_name,
      order_id,
      inventory_item_id
    ]
    filters: {
      field: returned_date
      value: "-NULL"
    }
  }

#   measure: returned_items_count {
#     type: count
#     sql: ${TABLE}.id;;
#     drill_fields: [
#       id,
#       returned_time,
#       sale_price,
#       products.name,
#       order_id,
#       inventory_item_id
#     ]
#     filters: {
#       field: returned_date
#       value: "-NULL"
#     }
#   }

  measure: percent_returned {
    type: number
    sql: 100.0 * ${returned_items_distinct} / NULLIF(${count}, 0) ;;
    value_format: "#.00\%"
  }

   measure: returned_percent_gauge {
    type: number
    sql: ${percent_returned};;
    value_format: "#.0\%"
    html:
      <img src="https://chart.googleapis.com/chart?chs=500x275&cht=gom&chxt=y&chco=635189,B1A8C4,1EA8DF,8ED3EF&chf=bg,s,FFFFFF00&chl={{ rendered_value }}&chd=t:{{ value }}">;;
      }




  parameter: sale_price_metric_picker {
    description: "Use with the Sale Price Metric measure"
    type: unquoted
    allowed_value: {
      label: "Total Sale Price"
      value: "SUM"
    }
    allowed_value: {
      label: "Average Sale Price"
      value: "AVG"
    }
    allowed_value: {
      label: "Maximum Sale Price"
      value: "MAX"
    }
    allowed_value: {
      label: "Minimum Sale Price"
      value: "MIN"
    }
  }

  measure: sale_price_metric {
    description: "Use with the Sale Price Metric Picker filter-only field"
    type: number
    label_from_parameter: sale_price_metric_picker
    sql: {% parameter sale_price_metric_picker %}(${sale_price}) ;;
    value_format_name: usd
  }








#   measure: total_revenue {
#     type: sum
#     sql: ${sale_price} ;;
#     value_format_name: usd
#   }

  measure: cumulative_total_sale_price {
    type: running_total
    sql: ${total_sale_price} ;;
    value_format_name: usd
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

#   measure: total_profit {
#     type: number
#     sql: ${order_items.total_revenue} - ${inventory_items.total_cost} ;;
#     value_format_name: usd
#   }

  measure: percent_of_total_profit {
    type: percent_of_total
    sql: ${total_gross_profit} ;;
  }

  measure: count_growth {
    type: percent_of_previous
    sql: ${count} ;;
  }

  measure: average_gross_profit {
    description: "Average of how much an item sold for minus the cost of that item."
    type: average
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost};;
  }

  measure: total_gross_profit_alt {
    type: sum
    sql: ${gross_profit} ;;
    value_format: "$#,##0.00"
    filters: {
      field: returned_date
      value: "NULL"
    }
  }

  measure: total_gross_profit {
    type: sum
    sql: ${gross_profit} ;;
    value_format: "$#,##0.00"
    drill_fields: [users.id, users.state, products.id, products.item_name, order_items.sale_price, returned_date, users.full_name, users.email]
    filters: {
      field: returned_date
      value: "NULL"
    }
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
    drill_fields: [users.id, users.state, products.id, products.item_name, order_items.sale_price, returned_date, users.full_name, users.email]
    filters: {
      field: returned_date
      value: "NULL"
    }
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: median_sale_price {
    type: median
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: median_gross_profit {
    type: median
    sql: ${gross_profit} ;;
    value_format_name: decimal_2
  }

  measure: 5th_percentile_sale_price {
    type: percentile
    percentile: 5
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: 5th_percentile_gross_profit {
    type: percentile
    percentile: 5
    sql: ${gross_profit} ;;
    value_format_name: decimal_2
  }

  measure: 25th_percentile_sale_price {
    type: percentile
    percentile: 25
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: 25th_percentile_gross_profit {
    type: percentile
    percentile: 25
    sql: ${gross_profit} ;;
    value_format_name: decimal_2
  }

  measure: 75th_percentile_sale_price {
    type: percentile
    percentile: 75
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: 75th_percentile_gross_profit {
    type: percentile
    percentile: 75
    sql: ${gross_profit} ;;
    value_format_name: decimal_2
  }

  measure: 95th_percentile_sale_price {
    type: percentile
    percentile: 95
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: 95th_percentile_gross_profit {
    type: percentile
    percentile: 95
    sql: ${gross_profit} ;;
    value_format_name: decimal_2
  }


  #RANDOM

  dimension: random_value {
    type:  number
    sql: ROUND(RAND()*100, 0) ;;
  }
}
