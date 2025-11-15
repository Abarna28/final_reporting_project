{{ config(materialized='table') }}

select
    outlet_id,
    (observation_time_utc)::timestamp as observation_time_utc,
    date((observation_time_utc)::timestamp) as observation_date,
    temperature_celsius,
    wind_speed_10m,
    relative_humidity_2m,
    created_at
from {{ source('public_raw', 'weather_hourly') }}
