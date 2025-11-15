{{ config(materialized='view') }}

with raw as (
    select
        listing_id,
        date::date as rating_date,
        cnt_ratings,
        avg_rating
    from {{ source('public_raw', 'ratings_agg') }}
),

deduped as (
    select *,
        row_number() over (
            partition by listing_id, rating_date
            order by cnt_ratings desc
        ) as rn
    from raw
)

select
    listing_id,
    rating_date,
    cnt_ratings,
    avg_rating
from deduped
where rn = 1
