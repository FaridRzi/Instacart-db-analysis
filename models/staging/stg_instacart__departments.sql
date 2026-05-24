select
    department_id,
    department as department_name
from {{ source('instacart', 'departments') }}