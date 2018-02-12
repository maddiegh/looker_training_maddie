view: users {
  sql_table_name: PUBLIC.USERS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.AGE ;;
  }

  dimension: age_tier {
    type: tier
    style: integer
    tiers: [0,10,20,30,40,50,60,70]
    sql: ${TABLE}.AGE ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: aprox_location {
    type: location
    sql_latitude: round(${TABLE}.latitude,1) ;;
    sql_longitude: round(${TABLE}.longitude,1) ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.CITY ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.COUNTRY ;;
  }

  dimension_group: created {
    type: time
    # timeframes: [
    #   raw,
    #   time,
    #   date,
    #   week,
    #   month,
    #   quarter,
    #   year
    # ]
    sql: ${TABLE}.CREATED_AT ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL ;;
  }

  dimension: first_name {
    type: string
    hidden: yes
    sql: ${TABLE}.FIRST_NAME ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.GENDER ;;
  }

  dimension: gender_short {
    type: string
    sql: lower(substr(${TABLE}.GENDER,1,1)) ;;
  }

  dimension: last_name {
    type: string
    hidden: yes
    sql: ${TABLE}.LAST_NAME ;;
  }

  dimension: latitude {
    type: number
    hidden: yes
    sql: ${TABLE}.LATITUDE ;;
  }

  dimension: longitude {
    type: number
    hidden: yes
    sql: ${TABLE}.LONGITUDE ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.STATE ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.TRAFFIC_SOURCE ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.ZIP ;;
  }

  dimension: UK_postcode {
    map_layer_name: uk_postcode_areas
    sql: case when substr(${zip}, 2, 1) in ('0','1','2','3','4','5','6','7','8','9')
         then upper(left(${zip}, 1))
         else upper(left(${zip}, 2)) end ;;
  }

  parameter: fields_to_filter_on {
    type: string
    hidden: yes
    allowed_value: { value: "gender" }
    allowed_value: { value: "age_tier" }
    allowed_value: { value: "state" }
  }

  dimension: metric {
    label_from_parameter:  fields_to_filter_on
    hidden: yes
    type: string
    sql: case when {% parameter fields_to_filter_on %} = 'gender' then ${gender}
            when {% parameter fields_to_filter_on %} = 'age_tier' then ${age_tier}
            when {% parameter fields_to_filter_on %} = 'state' then ${state}
      end
    ;;
  }


  measure: count {
    type: count
    drill_fields: [id, first_name, last_name, events.count, order_items1.count]
  }

  measure: average_age {
    type: average
    sql: ${TABLE}.AGE ;;
  }

  measure: count_percent_of_total {
    label: "Count (Percent of Total)"
    type: percent_of_total
    sql: ${count} ;;
  }

}
