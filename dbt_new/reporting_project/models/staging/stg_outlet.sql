{{ config(materialized='view') }}

with raw as (
    select
        id as outlet_id,
        org_id,
        name as outlet_name,
        latitude,
        longitude,
        "timestamp"::timestamp as outlet_ts
    from {{ source('public_raw', 'outlet') }}
),

deduped as (
    select *,
        row_number() over (
            partition by outlet_id
            order by outlet_ts desc
        ) as rn
    from raw
)

select
    outlet_id,
    org_id,
    outlet_name,
    latitude,
    longitude,
    outlet_ts
from deduped
where rn = 1