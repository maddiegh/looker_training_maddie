view: affinity {
  derived_table: {
    sql:
      select
          t3.prod_A_id,
          t3.prod_B_id,
          t3.joint_user_freq,
          t4.joint_order_freq,
          t5.prod_freq as prod_A_freq,
          t6.prod_freq as prod_B_freq

        from
            (
            select  t1.prod_id as prod_A_id,
                    t2.prod_id as prod_B_id,
                    count(*) as joint_user_freq
            from ${user_order_product.SQL_TABLE_NAME} t1
            left join ${user_order_product.SQL_TABLE_NAME} t2
              on t1.user_id = t2.user_id
              and t1.prod_id <> t2.prod_id
            group by 1,2
            ) t3

        left join
            (
            select  t1.prod_id as prod_A_id,
                    t2.prod_id as prod_B_id,
                    count(*) as joint_order_freq
            from ${user_order_product.SQL_TABLE_NAME} t1
            left join ${user_order_product.SQL_TABLE_NAME} t2
              on t1.order_id = t2.order_id
              and t1.prod_id <> t2.prod_id
            group by 1,2
            ) t4
        on t3.prod_A_id = t4.prod_A_id
          and t3.prod_B_id = t4.prod_B_id

        left join ${total_order_product.SQL_TABLE_NAME} t5
        on t3.prod_A_id = t5.product_id


        left join ${total_order_product.SQL_TABLE_NAME} t6
        on t3.prod_B_id = t6.product_id

        ;;
  }

  dimension: prod_A_id {
    sql: ${TABLE}.prod_A_id ;;
  }

  dimension: prod_B_id {
    sql: ${TABLE}.prod_B_id ;;
  }

  dimension: joint_order_freq {
    type: number
    description: "The number of orders that include both product a and product b"
    sql: ${TABLE}.joint_order_freq ;;
  }

  dimension: joint_user_freq {
    type: number
    description: "The number of users who have purchased both product a and product b"
    sql: ${TABLE}.joint_user_freq ;;
  }

  dimension: prod_A_freq {
    type: number
    description: "The total number of times product a has been purchased"
    sql: ${TABLE}.prod_A_freq ;;
  }

  dimension: prod_B_freq {
    type: number
    description: "The total number of times product b has been purchased"
    sql: ${TABLE}.prod_B_freq ;;
  }

  dimension: user_affinity_score {
    #hidden: yes
    type: number
    value_format: "0.00"
    sql: 100*${joint_user_freq}/nullif(${prod_A_freq}+${prod_B_freq}-${joint_user_freq},0) ;;
  }

  measure: mean_user_affinity_score {
    label: "Affinity Score (by User History)"
    description: "Percentage of users that bought both products weighted by how many times each product sold individually"
    value_format: "0.00"
    type: average
    sql: ${user_affinity_score} ;;
  }

  dimension: order_affinity_score {
    hidden: yes
    type: number
    sql: 100*${joint_order_freq}/nullif(${prod_A_freq}+${prod_B_freq}-${joint_order_freq},0) ;;
  }

  measure: mean_order_affinity_score {
    label: "Affinity Score (by Order History)"
    description: "Percentage of orders that contained both products weighted by how many times each product sold individually"
    value_format: "0.00"
    type: average
    sql: ${order_affinity_score} ;;
  }

}



# Products in each order by use

view: user_order_product {
  derived_table: {
    sql:
      select t1.user_id,
                t3.id as prod_id,
                t1.order_id
      from PUBLIC.ORDER_ITEMS t1
      left join PUBLIC.INVENTORY_ITEMS t2
        on t1.inventory_item_id = t2.id
      left join PUBLIC.PRODUCTS t3
        on t2.product_id = t3.id
      group by 1,2,3;;
  }
  dimension: user_id {
    sql: ${TABLE}.user_id ;;
  }

  dimension: prod_id {
    sql: ${TABLE}.prod_id ;;
  }

  dimension: order_id {
    sql: ${TABLE}.order_id ;;
  }
}

#######################################################
# The frequency of each product
view: total_order_product {
  derived_table: {
      sql: select t3.id as product_id,
            count(*) as prod_freq
      from PUBLIC.ORDER_ITEMS t1
      left join PUBLIC.INVENTORY_ITEMS t2
        on t1.inventory_item_id = t2.id
      left join PUBLIC.PRODUCTS t3
        on t2.product_id = t3.id
      group by 1
              ;;
  }

  dimension: product_id {
    sql: ${TABLE}.product_id ;;
  }

  dimension: prod_freq {
    sql: ${TABLE}.prod_freq ;;
  }
}
