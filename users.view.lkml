view: users {
  sql_table_name: demo_db.users ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  measure: nyc_count {
    type: count
    drill_fields: [detail*]
    filters: {
      field: users.city
      value: "New York"
    }
  }

  measure: sf_count {
    type: count
    drill_fields: [detail*]
    filters: {
      field: users.city
      value: "San Francisco"
    }
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }



  dimension_group: created {
    type: time
    timeframes: [
      raw,
      day_of_month,
      day_of_week,
      day_of_year,
      hour_of_day,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80]
    style: classic # the default value, could be excluded
    sql: ${age} ;;
  }


  dimension: age_tier_split {
    type: tier
    tiers: [0, 26, 49]
    style: classic # the default value, could be excluded
    sql: ${age} ;;
  }



  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: city_state {
    type: string
    sql: CONCAT(${TABLE}.city, ', ', ${TABLE}.state);;
    link: {
      label: "User Dashboard"
      url: "/dashboards/2?City%20State={{ value }}"
      icon_url: "http://looker.com/favicon.ico"
    }
  }




  dimension: full_name {
    type: string
    sql: CONCAT(${TABLE}.first_name, ' ', ${TABLE}.last_name);;
    link: {
      label: "User Dashboard"
      url: "/dashboards/2?Full%20Name={{ _filters['users.full_name'] | url_encode }}"
      # url: "/dashboards/2?Full%20Name={{ value }}"
      icon_url: "http://looker.com/favicon.ico"
    }
  }




  dimension: state {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}.state ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      last_name,
      orders.id,
      first_name,
      events.count,
      orders.count,
      products.count,
      user_data.count,
      users.age,
      users.zipcode
    ]
  }


  measure: average_age {
    type: average
    sql: ${TABLE}.age ;;
    value_format_name: decimal_2

  }

#   filter: brand_select { … }
#
#   dimension: brand_comparitor {
#     sql:
#     CASE
#       WHEN {% condition brand_select %} ${products.brand_name} {% endcondition %}
#       THEN ${products.brand_name}
#       ELSE 'All Other Brands'
#     END ;;
#   }

  measure: us_count {
    type: count   # COUNT(CASE WHEN user.country = ‘US’ THEN 1 ELSE NULL END)
    drill_fields: [detail*]   # Also, when drilling, adds the filter users.country=’US’
    filters: {
      field: users.country
      value: "US"
    }
  }
}
