include: "looker_training_maddie.model.lkml"
view: order_fact1 {
  derived_table: {
      explore_source: order_items1 {
        column: order_id {}
        column: items_in_order {field:order_items1.count}
        column: order_amount {field:order_items1.total_sale_price}
        column: order_cost {field:inventory_items.total_cost}
        column: user_id {field:order_items1.user_id}
        column: created_at {field:order_items1.created_raw}
        derived_column: order_sequence_number {
          sql: rank() over (partition by user_id order by created_at);;
          }
    }

  }

  dimension: order_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: items_in_order {
    type: number
    sql: ${TABLE}.items_in_order ;;
  }

  dimension: order_amount {
    type: number
    sql: ${TABLE}.order_amount ;;
  }

  dimension: order_cost {
    type: number
    sql: ${TABLE}.order_cost ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: created_at {
    type: number
    hidden: yes
    sql: ${TABLE}.created_at ;;
  }

  dimension: order_sequence_number {
    type: number
    sql: ${TABLE}.order_sequence_number ;;
  }

  dimension: months_since_signup {
    type: number
    sql: datediff('month',${users.created_raw}, ${created_at}) ;;
  }

  dimension: is_first_purchase {
    label: "Is First Purchase (Yes / No)"
    sql: case when ${order_sequence_number} = 1 then 'Yes'
          when ${order_sequence_number} > 1 then 'No'
    end;;
  }

  measure: first_purchase_count {
    view_label: "Orders"
    type: count_distinct
    sql: ${order_id} ;;
    filters: {
      field: is_first_purchase
      value: "Yes"
    }
  }


}
