view: inventory_items {
  sql_table_name: PUBLIC.INVENTORY_ITEMS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
  }

  dimension: cost {
    type: number
    value_format: "\"£\"#,##0.00"
    sql: ${TABLE}.COST ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month
    ]
    sql: ${TABLE}.CREATED_AT ;;
  }

  dimension: product_brand {
    type: string
    hidden: yes
    sql: ${TABLE}.PRODUCT_BRAND ;;
  }

  dimension: product_category {
    type: string
    hidden: yes
    sql: ${TABLE}.PRODUCT_CATEGORY ;;
  }

  dimension: product_department {
    type: string
    hidden: yes
    sql: ${TABLE}.PRODUCT_DEPARTMENT ;;
  }

  dimension: product_distribution_center_id {
    type: number
    hidden: yes
    sql: ${TABLE}.PRODUCT_DISTRIBUTION_CENTER_ID ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.PRODUCT_ID ;;
  }

  dimension: product_name {
    type: string
    hidden: yes
    sql: ${TABLE}.PRODUCT_NAME ;;
  }

  dimension: product_retail_price {
    type: number
    hidden: yes
    sql: ${TABLE}.PRODUCT_RETAIL_PRICE ;;
  }

  dimension: product_sku {
    type: string
    hidden: yes
    sql: ${TABLE}.PRODUCT_SKU ;;
  }

  dimension_group: sold {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month
    ]
    sql: ${TABLE}.SOLD_AT ;;
  }

  dimension: days_in_inventory {
    description: "days between created and sold date"
    type: number
    sql: DATEDIFF('day',${created_raw}, coalesce(${sold_raw},CURRENT_DATE));;
  }

  dimension: days_in_inventory_tier {
    type: tier
    tiers: [0,5,10,20,40,80,160,360]
    sql: ${days_in_inventory} ;;
    style: integer
  }

  dimension: days_since_arrival {
    description: "days since created"
    type: number
    sql: DATEDIFF('day',${created_raw}, CURRENT_DATE);;
  }

  dimension: days_since_arrival_tier {
    type: tier
    tiers: [0,5,10,20,40,80,160,360]
    sql: ${days_since_arrival} ;;
    style: integer
  }

  dimension: is_sold {
    label: "Is Sold (Yes/No)"
    type: string
    sql: case when ${sold_raw} is null then 'No'
        else 'Yes'
        end;;
  }

  measure: average_cost {
    type: average
    value_format: "\"£\"#,##0.00"
    sql: ${cost};;
  }

  measure: count {
    type: count
    drill_fields: [id, product_name, products.id, products.name, order_items1.count]
  }

  measure: number_on_hand {
    type: count
    filters: {
      field: is_sold
      value: "No"
    }
  }

  measure: sold_count {
    type: count
    filters: {
      field: is_sold
      value: "Yes"
    }
  }

  measure: sold_percent {
    type: number
    value_format: "0.00\%"
    sql: 100.0 * ${sold_count}/NULLIF(${count},0) ;;
  }

  measure: trailing_28d_sales {
    type: count
    hidden: yes
    filters: {
      field: sold_date
      value: "last 28 days"
    }
  }

  measure: stock_coverage_ratio {
    description: "Stock on hand vs trailing 28d Sales Ratio"
    type: number
    value_format: "0.00"
    sql: ${number_on_hand}/NULLIF(${trailing_28d_sales},0) ;;
    html:
    {% if value > 1 %}
    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% elsif value < 1 %}
    <p style="color: black; background-color: lightred; font-size:100%; text-align:center">{{ rendered_value }}</p>
     {% endif %}
    ;;
  }

  measure: total_cost {
    type: sum
    value_format: "\"£\"#,##0.00"
    sql: ${cost};;
    }
}
