select
    aisle_id,
    aisle as aisle_name
from {{ source('instacart', 'aisles') }}