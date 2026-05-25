with deps_count as (
    select
        user_id,
        department_id,
        count(*) as product_count
    from {{ ref('int_customer_orders_enriched') }}
    group by user_id, department_id
)

, ranked_deps as (
    select
        user_id,
        department_id,
        product_count,
        rank() OVER (PARTITION BY user_id ORDER BY product_count desc) as dep_rank
    from deps_count
)

, fav_deps as (
    select
        user_id,
        department_id as favorite_department_id,
    from ranked_deps
    where dep_rank = 1
)

select
    icoe.user_id,
    fd.favorite_department_id,
    count(distinct icoe.order_id) as total_orders,
    count(distinct icoe.order_id) as unique_orders,
    avg(icoe.days_since_prior_order) as avg_days_between_orders,
    count(distinct if(icoe.has_reordered, icoe.product_id, null)) / count(distinct icoe.product_id) as reorder_rate_item_lvl,
    count(distinct if(has_reordered, icoe.order_id, null)) / count(distinct icoe.order_id) as reorder_rate_order_lvl,
from {{ ref('int_customer_orders_enriched') }} as icoe
left join fav_deps as fd
    on icoe.user_id = fd.user_id
group by user_id, favroite_department_id
order by user_id