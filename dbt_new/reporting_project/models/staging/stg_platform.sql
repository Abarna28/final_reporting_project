{{ config(materialized='view') }}

select
    id as platform_id,
    "group" as platform_group,
    name as platform_name,
    country as platform_country
from {{ source('public_raw', 'platform') }}
