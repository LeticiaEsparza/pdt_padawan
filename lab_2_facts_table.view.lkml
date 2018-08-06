view: lab_2_facts_table {
  derived_table: {
    sql: SELECT
          users.id AS user_id,
          CASE WHEN COUNT(DISTINCT CONCAT(users.city,", ",users.state,", ",CAST(users.zip AS CHAR))) > 1 THEN "yes"
             ELSE "no"
             END AS has_moved,
             COALESCE(SUM(order_items.sale_price ), 0) AS total_spent,
             COUNT(DISTINCT demo_db.orders.id) AS total_orders,
             COUNT(DISTINCT demo_db.order_items.id) AS num_order_items,
             COUNT(DISTINCT demo_db.order_items.id)/COUNT(DISTINCT demo_db.orders.id) AS avg_items_per_order,
             COALESCE(AVG(order_items.sale_price), 0) AS avg_sale_price,
             (

      SELECT
        COUNT(DISTINCT orders.id ) AS count_orders_completed
      FROM demo_db.order_items  AS order_items
      LEFT JOIN demo_db.orders  AS orders ON order_items.order_id = orders.id
      LEFT JOIN demo_db.users  AS users ON orders.user_id = users.id
      WHERE
        (orders.status = 'complete')

      ) as total_orders_completed,
      SUM(CASE WHEN orders.status = 'complete' THEN 1 ELSE 0 END) count_orders_completed,

      (

      SELECT
        COUNT(DISTINCT orders.id ) AS total_orders_completed
      FROM demo_db.order_items  AS order_items
      LEFT JOIN demo_db.orders  AS orders ON order_items.order_id = orders.id
      LEFT JOIN demo_db.users  AS users ON orders.user_id = users.id
      WHERE
        (orders.status = 'pending')

      ) as total_orders_pending,
      SUM(CASE WHEN orders.status = 'pending' THEN 1 ELSE 0 END) count_orders_pending,

             -- Other fun facts
             MIN(NULLIF(orders.created_at,0)) as first_order,
             MAX(NULLIF(orders.created_at,0)) as latest_order


      FROM demo_db.order_items  AS order_items
      LEFT JOIN demo_db.orders  AS orders ON order_items.order_id = orders.id
      LEFT JOIN demo_db.users  AS users ON orders.user_id = users.id

      GROUP BY 1
 ;;
    sql_trigger_value: SELECT current_date;;
    indexes: ["user_id"]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: has_moved {
    type: string
    sql: ${TABLE}.has_moved ;;
  }

  dimension: has_moved_yesno {
    description: " A yesno reflecting if they’ve moved"
    type: yesno
    sql: ${has_moved}="yes" ;;
  }

  dimension: total_spent {
    description: " The total amount they’ve spent"
    type: number
    sql: ${TABLE}.total_spent ;;
    value_format_name: usd
  }

  dimension: total_orders {
    label: "Number of Orders Placed"
    description: "The number of orders they’ve placed"
    type: number
    sql: ${TABLE}.total_orders ;;
  }

  dimension: num_order_items {
    type: number
    sql: ${TABLE}.num_order_items ;;
  }

  dimension: avg_items_per_order {
    label: "Average Items Per Order"
    description: "The Average Number of Items Per Order"
    type: number
    sql: ${TABLE}.avg_items_per_order ;;
  }

  dimension: avg_sale_price {
    description: "Average Price of Items Ordered"
    type: number
    sql: ${TABLE}.avg_sale_price ;;
    value_format_name: usd
  }

  dimension: total_orders_completed {
    hidden: yes
    type: number
    sql: ${TABLE}.total_orders_completed ;;
  }

  dimension: count_orders_completed {
    label: "Orders Completed"
    description: "Amount of completed orders"
    type: number
    sql: ${TABLE}.count_orders_completed ;;
  }

  dimension: total_orders_pending {
    hidden: yes
    type: number
    sql: ${TABLE}.total_orders_pending ;;
  }

  dimension: count_orders_pending {
    label: "Orders Pending"
    description: "Amount of pending orders"
    type: number
    sql: ${TABLE}.count_orders_pending ;;
  }

# First and last order

  dimension: first_order {
    type: string
    sql: ${TABLE}.first_order ;;
  }

  dimension: latest_order {
    type: string
    sql: ${TABLE}.latest_order ;;
  }

  set: detail {
    fields: [
      user_id,
      has_moved,
      total_spent,
      total_orders,
      num_order_items,
      avg_sale_price,
      total_orders_completed,
      count_orders_completed,
      total_orders_pending,
      count_orders_pending,
      first_order,
      latest_order
    ]
  }
}
