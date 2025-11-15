{{ config(materialized='view') }}

with raw as (
    select
        listing_id,
        order_id,
        placed_at::timestamp as order_ts,
        status
    from {{ source('public_raw', 'orders') }}
),

deduped as (
    select *,
        row_number() over (
            partition by order_id
            order by order_ts desc
        ) as rn
    from raw
)

select
    listing_id,
    order_id,
    order_ts,
    status
from deduped
where rn = 1
