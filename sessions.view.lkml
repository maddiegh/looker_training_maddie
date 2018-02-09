include: "looker_training_maddie.model.lkml"

view: sessions5 {
  derived_table: {
    sql:
        select session_id,
          count(*) as number_of_events_in_session,
          max(case when event_type in ('Brand', 'Category') then 1 else 0 end) as browse_or_later,
          max(case when event_type = 'Product' then 1 else 0 end) as view_product_or_later,
          max(case when event_type = 'Cart' then 1 else 0 end) as add_to_cart_or_later,
          max(case when event_type = 'Purchase' then 1 else 0 end) as purchase,
          min(created_at) as session_start,
          max(created_at) as session_end,
          min(id) as landing_event_id,
          max(id) as bounce_event_id,
          max(user_id) as session_user_id

        from PUBLIC.EVENTS
        group by 1
        ;;
  }

  dimension: session_id {
    primary_key: yes
    sql: ${TABLE}.session_id ;;
  }

  dimension: session_user_id {
    type: number
    sql: ${TABLE}.session_user_id ;;
  }

  dimension: number_of_events_in_session {
    sql: ${TABLE}.number_of_events_in_session ;;
  }

  dimension: browse_or_later {
    hidden: yes
    type: number
    sql: ${TABLE}.browse_or_later ;;
  }

  dimension: view_product_or_later {
    hidden: yes
    type: number
    sql: ${TABLE}.view_product_or_later ;;
  }

  dimension: add_to_cart_or_later {
    hidden: yes
    type: number
    sql: ${TABLE}.add_to_cart_or_later ;;
  }

  dimension: purchase {
    hidden: yes
    type: number
    sql: ${TABLE}.purchase ;;
  }

  dimension: landing_event_id {
    type: number
    sql: ${TABLE}.landing_event_id ;;
  }

  dimension: bounce_event_id {
    type: number
    sql: ${TABLE}.bounce_event_id ;;
  }

  dimension_group: session_start {
    type: time
    timeframes: [date,month,time,week,raw]
    sql: ${TABLE}.session_start ;;
  }

  dimension_group: session_end {
    type: time
    timeframes: [date,month,time,week,raw]
    sql: ${TABLE}.session_end ;;
  }

  dimension: duration  {
    label: "Duration (sec)"
    type: number
    sql: datediff('second',${TABLE}.session_start, ${TABLE}.session_end)  ;;
  }

  dimension: duration_tier  {
    label: "Duration Tier (sec)"
    type: tier
    style: integer
    tiers: [10,30,60,120,300]
    sql: ${duration}  ;;
  }

  dimension: furthest_funnel_step {
    type: string
    sql: case when ${purchase} = 1 then '(5) Purchase'
          when ${add_to_cart_or_later} = 1 then '(4) Add to Cart'
          when ${view_product_or_later} = 1 then '(3) View Product'
          when ${browse_or_later} = 1 then '(2) Browse'
        else '(1) Land'
      end
    ;;
  }

  dimension:  includes_browse {
    type: yesno
    sql: ${browse_or_later} = 1 ;;
  }

  dimension:  includes_product {
    type: yesno
    sql: ${view_product_or_later} = 1 ;;
  }

  dimension:  includes_cart {
    type: yesno
    sql: ${add_to_cart_or_later} = 1 ;;
  }

  dimension:  includes_purchase {
    type: yesno
    sql: ${purchase} = 1 ;;
  }

  measure: count {
    type: count
  }

  measure: average_duration {
    label: "Average Duration (sec)"
    type: average
    value_format: "0.00"
    sql: ${duration} ;;
  }


  measure: count_with_cart {
    type: count
    filters: {field:add_to_cart_or_later value: "1"}
  }

  measure: count_with_purchase {
    type: count
    filters: {field:purchase value: "1"}
  }

  dimension: is_bounce_session {
    type: yesno
    sql: ${number_of_events_in_session} = 1 ;;
  }

  measure: count_bounce_sessions {
    type: count
    filters: {field:is_bounce_session value: "Yes"}
  }

  measure: percent_bounce_sessions {
    type: number
    value_format: "0.00%"
    sql: ${count_bounce_sessions}/nullif(${count},0) ;;
  }


  }
