view: user_order_facts {
  derived_table: {
#   # Or, you could make this view a derived table, like this:
  sql: |
  SELECT
  orders.user_id as user_id
  , COUNT(*) as lifetime_items
  , COUNT(DISTINCT order_items.order_id) as lifetime_orders
  , MIN(NULLIF(orders.created_at,0)) as first_order
  , MAX(NULLIF(orders.created_at,0)) as latest_order
  , COUNT(DISTINCT DATE_TRUNC('month', NULLIF(orders.created_at,0)))
  as number_of_distinct_months_with_orders
  , SUM(order_items.sale_price) as lifetime_revenue
  FROM order_items
  LEFT JOIN orders ON order_items.order_id=orders.id
  GROUP BY user_id;;
  }


  dimension: user_id {
    description: "Unique ID for each user that has ordered"
    type: number
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
    type: yesno
    sql: ${lifetime_orders} >= 1 AND ${lifetime_orders} <= 3;;
  }

  dimension: four_plus_customer {
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
    sql: DATEDIFF('day', ${TABLE}.first_order, ${TABLE}.latest_order)+1;;
    }

  measure: count {
    type: count
    drill_fields: [user_id, repeat_customer]
  }
}
