connection: "the_look"


# include all the views
include: "*.view"
include: "bq.*.view"
# include: "bq.explore.lkml"

# include all the dashboards
include: "*.dashboard"
# include: "/test_datablocks/bq.*.view.lkml"
# include: "/test_datablocks/bq.explore.lkml"


map_layer: my_neighborhood_layer {
  url: "https://www.dropbox.com/s/v8rs0zarjmdy99o/cb_2014_48_tract_500k.json?dl=0"
  property_key: "neighborhood"
}



map_layer: my_california_layer {
  url: "https://www.dropbox.com/s/bdt59bats1ngyku/tl_2010_06_zcta510.json?dl=0"
}



explore: events {
  hidden: yes
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
  join: orders {
    type: left_outer
    sql_on: ${order_items.order_id} = ${orders.id} ;;
    relationship: many_to_one
  }
}

explore: order_items {
  label: "Order Items 📈"
 view_label: "General Order Info "
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
  hidden: yes
  sql_always_where: ${created_date} >= '2012-01-01' ;;
  join: users {
    type: left_outer
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}




# explore: user_data {
#   join: users {
#     type: left_outer
#     sql_on: ${user_data.user_id} = ${users.id} ;;
#     relationship: many_to_one
#   }
# }

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
