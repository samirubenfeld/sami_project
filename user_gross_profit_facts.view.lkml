view: user_gross_profit_facts {
  derived_table: {
    sql: SELECT u.id AS "user_id"
        , SUM(CASE WHEN o.created_at <= u.created_at + INTERVAL 24 HOUR THEN (oi.sale_price - ii.cost) ELSE 0 END) AS 24_hour_gross_profit
        , SUM(CASE WHEN o.created_at <= u.created_at + INTERVAL 30 DAY THEN (oi.sale_price - ii.cost) ELSE 0 END) AS 30_day_gross_profit
        , SUM(CASE WHEN o.created_at <= u.created_at + INTERVAL 90 DAY THEN (oi.sale_price - ii.cost) ELSE 0 END) AS 90_day_gross_profit
        , SUM(CASE WHEN o.created_at <= u.created_at + INTERVAL 365 DAY THEN (oi.sale_price - ii.cost) ELSE 0 END) AS 365_day_gross_profit
      FROM order_items AS oi
      LEFT JOIN orders AS o ON o.id = oi.order_id
      LEFT JOIN users AS u ON u.id = o.user_id
      LEFT join inventory_items AS ii on ii.id = oi.inventory_item_id
      GROUP BY 1
       ;;
    indexes: ["user_id"]  #Builds an index on the PDT for faster joins
#     persist_for: "12 hours" #Indicates to 'persist' this to the db as a PDT.  I.e. create table.  Table will rebuild after 12 hours
  }

  dimension: user_id {
    primary_key: yes
    hidden: no
  }



  dimension: 24_hour_gross_profit {
    type: number
    value_format_name: decimal_2
  }

  dimension: 30_day_gross_profit {
    type: number
    value_format_name: decimal_2
  }

  dimension: 90_day_gross_profit {
    type: number
    value_format_name: decimal_2
  }

  dimension: 365_day_gross_profit {
    type: number
    value_format_name: decimal_2
  }

  dimension: 30_day_gp_tier {
    type: tier
    tiers: [0, 5, 10, 25, 50, 100, 250]
    sql: ${24_hour_gross_profit} ;;
  }

  measure: total_24_hour_gp {
    type: sum
    sql: ${24_hour_gross_profit} ;;
    value_format_name: decimal_2
  }

  measure: average_24_hour_gp {
    type: average
    sql: ${24_hour_gross_profit} ;;
    value_format_name: decimal_2
  }

  measure: total_30_day_gp{
    type: sum
    sql: ${30_day_gross_profit} ;;
    value_format: "$#,##0.00"
  }

  measure: average_30_day_gp {
    type: average
    sql: ${30_day_gross_profit} ;;
    value_format: "$#,##0.00"
  }

  measure: total_90_day_gp {
    type: sum
    sql: ${90_day_gross_profit} ;;
    value_format: "$#,##0.00"
  }

  measure: average_90_day_gp {
    type: average
    sql: ${90_day_gross_profit} ;;
    value_format: "$#,##0.00"
  }

  measure: total_365_day_gp {
    type: sum
    sql: ${365_day_gross_profit} ;;
    value_format: "$#,##0.00"
  }

  measure: average_365_day_gp {
    type: average
    sql: ${365_day_gross_profit} ;;
    value_format: "$#,##0.00"
  }
}
