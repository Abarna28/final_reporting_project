{{ config(materialized='view') }}

with raw as (
    select
        id as org_id,
        name as org_name,
        ("timestamp")::timestamp as org_ts
    from {{ source('public_raw', 'org') }}
),

deduped as (
    select *,
        row_number() over (
            partition by org_id
            order by org_ts desc
        ) as rn
    from raw
)

select
    org_id,
    org_name,
    org_ts
from deduped
where rn = 1
