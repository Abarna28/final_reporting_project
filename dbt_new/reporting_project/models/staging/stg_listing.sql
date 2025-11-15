{{ config(materialized='view') }}

with raw as (
    select
        id as listing_id,
        outlet_id,  -- Make sure this is included
        platform_id,
        ("timestamp")::timestamp as listing_ts
    from {{ source('public_raw', 'listing') }}
),

deduped as (
    select *,
        row_number() over (
            partition by listing_id, outlet_id, platform_id
            order by listing_ts desc
        ) as rn
    from raw
)

select
    listing_id,
    outlet_id,  -- Make sure this is included
    platform_id,
    listing_ts
from deduped
where rn = 1