view: orders_alt {
  derived_table: {
    sql: select
        date(created_at) as date,
        count(1) as value
      from orders
      group by 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: value {
    type: string
    sql: ${TABLE}.value ;;
  }

  set: detail {
    fields: [date, value]
  }
}
