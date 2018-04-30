 connection: "snowlooker"

#  include all the views
 include: "*.view"  #include all the views

#  include all the dashboards
 include: "*.dashboard"

 datagroup: looker_training_maddie_default_datagroup {
   sql_trigger: SELECT MAX(id) FROM etl_log;;
   max_cache_age: "1 hour"
 }

 persist_with: looker_training_maddie_default_datagroup

 explore: distribution_centers {}

 explore: etl_jobs {}

 explore: events1 {
   view_label: "Events"
   label: "(2) Web Event Data"
   join: users {
     type: left_outer
     sql_on: ${events1.user_id} = ${users.id} ;;
     relationship: many_to_one
   }

   join: sessions5 {
     view_label: "Sessions"
     type: left_outer
     sql_on: ${events1.session_id} = ${sessions5.session_id} ;;
     relationship: many_to_one

   }

   join: user_order_fact {
     type: left_outer
     sql_on: ${users.id} = ${user_order_fact.user_id};;
     relationship: many_to_one
   }

   join: products {
     view_label: "Product Viewed"
     type: left_outer
     sql_on: ${events1.viewed_product_ID} = ${products.id};;
     relationship: many_to_one
   }

   join: session_bounce_page {
     from: events1
     type: left_outer
     sql_on: ${sessions5.bounce_event_id} = ${session_bounce_page.event_id} ;;
     fields: [session_list*]
     relationship: many_to_one
   }

   join: session_landing_page {
     from: events1
     type: left_outer
     sql_on: ${sessions5.landing_event_id} = ${session_landing_page.event_id} ;;
     fields: [session_list*]
     relationship: many_to_one
   }
 }

 explore: inventory_items {
   join: products {
     type: left_outer
     sql_on: ${inventory_items.product_id} = ${products.id} ;;
     relationship: many_to_one
   }

   join: distribution_centers {
     type: left_outer
     sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
     relationship: many_to_one
   }

   join: order_items1 {
     type: left_outer
     sql_on: ${inventory_items.id} = ${order_items1.inventory_item_id};;
     relationship: one_to_many
   }

   join: order_fact1 {
     view_label: "Orders"
     type: left_outer
     sql_on: ${order_items1.order_id} = ${order_fact1.order_id}  ;;
     relationship: many_to_one
   }

   join: users {
     type: left_outer
     sql_on: ${order_items1.user_id} = ${users.id};;
     relationship: one_to_many
   }

   join: repeat_orders {
     view_label: "Repeat Purchase Facts"
     type: left_outer
     sql_on: ${order_items1.order_id} = ${repeat_orders.order_id}  ;;
     relationship: many_to_one
   }

   join: user_order_fact {
     type: left_outer
     sql_on: ${users.id} = ${user_order_fact.user_id};;
     relationship: many_to_one
   }

 }

 explore: order_items1 {
   label: "(1) Orders, Items and Users"
   view_label: "Order Items"
     join: users {
     type: left_outer
     sql_on: ${order_items1.user_id} = ${users.id} ;;
     relationship: many_to_one
   }

   join: inventory_items {
     type: full_outer
     sql_on: ${order_items1.inventory_item_id} = ${inventory_items.id} ;;
     relationship: one_to_one
   }

   join: products {
     type: left_outer
     sql_on:  ${products.id} = ${inventory_items.product_id} ;;
     relationship: many_to_one
   }

   join: distribution_centers {
     type: left_outer
     sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
     relationship: many_to_one
   }

   join: order_fact1 {
     view_label: "Orders"
     type: left_outer
     sql_on: ${order_items1.order_id} = ${order_fact1.order_id}  ;;
     relationship: many_to_one
   }

   join: repeat_orders {
     view_label: "Repeat Purchase Facts"
     type: left_outer
     sql_on: ${order_items1.order_id} = ${repeat_orders.order_id}  ;;
     relationship: many_to_one
   }

   join: user_order_fact {
     type: left_outer
     sql_on: ${users.id} = ${user_order_fact.user_id};;
     relationship: many_to_one
   }

   }

 explore: products {
   join: distribution_centers {
     type: left_outer
     sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
     relationship: many_to_one
   }
   }

 explore: users {}


 explore: repeat_orders {}


 explore: affinity {
   label: "(4) Affinity Analysis"
 }

explore: orders_raw {}
