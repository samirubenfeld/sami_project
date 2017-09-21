connection: "the_look"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"





explore: events {
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
  join: order_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }
}

explore: order_items {

  view_label: "General Order Info"
  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: orders {
    type: left_outer
    sql_on: ${order_items.order_id} = ${orders.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_data {
    type: left_outer
    sql_on: ${user_data.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts {
    type: left_outer
    sql_on: ${user_order_facts.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_gross_profit_facts {
    type: left_outer
    sql_on: ${user_gross_profit_facts.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

# explore: order_items_returned {}

explore: orders {
  sql_always_where: ${created_date} >= '2012-01-01' ;;
  join: users {
    type: left_outer
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: products {
  join: inventory_items {
    type: left_outer
    sql_on: ${products.id} = ${inventory_items.product_id};;
    relationship: many_to_one
  }
  join: order_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }
}

explore: user_order_facts {

}



explore: user_data {
  join: users {
    type: left_outer
    sql_on: ${user_data.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

explore: users {
  always_filter: {
    filters: {
      field: users.age
      value: "25"
    }
  }
  join: orders {
    type:  inner
    sql_on: ${users.id} = ${orders.user_id} ;;
    relationship: one_to_many
    }




}
