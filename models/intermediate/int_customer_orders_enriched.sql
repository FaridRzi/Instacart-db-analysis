with orders as (
    select
        order_id,
        user_id,
        order_number,
        order_dow,
        order_hour_of_day,
        days_since_prior_order
    from {{ ref('stg_instacart__orders')}}
)

, order_proudcts as (
    select
        order_product_id,
        order_id,
        product_id,
        source_type,
        add_to_cart_order,
        has_reordered
    from {{ ref('stg_instacart__order_products')}}
)

, products as (
    select
        product_id,
        product_name,
        aisle_id,
        department_id
    from {{ ref('stg_instacart__products')}}
)

select
    op.order_product_id,
    o.order_id,
    o.user_id,
    o.order_number,
    o.order_dow,
    o.order_hour_of_day,
    o.days_since_prior_order,
    op.product_id,
    op.source_type,
    op.add_to_cart_order,
    op.has_reordered,
    p.product_name,
    p.department_id,
from orders o
left join order_proudcts op
    on o.order_id = op.order_id
left join products p
    on op.product_id = p.product_id
order by user_id, order_id, product_id