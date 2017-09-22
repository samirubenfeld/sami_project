view: users {
  sql_table_name: demo_db.users ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;

    link: {
      label: "User Dashboard"
      url: "/dashboards/2?ID={{ _filters['users.id'] | url_encode }}"
      icon_url: "http://looker.com/favicon.ico"
    }
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: city {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}.city ;;
  }

  measure: nyc_count {
    type: count
    drill_fields: [detail*]
    filters: {
      field: users.city
      value: "New York"
    }
    link: {
      label: "Regional Dash: New York City"
      url: "/dashboards/4?City={{ _filters['users.city'] | url_encode }}"
      icon_url: "http://looker.com/favicon.ico"
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
    link: {
      label: "Send Email"
      url: "mailto:{{value}}"
      icon_url: "https://lh6.ggpht.com/8-N_qLXgV-eNDQINqTR-Pzu5Y8DuH0Xjz53zoWq_IcBNpcxDL_gK4uS_MvXH00yN6nd4=w300"
    }
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
      url: "/dashboards/2?Full%20Name={{ value }}"
      icon_url: "http://looker.com/favicon.ico"
    }
    link: {
      label: "Send Email"
      url: "mailto:{{email}}"
      icon_url: "https://lh6.ggpht.com/8-N_qLXgV-eNDQINqTR-Pzu5Y8DuH0Xjz53zoWq_IcBNpcxDL_gK4uS_MvXH00yN6nd4=w300"
    }
    # link: {
    #   label: "User Dash Alt"
    #   url: "/dashboards/2?Full%20Name={{ _filters['users.full_name'] | url_encode }}&Users%20ID={{ _filters['users.id'] | url_encode }}"
    # }
  }

  filter: state_select {
    suggest_dimension: state
  }

  dimension: state_comparitor {
    sql:
      CASE WHEN {% condition state_select %} ${state} {% endcondition %}
      THEN ${state}
      ELSE 'Rest Of Population'
      END;;
  }



  dimension: state {
    type: string
    map_layer_name: us_states
    drill_fields: [detail*]
    sql: ${TABLE}.state ;;
  }

  filter: full_name_select {
    suggest_dimension: full_name
  }

  dimension: full_name_comparitor {
    sql:
      CASE WHEN {% condition full_name_select %} ${full_name} {% endcondition %}
      THEN ${full_name}
      ELSE 'Rest Of Population'
      END;;
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
      orders.id,
      full_name,
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

  measure: men_count {
    type: count
    filters: {
      field: gender
      value: "Male"
    }
  }

  measure: female_count {
    type: count
    filters: {
      field: gender
      value: "Female"
    }
  }



  measure: us_count {
    type: count   # COUNT(CASE WHEN user.country = ‘US’ THEN 1 ELSE NULL END)
    drill_fields: [detail*]   # Also, when drilling, adds the filter users.country=’US’
    filters: {
      field: users.country
      value: "US"
    }
  }
}
