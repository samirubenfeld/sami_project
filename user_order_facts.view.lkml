view: user_order_facts {
  derived_table: {
  sql:
  SELECT
  orders.user_id as user_id
  , COUNT(*) as lifetime_items
  , COUNT(DISTINCT order_items.order_id) as lifetime_orders
  , MIN(DATE(orders.created_at)) AS first_order
  , MAX(DATE(orders.created_at)) AS latest_order
  , SUM(order_items.sale_price) as lifetime_revenue
  , SUM(order_items.sale_price - inventory_items.cost) as lifetime_gross_margin
  FROM order_items
  LEFT JOIN orders ON order_items.order_id=orders.id
  LEFT JOIN inventory_items ON order_items.inventory_item_id = inventory_items.id
  GROUP BY user_id;;
  }




  dimension: user_id {
    description: "Unique ID for each user that has ordered"
    type: number
    primary_key: yes
    sql: ${TABLE}.user_id ;;
   }

    dimension: lifetime_items {
    type: number
    sql: COALESCE(${TABLE}.lifetime_items,0);;
    }

  dimension: lifetime_orders {
  type: number
  sql: COALESCE(${TABLE}.lifetime_orders,0);;
  }

  dimension: lifetime_orders_tiered {
    type: tier
    tiers: [0,1,2,3,5,10]
    sql: ${lifetime_orders};;
    }

  dimension: lifetime_revenue {
    type: number
    sql: COALESCE(${TABLE}.lifetime_revenue, 0);;
    value_format_name: usd
    }

  dimension: lifetime_gross_margin {
    type: number
    sql: COALESCE(${TABLE}.lifetime_gross_margin, 0);;
    value_format_name: usd
  }

  dimension: lifetime_revenue_tiered {
    type: tier
    sql: ${lifetime_revenue};;
    tiers: [0,0.01,20,50,100,500,1000,10000]
    }

  dimension: repeat_customer {
    type: yesno
    sql: ${lifetime_orders} > 1;;
    }

  dimension: one_to_three_customer {
    description: "Users who have made between 1 and 3 orders"
    type: yesno
    sql: ${lifetime_orders} >= 1 AND ${lifetime_orders} <= 3;;
  }

  dimension: four_plus_customer {
    description: "Users who have made 4+ orders"
    type: yesno
    sql: ${lifetime_orders} > 4;;
  }

  dimension_group: first_order {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.first_order;;
    }

   dimension_group: latest_order {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.latest_order;;
    }

  dimension: days_as_customer {
    type: number
    sql: ABS(DATEDIFF(${TABLE}.first_order, ${TABLE}.latest_order)+1);;
    }

  measure: count {
    type: count
    drill_fields: [users.full_name, user_id, repeat_customer]
  }
}
