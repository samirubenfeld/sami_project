view: products {
  sql_table_name: demo_db.products ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}.item_name ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}.rank ;;
  }


  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
    value_format_name: usd
  }

  measure: total_retail_price {
    type: sum
    sql: ${retail_price} ;;
    value_format_name: usd
  }

  measure: average_retail_price {
    type: average
    sql: ${retail_price} ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  measure: category_list {
    type: string
    sql: GROUP_CONCAT(${category}) ;;
  }

  measure: count {
    type: count
    drill_fields: [
      id,
      item_name,
      retail_price,
      sku,
      department,
      rank,
      brand,
      category,
      inventory_items.count
    ]
  }

}
