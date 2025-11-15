{{ config(materialized='view') }}

with raw as (
    select
        listing_id,
        date::date as order_date,
        orders as daily_orders,
        "timestamp"::timestamp as updated_ts
    from {{ source('public_raw', 'orders_daily') }}
),

deduped as (
    select *,
        row_number() over (
            partition by listing_id, order_date
            order by updated_ts desc
        ) as rn
    from raw
)

select
    listing_id,
    order_date,
    daily_orders,
    updated_ts
from deduped
where rn = 1
