view: distribution_centers {
  sql_table_name: PUBLIC.DISTRIBUTION_CENTERS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
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

  dimension: location {
    type: location
    sql_longitude: ${TABLE}.LONGITUDE ;;
    sql_latitude: ${TABLE}.LATITUDE;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  measure: count {
    type: count
    hidden: yes
    drill_fields: [id, name, products.count]
  }
}
