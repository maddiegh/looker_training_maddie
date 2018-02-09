include: "looker_training_maddie.model.lkml"
include: "order_items1.view.lkml"

view: repeat_orders {
  derived_table: {
    sql:
      select
            t1.order_id,
            count(distinct t2.order_id) as number_subsequent_orders,
            min(t2.created_raw) as next_order_date,
            min(t2.order_id) as next_order_id
          from order_items1 t1
      left join order_items1 t2
      on t1.user_id = t2.user_id
      and t1.created_raw < t2.created_raw
      group by 1
            ;;
  }

  dimension: order_id {
    hidden: yes
    sql:${TABLE}.order_id ;;
  }

  dimension: number_subsequent_orders {
    sql:${TABLE}.number_subsequent_orders ;;
  }

  dimension: next_order_date {
    hidden: yes
    sql:${TABLE}.next_order_date ;;
  }

  dimension: next_order_id {
    hidden: yes
    sql:${TABLE}.next_order_id ;;
  }


}
