{{ config(materialized='view') }}

with cleaned as (
    select
        listing_id,
        date::text as date_raw,
        timestamp::text as ts_raw,
        is_online,
        rank,

        case
            when date::text ~ '^\d{2}-\d{2}-\d{4}$'
                then to_date(date::text, 'DD-MM-YYYY')
            when date::text ~ '^\d{4}-\d{2}-\d{2}$'
                then to_date(date::text, 'YYYY-MM-DD')
            else null
        end as rank_date,

        case
            when timestamp::text ~ '^\d{2}-\d{2}-\d{4} \d{2}:\d{2}$'
                then to_timestamp(timestamp::text, 'DD-MM-YYYY HH24:MI')
            else null
        end as rank_ts

    from {{ source('public_raw', 'rank') }}
),

deduped as (
    select *,
        row_number() over (
            partition by listing_id, rank_date
            order by rank_ts desc
        ) as rn
    from cleaned
)

select
    listing_id,
    rank_date,
    rank_ts,
    (is_online = 'TRUE') as is_online,
    rank
from deduped
where rn = 1
