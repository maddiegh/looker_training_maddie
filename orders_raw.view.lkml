view: orders_raw {
  derived_table: {
    sql: select * from public.order_items
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_orders {
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [detail*]
  }

  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}.ID ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.ORDER_ID ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.USER_ID ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.INVENTORY_ITEM_ID ;;
  }

  dimension: sale_price_dim {
    type: number
    sql: ${TABLE}.SALE_PRICE ;;
  }

  measure: sale_price {
    type: sum
    sql: ${sale_price_dim} ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.STATUS ;;
  }

  dimension_group: created_at {
    convert_tz: no
    type: time
    timeframes: [raw,date,week,month,month_name,year]
    sql: ${TABLE}.CREATED_AT ;;
  }

  dimension_group: returned_at {
    type: time
    timeframes: [raw,date,week,month,month_name,year]
    sql: ${TABLE}.RETURNED_AT ;;
  }

  dimension_group: shipped_at {
    type: time
    sql: ${TABLE}.SHIPPED_AT ;;
  }

  dimension_group: delivered_at {
    type: time
    sql: ${TABLE}.DELIVERED_AT ;;
  }

  parameter: timeframe {
    type: unquoted
    allowed_value: {
      label: "Month to Date"
      value: "Month"
    }
    allowed_value: {
      label: "Year to Date"
      value: "Year"
    }
  }

  dimension: vs_last_year {
    type:string
    sql:
      case when '{% parameter timeframe %}'= 'Year' and
              date_part('year',${created_at_raw}) = date_part('year',CURRENT_DATE) and to_date(${created_at_raw})  <= CURRENT_DATE  then 'Year - This Year to Date'
        when '{% parameter timeframe %}'= 'Year' and
              date_part('year',${created_at_raw}) + 1 = date_part('year',CURRENT_DATE) and date_part('dayofyear',${created_at_raw}) <= date_part('dayofyear',CURRENT_DATE) then 'Year - Last Year to Date'
        when '{% parameter timeframe %}'= 'Month' and date_part('year',${created_at_raw}) = date_part('year',CURRENT_DATE) and
              date_part('month',${created_at_raw}) = date_part(month,CURRENT_DATE) and to_date(${created_at_raw})  <= CURRENT_DATE  then 'Month - This Year to Date'
        when '{% parameter timeframe %}'= 'Month' and   date_part('year',${created_at_raw}) + 1 = date_part('year',CURRENT_DATE) and
              date_part('month',${created_at_raw}) = date_part('month',CURRENT_DATE) and date_part('dayofyear',${created_at_raw}) <= date_part('dayofyear',CURRENT_DATE) then 'Month - Last Year to Date'

      end;;

  }
    # case
    #   when date_part('{% parameter timeframe %}',${created_at_raw}) = date_part('{% parameter timeframe %}',CURRENT_DATE)   and ${created_at_raw} < CURRENT_DATE
    #     then 'This Year, {% parameter timeframe %} to Date'

    #   when date_part('{% parameter timeframe %}',${created_at_raw}) + 1 = date_part('{% parameter timeframe %}',CURRENT_DATE)
    #           and date_part('dayof{% parameter timeframe %}',${created_at_raw}) <= date_part('dayof{% parameter timeframe %}',CURRENT_DATE)
    #     then 'Last Year, {% parameter timeframe %} to Date'
    # end;;

  set: detail {
    fields: [
      id,
      order_id,
      user_id,
      inventory_item_id,
      sale_price,
      status,
      shipped_at_time,
      delivered_at_time
    ]
  }
}
