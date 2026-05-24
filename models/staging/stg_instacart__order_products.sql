-- We are not going to use this data for training a model. The goal is to build an analytics pipeline now
-- Therefore, we are going to merge the two tables order_products__prior and order_products__train into 
-- one table called stg_instacart__order_products. There will be a flag to indicate whether the record is 
-- from the prior or train table. This will allow us to use the same table for both analytics and modeling purposes in the future.

with order_products as (

select
    order_id,
    product_id,
    'prior' as source_type,
    add_to_cart_order,
    reordered,
from {{ source('instacart', 'order_products__prior') }} 

union all

select
    order_id,
    product_id,
    'train' as source_type,
    add_to_cart_order,
    reordered
from {{ source('instacart', 'order_products__train') }}

)
select

    {{ dbt_utils.generate_surrogate_key(['order_id', 'product_id']) }} order_product_id,
    order_id,
    product_id,
    source_type,
    add_to_cart_order,
    if(reordered = 1, true, false) as has_reordered
from order_products