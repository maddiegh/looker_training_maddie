view: order_items1 {
  sql_table_name: PUBLIC.ORDER_ITEMS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week,
      hour,
      hour_of_day,
      week,
      week_of_year,
      month,
      month_num,
      year
    ]
    sql: ${TABLE}.CREATED_AT ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month
    ]
    sql: ${TABLE}.DELIVERED_AT ;;
  }

  dimension: days_to_process {
    type: number
    sql: case
    when ${status} = 'Processing' then datediff('day',${created_raw},CURRENT_DATE())
    when ${status} IN ('Shipped', 'Complete', 'Returned') then datediff('day',${created_raw},${shipped_raw})
    when ${status} = 'Cancelled' then NULL
    end;;
  }


  dimension: inventory_item_id {
    type: number
    hidden: yes
    sql: ${TABLE}.INVENTORY_ITEM_ID ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.ORDER_ID ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month
    ]
    sql: ${TABLE}.RETURNED_AT ;;
  }

  dimension: sale_price {
    type: number
    value_format: "\"£\"#,##0.00"
    sql: ${TABLE}.SALE_PRICE ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month
    ]
    sql: ${TABLE}.SHIPPED_AT ;;
  }

  dimension: shipping_time {
    type: number
    sql: datediff('day',${shipped_raw},${delivered_raw});;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.STATUS ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: gross_margin {
    type: number
    value_format: "\"£\"0.00"
    sql: ${sale_price}-${inventory_items.cost} ;;
  }

  dimension: is_returned {
    label: "Is Returned (Yes/No)"
    type: string
    sql: case when ${returned_raw} is not null then 'Yes'
        else 'No'
      end;;
  }

  dimension: item_gross_margin_percentage {
    type: number
    value_format: "0.00%"
    sql: ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    type: tier
    value_format: "\"£\"#,##0.00"
    tiers: [0.0,10.0,20.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0]
    sql: ${gross_margin}/NULLIF(${sale_price},0) ;;
    style: interval
  }

  dimension: reporting_period {
    type: string
    sql:
       case
        when date_part('year',${created_raw}) = date_part('year',CURRENT_DATE)
        and ${created_raw} < CURRENT_DATE
        then 'This Year to Date'

        when date_part('year',${created_raw}) + 1 = date_part('year',CURRENT_DATE)
        and date_part('dayofyear',${created_raw}) <= date_part('dayofyear',CURRENT_DATE)
        then 'Last Year to Date'

      end;;
  }

  dimension: days_until_next_order {
    view_label: "Repeat Purchase Facts"
    type: number
    sql: datediff('days',${created_raw},${repeat_orders.next_order_date})  ;;
  }

  dimension: has_subsequent_order {
    view_label: "Repeat Purchase Facts"
    type: yesno
    sql: ${repeat_orders.next_order_id} is not null  ;;
  }


  dimension: repeat_orders_within_30d {
    view_label: "Repeat Purchase Facts"
    type: yesno
    sql: ${days_until_next_order} <= 30 ;;
  }


  measure: count_with_repeat_purchase_within_30d {
    view_label: "Repeat Purchase Facts"
    type: count
    filters: {field:repeat_orders_within_30d value: "Yes"}
  }

  measure:  30_day_repeat_purchase_rate{
    view_label: "Repeat Purchase Facts"
    description: "Percentage of customers who purchase again within 30 days"
    type: number
    value_format: "0.00%"
    sql: 100*${count_with_repeat_purchase_within_30d}/NULLIF(${count},0)  ;;
  }

    measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: average_days_to_process {
    type: average
    value_format: "0.00"
    sql: ${days_to_process} ;;
  }

  measure: average_gross_margin {
    type: average
    value_format: "0.00"
    sql: ${gross_margin} ;;
  }

  measure: average_sale_price {
    type: average
    value_format: "\"£\"#,##0.00"
    sql: ${sale_price} ;;
  }

  measure: average_shipping_time {
    type: average
    value_format: "0.00"
    sql: ${shipping_time} ;;
  }

  measure: total_sale_price {
    type: sum
    value_format: "\"£\"#,##0.00"
    sql: ${sale_price} ;;
  }

  measure: median_sale_price {
    type: median
    value_format: "\"£\"#,##0.00"
    sql: ${sale_price} ;;
  }

  measure: total_gross_margin {
    type: sum
    value_format: "\"£\"#,##0.00"
    sql: ${gross_margin} ;;
  }

  measure: total_gross_margin_percentage {
    type: number
    value_format: "0.00%"
    sql: sum(${gross_margin})/sum(NULLIF(${sale_price},0)) ;;
  }

  measure: average_spend_per_user {
    type: number
    value_format: "\"£\"#,##0.00"
    sql: ${total_sale_price}/NULLIF(${users.count},0) ;;
  }

  measure: returned_count {
    type: count
    filters: {
      field: status
      value: "Returned"
    }
  }

  measure: returned_total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format: "\"£\"#,##0.00"
    filters: {
      field: status
      value: "Returned"
    }
  }

  measure: returned_rate {
    type: number
    sql: ${returned_count}/NULLIF(${count},0) ;;
    value_format: "0.00%"
  }

  measure: order_count {
    view_label: "Orders"
    type: count_distinct
    drill_fields: [detail*]
    sql: ${order_id} ;;
  }

  measure: month_count {
    hidden: yes
    type:count_distinct
    sql: ${created_month} ;;
  }

  measure: first_order {
    hidden: yes
    type: min
    sql: ${created_raw} ;;
  }

  measure: latest_order {
    hidden: yes
    type: max
    sql: ${created_raw} ;;
  }

    # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.id,
      users.first_name,
      users.last_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
