view: products {
  sql_table_name: PUBLIC.PRODUCTS ;;

  dimension: id {
    primary_key: yes
    type: number
    value_format: "0"
    sql: ${TABLE}.ID ;;
  }

  dimension: brand {
    type: string
    sql: TRIM(${TABLE}.BRAND) ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.CATEGORY ;;
  }

  dimension: cost {
    type: number
    hidden: yes
    sql: ${TABLE}.COST ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.DEPARTMENT ;;
  }

  dimension: distribution_center_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.DISTRIBUTION_CENTER_ID ;;
  }

  dimension: item_name {
    type: string
    sql: TRIM(${TABLE}.NAME)  ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.RETAIL_PRICE ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.SKU ;;
  }

  measure: count {
    type: count
    drill_fields: [id, item_name, distribution_centers.id, distribution_centers.name, inventory_items.count]
  }

  measure: brand_count {
    type: count_distinct
    sql: ${brand} ;;
  }

  measure: department_count {
    type: count_distinct
    sql: ${department} ;;
  }

  measure: category_count {
    type: count_distinct
    sql: ${category} ;;
  }

}
